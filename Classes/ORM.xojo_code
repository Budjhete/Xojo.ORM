#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Method, Flags = &h0
		Function Add(pAlias As String, pFarkeys() As Variant) As ORM
		  // Converts any ORM that might be in the pFarkeys array
		  // into a variant
		  For pFarKey As Integer = 0 To pFarkeys.Ubound
		    If pFarkeys(pFarKey) IsA ORM Then
		      pFarKeys(pFarKey) = ORM(pFarKeys(pFarKey)).Pk()
		    End If
		  Next
		  
		  // Sets the columns to insert into
		  Dim pColumns() As Variant = Array(_
		  Dictionary(Me.mHasMany.Value(pAlias)).Value("ForeignKey"),_
		  Dictionary(Me.mHasMany.Value(pAlias)).Value("FarKey"))
		  // Defines the foreign key to use for this model
		  Dim pForeignKey As Variant = Me.Pk()
		  
		  // Links this model with each Far Key provided for
		  For Each pFarKey As Variant in pFarkeys
		    DB.Insert(Dictionary(Me.mHasMany.Value(pAlias)).Value("Through").StringValue,_
		    pColumns).Values(pForeignKey, pFarKey).Execute(Me.Database)
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pAlias As String, ParamArray pFarKeys As Variant) As ORM
		  Return Me.Add(pAlias, pFarKeys)
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
		Function BelongsTo() As Dictionary
		  return mBelongsTo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BelongsTo(pTableName As String, pForeignKey As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BelongsTo(pAlias As String, pForeignKey As String, pORM As ORM)
		  // pAlias will be the "property" through which we will acces the models that Me belongsTo
		  mBelongsTo.Value(pAlias) = New Dictionary("Model" : pORM, "ForeignKey" : pForeignKey)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  return mChanged.Keys().Ubound > -1
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

	#tag Method, Flags = &h1000
		Sub Constructor()
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mHasMany = New Dictionary
		  mBelongsTo = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pPrimaryKey As Variant)
		  Constructor()
		  
		  Call Where(PrimaryKey(), "=", pPrimaryKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll(pDatabase As Database) As Integer
		  Return DB.Find(DB.Expression("COUNT(*) AS count")).From(TableName).Execute(pDatabase).Field("count").IntegerValue
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountRelations(pAlias As String, pFarKeys() As Variant) As Integer
		  If Not Me.Loaded Then
		    return 0
		  End If
		  
		  
		  // The request that looks in the pivot table to see if this model is present
		  Dim pQueryBuilder As QueryBuilder = DB.Find(DB.Expression("COUNT(*) AS RecordsFound"))_
		  .From(Dictionary(Me.mHasMany.Value(pAlias)).Value("Through"))_
		  .Where(Dictionary(Me.mHasMany.Value(pAlias)).Value("ForeignKey"), "=", Me.Pk())
		  
		  // Converts any ORM in the array into a variant containing its primary key
		  For i As integer = 0 To pFarKeys.Ubound
		    If pFarKeys(i) IsA ORM Then
		      pFarKeys(i) = ORM(pFarKeys(i)).Pk()
		    End If
		  Next
		  
		  If pFarKeys.Ubound >= 0 Then
		    // The request to see if this model is related to the specified FarKeys
		    Call pQueryBuilder.Where(Dictionary(Me.mHasMany.Value(pAlias)).Value("FarKey"), "IN", pFarKeys)
		  End If
		  
		  Dim Records As RecordSet = pQueryBuilder.Execute(Me.Database)
		  
		  System.DebugLog(pQueryBuilder.Compile())
		  
		  // Returns the number of relations found
		  return Records.Field("RecordsFound").IntegerValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountRelations(pAlias As String, ParamArray pFarKeys As Variant) As Integer
		  // @FIXME Does not manage parameters that might be an array of any datatype
		  // Do not call it this way <code>MyORM.CountRelations("MyAlias", Array("FarKey1", "FarKey2"))</code>
		  Return Me.CountRelations(palias, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create(pDatabase As Database) As ORM
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
		Sub dumpChanges()
		  // For debug purposes
		  If Not Loaded Then
		    System.DebugLog "Model is not loaded !"
		  Else
		    System.DebugLog "Dumping " + Str(mChanged.Count) + " changed values : "
		    
		    Dim i As Integer = 0
		    Dim mesg As String
		    For i = 0 To mChanged.Count-1
		      mesg = mesg + " " + Str(mChanged.Key(i))
		    Next
		    System.DebugLog mesg
		    
		    
		    For Each element As Variant In mChanged.Keys
		      Dim msg As String = element.StringValue + " is : " _
		      + mChanged.Value(element).StringValue
		      
		      If mData.HasKey(element) Then
		        msg = msg + "; was : " + mData.Value(element).StringValue
		      Else
		        msg = msg + " (never was)"
		      End If
		      
		      System.DebugLog msg
		    Next
		  End If
		  
		End Sub
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
		      For Each pColumn As Variant In TableColumns(pDatabase)
		        mData.Value(pColumn) = pRecordSet.Field(pColumn).Value
		      Next
		      
		    End If
		    
		    RaiseEvent Found()
		    
		  End If
		  
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
		Function Has(pAlias As String, pFarKeys() As Variant) As Boolean
		  If pFarKeys.Ubound < 0 Then
		    Return (Me.CountRelations(pAlias) <> 0)
		  End If
		  
		  For i As Integer = 0 To pFarKeys.Ubound
		    If pFarKeys(i) IsA ORM Then
		      pFarKeys(i) = ORM(pFarKeys(i)).Pk()
		    End If
		  Next
		  
		  Return (Me.CountRelations(pAlias, pFarKeys) = pFarKeys.Ubound + 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pAlias As String, ParamArray pFarKeys As Variant) As Boolean
		  Return Me.Has(pAlias, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMany() As Dictionary
		  return mHasMany
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HasMany(pORM As ORM, pAlias As String, pForeignKey As String, Optional pThrough As String, Optional pFarKey As Variant)
		  If pFarKey.IsNull Then
		    pFarKey = pORM.TableName + "Id"
		  End If
		  // Sets a new HasMany relationship in between this model and any other
		  mHasMany.Value(pAlias) = New Dictionary("Model" : pORM, "ForeignKey" : pForeignKey, "Through" : pThrough, "FarKey" : pFarKey)
		End Sub
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
		Function Inflate(pORM As ORM) As ORM
		  // Inflate this ORM on another ORM
		  
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
		Function Remove(pAlias As String, pFarKeys() As Variant) As ORM
		  // Starts the QueryBuilder by removing everything that has this model's primary key as a foreign key
		  Dim pQueryBuilder As QueryBuilder = DB.Delete(Dictionary(Me.mHasMany.Value(pAlias)).Value("Through"))_
		  .Where(Dictionary(Me.mHasMany.Value(pAlias)).Value("ForeignKey"), "=", Me.Pk())
		  
		  // Converts any ORM into a variant
		  For pFarKey As Integer = 0 To pFarKeys.Ubound
		    If pFarKeys(pFarKey) IsA ORM Then
		      pFarKeys(pFarKey) = ORM(pFarKeys(pFarKey))
		    End If
		  Next
		  
		  // Adds a where clause if this Far Key's array is not empty
		  If pFarKeys.Ubound >= 0 Then
		    Call pQueryBuilder.Where(Dictionary(Me.mHasMany.Value(pAlias)).Value("FarKey"), "IN", pFarKeys)
		  End If
		  
		  pQueryBuilder.Execute(ORMTestDatabase)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pAlias As String, ParamArray pFarKeys As Variant) As ORM
		  Return Me.Remove(pAlias, pFarKeys)
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
		    
		    Dim returnValue As ORM
		    
		    If Loaded() Then
		      returnValue = Update(pDatabase)
		    Else
		      returnValue = Create(pDatabase)
		    End
		    
		    RaiseEvent Saved
		    
		    Return returnValue
		    
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
		  
		  If Not RaiseEvent Updating() Then
		    
		    DB.Update(TableName()).Set(mChanged).Where(PrimaryKey(), "=", Pk()).Execute(pDatabase)
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys()
		      mData.Value(pKey) = mChanged.Value(pKey)
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


	#tag Property, Flags = &h1
		Protected mBelongsTo As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHasMany As Dictionary
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
