#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Method, Flags = &h0
		Function AndHaving(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  AndHaving(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  AndWhere(pColumn, pOperator, pValue)
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
		Sub Clear()
		  // Clear changes, not data
		  mChanged.Clear()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  mData = New Dictionary()
		  mChanged = New Dictionary()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll(pDatabase As Database) As Integer
		  mQuery.Append(new SelectQueryExpression("COUNT(*)", TableName()))
		  
		  Dim pRecordSet As RecordSet = Execute(pDatabase)
		  
		  Return pRecordSet.Field("(COUNT(*))").IntegerValue()
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Create(pDatabase As Database)
		  if Loaded() then
		    Raise new ORMException("Cannot create " + TableName() + " model because it is already loaded.")
		  end
		  
		  RaiseEvent Creating()
		  
		  Dim pColumns() As String
		  
		  // Cast columns to string
		  For Each pKey As Variant In mChanged.Keys()
		    pColumns.Append(pKey.StringValue)
		  Next
		  
		  mQuery.Append(new InsertQueryExpression(TableName(), pColumns))
		  mQuery.Append(new ValuesQueryExpression(mChanged.Values()))
		  
		  Execute(pDatabase)
		  
		  // Update data
		  For Each pKey As Variant In mChanged.Keys()
		    mData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  // Clear changes, they are saved in mData
		  Clear()
		  
		  Dim pRecordSet As RecordSet = DB.Find(PrimaryKey(), TableName()).OrderBy(PrimaryKey(), "DESC").Execute(pDatabase)
		  
		  // Update primary key from the last row inserted in this table
		  mData.Value(PrimaryKey()) = pRecordSet.Field(PrimaryKey())
		  
		  RaiseEvent Created()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create(pDatabase As Database) As ORM
		  Create(pDatabase)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data() As Dictionary
		  // @TODO merger mChanged sur mData
		  Return mData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(pData as Dictionary)
		  For Each pKey As Variant In pData.Keys()
		    Data(pKey, pData.Value(pKey))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pData as Dictionary) As ORM
		  Data(pData)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As String) As Variant
		  // Getter for data
		  If mChanged.HasKey(pColumn) Then
		    Return mChanged.Value(pColumn)
		  End If
		  
		  Return mData.Value(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(pColumn As String, pValue As Variant)
		  // If it is different than the original data, it has changed
		  If mData.Value(pColumn) <> pValue Then
		    RaiseEvent Changing()
		    mChanged.Value(pColumn) = pValue
		    RaiseEvent Changed()
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As String, pValue As Variant) As ORM
		  Data(pColumn, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(pDatabase As Database)
		  if Not Loaded() then
		    Raise new ORMException("Cannot delete " + TableName() + " model because it is not loaded.")
		  end
		  
		  RaiseEvent Deleting()
		  
		  mQuery.Append(new DeleteQueryExpression(TableName()))
		  Where(PrimaryKey(), "=", Pk())
		  
		  Execute(pDatabase)
		  
		  Unload()
		  Clear()
		  
		  RaiseEvent Deleted()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Find(pDatabase As Database)
		  If Loaded() Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  mQuery.Append(new SelectQueryExpression(TableName()))
		  mQuery.Append(new LimitQueryExpression(1))
		  
		  RaiseEvent Finding()
		  
		  Dim pRecordSet As RecordSet = Execute(pDatabase)
		  
		  // Fetch record set
		  For Each pColumn As Variant In TableColumns(pDatabase)
		    mData.Value(pColumn) = pRecordSet.Field(pColumn).Value
		  Next
		  
		  RaiseEvent Found()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pDatabase As Database) As ORM
		  Find(pDatabase)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll(pDatabase As Database) As RecordSet
		  mQuery.Append(new SelectQueryExpression(TableColumns(pDatabase), TableName()))
		  Return Execute(pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As String) As ORM
		  GroupBy(pColumns)
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
		  Having(pValues)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Having(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial() As Dictionary
		  Return mData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial(pColumn As String) As Variant
		  Return mData.Value(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial(pColumn As String, pValue As Variant) As ORM
		  Data(pColumn, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pDirection As String, pTableName As String) As ORM
		  Join(pDirection, pTableName)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Limit(pLimit As Integer) As ORM
		  Limit(pLimit)
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
		  Offset(pOffset)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  On(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumns() As String, pDirection As String = "ASC") As ORM
		  OrderBy(pColumns, pDirection)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As String, pDirection As String = "ASC") As ORM
		  OrderBy(pColumn, pDirection)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  OrHaving(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  OrWhere(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pk() As Integer
		  // Primary key value
		  Return Data(PrimaryKey()).IntegerValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKey() As String
		  // Retourne la colonne de la clé primaire
		  Return "id"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reload(pDatabase As Database)
		  Dim pk As Integer = Pk()
		  
		  Unload() // Empty data, not changes
		  
		  Where(PrimaryKey(), "=", pk)
		  
		  Find(pDatabase) // Reload data
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As ORM
		  Reset()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save(pDatabase As Database)
		  If Loaded() Then
		    Update(pDatabase)
		  Else
		    Create(pDatabase)
		  End
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(pDatabase As Database) As ORM
		  Save(pDatabase)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Dictionary) As ORM
		  Set(pValues)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableColumns(pDatabase As Database) As String()
		  Dim pColumns() As String
		  
		  Dim pRecordSet As RecordSet = pDatabase.FieldSchema(TableName)
		  
		  While Not pRecordSet.EOF
		    pColumns.Append(pRecordSet.Field("ColumnName").StringValue)
		    pRecordSet.MoveNext()
		  WEnd
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unload()
		  // Vide les données, pas les changements
		  mData.Clear()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unload() As ORM
		  Unload()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update(pDatabase As Database)
		  If Not Loaded() then
		    Raise new ORMException("Cannot update " + TableName() + " model because it is not loaded.")
		  End If
		  
		  RaiseEvent Updating()
		  
		  mQuery.Append(new UpdateQueryExpression(TableName()))
		  Set(mChanged)
		  Where(PrimaryKey(), "=", Pk())
		  
		  Execute(pDatabase)
		  
		  For Each pKey As Variant In mChanged.Keys()
		    mData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  Clear()
		  
		  RaiseEvent Updated()
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pDatabase As Database) As ORM
		  Update(pDatabase)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As ORM
		  Values(pValues)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Where(pColumn, pOperator, pValue)
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

	#tag Property, Flags = &h0
		TableName As String
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
			Name="TableName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
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
