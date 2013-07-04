#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Method, Flags = &h0
		Sub AddORMListener(pORMListener As ORMListener)
		  mORMListeners.Append(pORMListener)
		End Sub
	#tag EndMethod

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
		Function Changed() As Boolean
		  return mChanged.Keys().Ubound >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed(pColumn as String) As Boolean
		  return mChanged.HasKey(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  mData = new Dictionary()
		  mChanged = new Dictionary()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(mValues As Dictionary)
		  Constructor()
		  
		  For Each pKey As String In mValues.Keys()
		    Where(pKey, "=", mValues.Value(pKey))
		  Next
		  
		  Find()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pk as Integer)
		  Constructor()
		  
		  Where(PrimaryKey(), "=", pk)
		  
		  Find()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll() As Integer
		  // Compte les résultats
		  
		  mQuery.Append(new SelectQueryExpression(TableName(), TableColumns()))
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Create()
		  if Loaded() then
		    Raise new ORMException("Cannot create " + TableName() + " model because it is already loaded.")
		  end
		  
		  RaiseEvent Creating()
		  
		  Dim pColumns() As String
		  
		  // Cast columns to string
		  For Each pKey As Variant In mData.Keys()
		    pColumns.Append(pKey.StringValue)
		  Next
		  
		  mQuery.Append(new InsertQueryExpression(TableName(), pColumns))
		  mQuery.Append(new ValuesQueryExpression(mData.Values()))
		  
		  Execute(mDatabase)
		  
		  Dim pRecordSet As RecordSet = DB.Find(TableName(), Array("id")).OrderBy(PrimaryKey(), "DESC").Execute(mDatabase)
		  
		  // Update primary key from the last row inserted in this table
		  mData.Value(PrimaryKey()) = pRecordSet.Field(PrimaryKey())
		  
		  RaiseEvent Created()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create() As ORM
		  Create()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data() As Dictionary
		  return mData
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
		  If mChanged.HasKey(pColumn) Then
		    Return mChanged.Value(pColumn)
		  End If
		  
		  Return mData.Value(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(pColumn As String, pValue As Variant)
		  If Not mData.HasKey(pColumn) Then
		    mData.Value(pColumn) = pValue
		  End If
		  
		  // If it is different than the original data, it has changed
		  If mData.Value(pColumn) <> pValue Then
		    mChanged.Value(pColumn) = pValue
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
		Sub Delete()
		  if Not Loaded() then
		    Raise new ORMException("Cannot delete " + TableName() + " model because it is not loaded.")
		  end
		  
		  RaiseEvent Deleting()
		  
		  mQuery.Append(new DeleteQueryExpression(TableName()))
		  Where(PrimaryKey(), "=", Pk())
		  
		  Execute(mDatabase)
		  
		  mData.Clear()
		  mChanged.Clear()
		  
		  RaiseEvent Deleted()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Find()
		  If Loaded() Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  mQuery.Append(new SelectQueryExpression(TableName(), TableColumns()))
		  mQuery.Append(new LimitQueryExpression(1))
		  
		  RaiseEvent Finding()
		  
		  Dim pRecordSet As RecordSet = Execute(mDatabase)
		  
		  // Fetch record set
		  For Each pColumn As Variant In TableColumns()
		    mData.Value(pColumn) = pRecordSet.Field(pColumn).Value
		  Next
		  
		  RaiseEvent Found()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find() As ORM
		  Find()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll() As RecordSet
		  mQuery.Append(new SelectQueryExpression(TableName(), TableColumns()))
		  Return Execute(mDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As String) As ORM
		  GroupBy(pColumns)
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
		Function Join(pTableName As String) As ORM
		  Join(pTableName)
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
		  Return mData.HasKey(PrimaryKey())
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Lock()
		  // @TODO lock options
		  Dim pStatement As String = "LOCK TABLE " + QueryCompiler.TableName(TableName()) + " WRITE"
		  
		  // Lock table for this model
		  mDatabase.SQLExecute(pStatement)
		  
		  If mDatabase.Error Then
		    Raise New ORMException(mDatabase.ErrorMessage + " " + pStatement)
		  Else
		    mDatabase.Commit()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lock() As ORM
		  Lock()
		  Return Me
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
		 Shared Function Pool(pTableName As String, pPrimaryKey As Integer) As ORM
		  If mPool Is Nil Then
		    mPool = New Dictionary
		  End If
		  
		  Dim pKey As String = Str(pPrimaryKey) + "@" + pTableName
		  
		  If mPool.HasKey(pKey) Then
		    // Return mPool.Value(pKey)
		  End If
		  
		  // Fetch a new instance
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKey() As String
		  // Retourne la colonne de la clé primaire
		  Return "id"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As ORM
		  Reset()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save()
		  If Loaded() Then
		    Update()
		  Else
		    Create()
		  End
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save() As ORM
		  Save()
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
		Function TableColumns() As String()
		  // Retourne les colonnes de la table
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  // Retourne le nom de la table
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unlock()
		  // Unlock table for this model
		  
		  Dim pStatement As String = "UNLOCK TABLES"
		  
		  mDatabase.SQLExecute(pStatement)
		  
		  If mDatabase.Error Then
		    Raise New ORMException(mDatabase.ErrorMessage + " " + pStatement)
		  Else
		    mDatabase.Commit()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unlock() As ORM
		  Unlock()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update()
		  If Not Loaded() then
		    Raise new ORMException("Cannot update " + TableName() + " model because it is not loaded.")
		  End If
		  
		  If Not Changed() Then
		    Return
		  End If
		  
		  RaiseEvent Updating()
		  
		  mQuery.Append(new UpdateQueryExpression(TableName()))
		  Set(mChanged)
		  Where(PrimaryKey(), "=", Pk())
		  
		  Execute(mDatabase)
		  
		  For Each pKey As Variant In mChanged.Keys()
		    mData.Value(pKey) = mChanged.Value(pKey)
		  Next
		  
		  RaiseEvent Updated()
		  
		  mChanged.Clear()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update() As ORM
		  Update()
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


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mDatabase
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mDatabase = value
			End Set
		#tag EndSetter
		Shared Database As Database
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mDatabase As Database
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mORMListeners() As ORMListener
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mPool As Dictionary
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
