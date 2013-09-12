#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Method, Flags = &h0
		Function Add() As Dictionary
		  Dim pAdd As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In mAdd.Keys()
		    pAdd.Value(pKey) = mAdd.Value(pKey)
		  Next
		  
		  Return pAdd
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pFarKeys() As Variant) As ORM
		  For Each pFarKey As Variant In pFarKeys
		    
		    If Not RaiseEvent Changing Then
		      
		      Dim pIdentifier As String = pForeignColumn + "=" + Me.Pk + "&" + pFarColumn + "=" + pFarKey + "@" + pPivotTableName
		      
		      If mRemove.HasKey(pIdentifier) Then
		        mRemove.Remove(pIdentifier)
		      Else
		        mAdd.Value(pIdentifier) = New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, Me.Pk, pFarColumn, pFarKey)
		      End If
		      
		      RaiseEvent Changed
		      
		    End If
		    
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, ParamArray pFarKeys As Variant) As ORM
		  Return Add(pPivotTableName, pForeignColumn, pFarColumn, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndHaving(pLeft As Variant, pOperator As String, pRight As Variant) As ORM
		  Call Super.AndHaving(pLeft, pOperator, pRight)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pLeft As Variant, pOperator As String, pRight As Variant) As ORM
		  Call Super.AndWhere(pLeft, pOperator, pRight)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  Return mChanged.Keys().Ubound > -1 Or mAdd.Keys().Ubound > -1 Or mRemove.Keys.Ubound > -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed(pColumn as String) As Boolean
		  return mChanged.HasKey(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clear() As ORM
		  // Clear changes, not data
		  mChanged.Clear()
		  mAdd.Clear()
		  mRemove.Clear()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdd = New Dictionary
		  mRemove = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pPrimaryKey As Variant)
		  Constructor()
		  
		  Call Where(PrimaryKey(), "=", pPrimaryKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy() As ORM
		  Dim ORMConstructors() As Introspection.ConstructorInfo = Introspection.GetType(Me).GetConstructors
		  Dim CopyORM As ORM = ORMConstructors(0).Invoke()
		  
		  Return CopyORM.Deflate(Me)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll(pDatabase As Database) As Integer
		  Return DB.Find(DB.Expression("COUNT(*) AS count")).From(TableName).Execute(pDatabase).Field("count").IntegerValue
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  if Loaded() then
		    Raise new ORMException("Cannot create " + TableName() + " model because it is already loaded.")
		  end
		  
		  If Not RaiseEvent Creating() Then
		    
		    DB.Insert(TableName(), mChanged.Keys()).Values(mChanged.Values()).Execute(pDatabase)
		    
		    // Update data
		    For Each pKey As Variant In mChanged.Keys()
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear changes, they are saved in mData
		    Call Clear()
		    
		    Dim pRecordSet As RecordSet = DB.Find(PrimaryKey()).From(TableName).OrderBy(PrimaryKey(), "DESC").Execute(pDatabase)
		    
		    // Update primary key from the last row inserted in this table
		    mData.Value(PrimaryKey()) = pRecordSet.Field(PrimaryKey())
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mAdd.Values()
		      Call pRelation.Add(pDatabase)
		    Next
		    
		    For Each pRelation As ORMRelation In mRemove.Values()
		      Call pRelation.Remove(pDatabase)
		    Next
		    
		    RaiseEvent Created()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data() As Dictionary
		  Dim pData As Dictionary = Initial()
		  
		  // Merge mChanged over mData
		  For Each pKey As Variant In mChanged.Keys()
		    pData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pData as Dictionary) As ORM
		  For Each pKey As Variant In pData.Keys()
		    Call Data(pKey, pData.Value(pKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As String) As Variant
		  // Getter for data
		  If mChanged.HasKey(pColumn) Then
		    Return mChanged.Value(pColumn)
		  End If
		  
		  Return mData.Lookup(pColumn, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(pcolumn As String, Assigns pValue As Variant)
		  Call Data(pColumn, pValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As String, pValue As Variant) As ORM
		  If Not RaiseEvent Changing() Then
		    
		    // Database support Booleans as 1's and 0's
		    If pValue.Type = pValue.TypeBoolean And pValue Then
		      pValue = 1
		    ElseIf pValue.Type = pValue.TypeBoolean And Not pValue Then
		      pValue = 0
		    End
		    
		    // If it is different than the original data, it has changed
		    If Initial(pColumn) <> pValue Then
		      mChanged.Value(pColumn) = pValue
		    ElseIf mChanged.HasKey(pColumn) Then
		      mChanged.Remove(pColumn)
		    End If
		    
		    RaiseEvent Changed()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Database() As Database
		  return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Deflate(pORM As ORM) As ORM
		  Call pORM.Inflate(Me)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(pDatabase As Database) As ORM
		  if Not Loaded() then
		    Raise new ORMException("Cannot delete " + TableName() + " model because it is not loaded.")
		  end
		  
		  If Not RaiseEvent Deleting() Then
		    
		    DB.Delete(TableName()).Where(PrimaryKey(), "=", Pk()).Execute(pDatabase)
		    
		    // Empty mData
		    Call Unload()
		    
		    // Empty mChanges
		    Call Clear()
		    
		    RaiseEvent Deleted()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find() As ORM
		  Return Me.Find(Me.Database)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pDatabase As Database) As ORM
		  If Loaded() Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding() Then
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As RecordSet = Append(new SelectQueryExpression(TableColumns(pDatabase))).From(TableName).Limit(1).Execute(pDatabase)
		    
		    If pRecordSet <> Nil Then
		      
		      // Fetch record set
		      
		      For i As Integer = 1 To pRecordSet.FieldCount
		        Dim pColumn As String = pRecordSet.IdxField(i).Name
		        mData.Value(pColumn) = pRecordSet.Field(pColumn).Value
		      Next
		      
		    End If
		    
		    RaiseEvent Found()
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll() As RecordSet
		  Return Me.FindAll(Me.Database)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll(pDatabase As Database) As RecordSet
		  Return Append(new SelectQueryExpression(TableColumns(pDatabase))).From(TableName).Execute(pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As Variant) As ORM
		  Call Super.GroupBy(pColumns)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(ParamArray pColumns As Variant) As ORM
		  Call Super.GroupBy(pColumns)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pDatabase As Database) As Boolean
		  // Tells if this model is in HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pPivotTableName As String, pForeignColumn As String, pFarColumn As Variant, pFarKey As Variant, pDatabase As Database) As Boolean
		  // Tells if this model is in HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  AndWhere(pFarColumn, "=", pFarKey)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasMany(pORM As ORM, pForeignColumn As String) As ORM
		  Return pORM._
		  Where(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasManyThrough(pORM As ORM, pPivotTableName As String, pForeignColumn As String, pFarColumn As String) As ORM
		  Return pORM._
		  Join(pPivotTableName)._
		  On(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HasOne(pTableName As String, pFarKey As String, pORM As ORM)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pValues As Dictionary) As ORM
		  Call Super.Having(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Call Super.Having(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HavingClose() As ORM
		  Call Super.HavingClose()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HavingOpen() As ORM
		  Call Super.HavingOpen()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Inflate(pORM As ORM) As ORM
		  // Inflate this ORM on another ORM
		  
		  // Call QueryBuilder Inflate
		  Call Super.Inflate(pORM)
		  
		  // Clear mData
		  pORM.mData.Clear()
		  
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In mData.Keys()
		    pORM.mData.Value(pKey) = mData.Value(pKey)
		  Next
		  
		  // Clear mChanged
		  pORM.mChanged.Clear()
		  
		  // Use a copy of mChanged to avoid external changes
		  For Each pKey As Variant In mChanged.Keys()
		    pORM.mChanged.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  pORM.mAdd.Clear
		  
		  // Use a copy of mAdd to avoid external changes
		  For Each pKey As Variant In mAdd.Keys()
		    pORM.mAdd.Value(pKey) = mAdd.Value(pKey)
		  Next
		  
		  pORM.mRemove.Clear
		  
		  // Use a copy of mRemove to avoid external changes
		  For Each pKey As Variant In mRemove.Keys()
		    pORM.mRemove.Value(pKey) = mRemove.Value(pKey)
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial() As Dictionary
		  Dim pData As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In mData.Keys()
		    pData.Value(pKey) = mData.Value(pKey)
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial(pColumn As String) As Variant
		  Return mData.Lookup(pColumn, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As String) As ORM
		  Call Super.Join(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As String, pTableAlias As String) As ORM
		  Call Super.Join(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Limit(pLimit As Integer) As ORM
		  Call Super.Limit(pLimit)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Loaded() As Boolean
		  // Model must have a primary key and that primary key must not be Nil
		  Return Initial(PrimaryKey()) <> Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Offset(pOffset As Integer) As ORM
		  Call Super.Offset(pOffset)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn As Variant, pOperator As String, pValue As Variant) As ORM
		  Call Super.On(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Operator_Convert(pRecord As RecordSet)
		  Constructor
		  For i As Integer = 1 To pRecord.FieldCount
		    mData.Value(pRecord.IdxField(i).Name) = pRecord.IdxField(i).Value
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumns() As Variant, pDirections() As String) As ORM
		  Call Super.OrderBy(pColumns, pDirections)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As Variant, pDirection As String = "ASC") As ORM
		  Call Super.OrderBy(pColumn, pDirection)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Call Super.OrHaving(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Call Super.OrWhere(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pk() As Variant
		  // Initial primary key value
		  Return Initial(PrimaryKey())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Pk(Assigns pValue As Variant)
		  Data(PrimaryKey()) = pValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKey() As String
		  // Retourne la colonne de la clé primaire
		  Return "id"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reload(pDatabase As Database) As ORM
		  // Save primary key, the model will be unloaded
		  
		  Dim pk As Variant = Pk()
		  
		  Call Unload()
		  
		  // Empty data, not changes and reload data
		  Return Where(PrimaryKey(), "=", pk).Find(pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove() As Dictionary
		  Dim pRemove As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In mRemove.Keys()
		    pRemove.Value(pKey) = mRemove.Value(pKey)
		  Next
		  
		  Return pRemove
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pFarKeys() As Variant) As ORM
		  // Remove a HasManyThrough relationship
		  
		  If pFarKeys.Ubound = -1 Then
		    pFarKeys.Append(DB.Expression("*"))
		  End If
		  
		  For Each pFarKey As Variant In pFarKeys
		    
		    If Not RaiseEvent Changing Then
		      
		      Dim pIdentifier As String = pForeignColumn + "=" + Me.Pk + "&" + pFarColumn + "=" + pFarKey + "@" + pPivotTableName
		      
		      If mAdd.HasKey(pIdentifier) Then
		        mAdd.Remove(pIdentifier)
		      Else
		        mRemove.Value(pIdentifier) = New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, Me.Pk, pFarColumn, pFarKey)
		      End If
		      
		      RaiseEvent Changed
		      
		    End If
		    
		  Next
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, ParamArray pFarKeys As Variant) As ORM
		  Return Remove(pPivotTableName, pForeignColumn, pFarColumn, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As ORM
		  Call Super.Reset()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(pDatabase As Database) As ORM
		  If Not RaiseEvent Saving Then
		    
		    If Loaded() Then
		      Call Update(pDatabase)
		    Else
		      Call Create(pDatabase)
		    End
		    
		    RaiseEvent Saved
		    
		    Return Me
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Dictionary) As ORM
		  Call Super.Set(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(ParamArray pValues As Pair) As ORM
		  Dim pDictionary As Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Call Super.Set(pDictionary)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableColumns(pDatabase As Database) As Variant()
		  Dim pColumns() As Variant
		  
		  Dim pRecordSet As RecordSet = pDatabase.FieldSchema(TableName)
		  
		  While Not pRecordSet.EOF
		    pColumns.Append(TableName() + "." + pRecordSet.Field("ColumnName").Value)
		    pRecordSet.MoveNext()
		  WEnd
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Return Introspection.GetType(Me).Name
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unload() As ORM
		  // Vide les données, pas les changements
		  mData.Clear()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Loaded() then
		    Raise new ORMException("Cannot update " + TableName() + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    // Update only if there are changes
		    If mChanged.Count > 0 Then
		      
		      DB.Update(TableName()).Set(mChanged).Where(PrimaryKey(), "=", Pk()).Execute(pDatabase)
		      
		      // Merge mData with mChanged
		      For Each pKey As Variant In mChanged.Keys()
		        mData.Value(pKey) = mChanged.Value(pKey)
		      Next
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mAdd.Values()
		      Call pRelation.Add(pDatabase)
		    Next
		    
		    For Each pRelation As ORMRelation In mRemove.Values()
		      Call pRelation.Remove(pDatabase)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    Call Clear()
		    
		    RaiseEvent Updated()
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Using(pColumns() As Variant) As ORM
		  Call Super.Using(pColumns)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Using(ParamArray pColumns As Variant) As ORM
		  Return Using(pColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(ParamArray pValues() As Variant) As ORM
		  Call Super.Values(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As ORM
		  Call Super.Values(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pCriterias As Dictionary) As ORM
		  For Each pKey As Variant in pCriterias.Keys
		    Call Where(pKey, "=", pCriterias.Value(pKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Call Super.Where(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WhereClose() As ORM
		  Call Super.WhereClose()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WhereOpen() As ORM
		  Call Super.WhereOpen()
		  
		  Return Me
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Changed()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Changing() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Created()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Creating() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deleted()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deleting() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Finding() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Found()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Saved()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Saving() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Updated()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Updating() As Boolean
	#tag EndHook


	#tag Note, Name = Has
		
		Ne sert qu'à vérifier les relations Has Many Through
	#tag EndNote


	#tag Property, Flags = &h21
		Private mAdd As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRemove As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
