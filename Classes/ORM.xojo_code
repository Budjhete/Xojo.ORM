#tag Class
Protected Class ORM
Inherits QueryBuilder
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
		Function BelongsTo(pTableName As String, pForeignKey As Integer) As ORM
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BelongsTo(pTableName As String, pForeignKey As Integer, pORM As ORM)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  return mChanged.Keys().Ubound >= 0
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
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As ORM
		  Return New ORM(Me)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  mData = New Dictionary()
		  mChanged = New Dictionary()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pORM As ORM)
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In pORM.mData.Keys()
		    mData.Value(pKey) = pORM.mData.Value(pKey)
		  Next
		  
		  // Use a copy of mChanged to avoid external changes
		  For Each pKey As Variant In pORM.mChanged.Keys()
		    mChanged.Value(pKey) = pORM.mChanged.Value(pKey)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll(pDatabase As Database) As Integer
		  Return DB.Find(DB.Expression("COUNT(*) AS count")).From(TableName).Execute(pDatabase).Field("count").IntegerValue
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create(pDatabase As Database) As ORM
		  if Loaded() then
		    Raise new ORMException("Cannot create " + TableName() + " model because it is already loaded.")
		  end
		  
		  RaiseEvent Creating()
		  
		  DB.Insert(TableName(), mChanged.Keys()).Values(mChanged.Values()).Execute(pDatabase)
		  
		  // Update data
		  For Each pKey As Variant In mChanged.Keys()
		    mData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  // Reset QueryBuilder
		  Call Reset()
		  
		  // Clear changes, they are saved in mData
		  Call Clear()
		  
		  Dim pRecordSet As RecordSet = DB.Find(PrimaryKey()).From(TableName).OrderBy(PrimaryKey(), "DESC").Execute(pDatabase)
		  
		  // Update primary key from the last row inserted in this table
		  mData.Value(PrimaryKey()) = pRecordSet.Field(PrimaryKey())
		  
		  RaiseEvent Created()
		  
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
		Function Data(pColumn As String, pValue As Variant) As ORM
		  // If it is different than the original data, it has changed
		  If Initial(pColumn) <> pValue Then
		    RaiseEvent Changing()
		    mChanged.Value(pColumn) = pValue
		    RaiseEvent Changed()
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(pDatabase As Database)
		  if Not Loaded() then
		    Raise new ORMException("Cannot delete " + TableName() + " model because it is not loaded.")
		  end
		  
		  RaiseEvent Deleting()
		  
		  Append(new DeleteQueryExpression(TableName())).Where(PrimaryKey(), "=", Pk()).Execute(pDatabase)
		  
		  Call Unload()
		  
		  Call Clear()
		  
		  RaiseEvent Deleted()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pDatabase As Database) As ORM
		  If Loaded() Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  RaiseEvent Finding()
		  
		  // Add SELECT and LIMIT 1 to the query
		  Dim pRecordSet As RecordSet = Append(new SelectQueryExpression(TableColumns(pDatabase))).From(TableName).Limit(1).Execute(pDatabase)
		  
		  // Fetch record set
		  For Each pColumn As Variant In TableColumns(pDatabase)
		    mData.Value(pColumn) = pRecordSet.Field(pColumn).Value
		  Next
		  
		  RaiseEvent Found()
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll(pDatabase As Database) As RecordSet
		  Return DB.Find(TableColumns(pDatabase)).From(TableName()).Execute(pDatabase)
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
		Function Has(pTableName As String, pForeignKey As Variant, pFarTable As String, pFarKey As Variant) As Boolean
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasOne(pTableName As String, pFarKey As String) As RecordSet
		  
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
		Function Initial() As Dictionary
		  Dim pData As Dictionary
		  
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
		  Return Data(PrimaryKey()) <> Nil
		  
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
		  // Primary key value
		  Return Data(PrimaryKey())
		End Function
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
		Function Reset() As ORM
		  Call Super.Reset()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(pDatabase As Database) As ORM
		  If Loaded() Then
		    Return Update(pDatabase)
		  Else
		    Return Create(pDatabase)
		  End
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
		    pColumns.Append(pRecordSet.Field("ColumnName").Value)
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
		  If Not Loaded() then
		    Raise new ORMException("Cannot update " + TableName() + " model because it is not loaded.")
		  End If
		  
		  RaiseEvent Updating()
		  
		  Append(new UpdateQueryExpression(TableName)).Set(mChanged).Where(PrimaryKey(), "=", Pk()).Execute(pDatabase)
		  
		  For Each pKey As Variant In mChanged.Keys()
		    mData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  // Clear mChanged, they are merged in mData
		  Call Clear()
		  
		  RaiseEvent Updated()
		  
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
		Event Changing()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Created()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Creating()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deleted()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deleting()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Finding()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Found()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Updated()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Updating()
	#tag EndHook


	#tag Property, Flags = &h21
		Private mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mData As Dictionary
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
