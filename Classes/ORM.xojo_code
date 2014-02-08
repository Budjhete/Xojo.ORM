#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Event
		Sub Close()
		  RaiseEvent Close
		End Sub
	#tag EndEvent

	#tag Event
		Sub CreatePane()
		  RaiseEvent CreatePane
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  RaiseEvent Open
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function Add() As Dictionary
		  Dim pAdded As New Dictionary
		  
		  For Each pKey As Variant In mAdded.Keys()
		    pAdded.Value(pKey) = mAdded.Value(pKey)
		  Next
		  
		  Return pAdded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pORMRelation As ORMRelation) As ORM
		  If Not RaiseEvent Adding(pORMRelation) Then
		    
		    If mRemoved.HasKey(pORMRelation) Then
		      mRemoved.Remove(pORMRelation)
		    Else
		      mAdded.Value(pORMRelation) = pORMRelation
		    End If
		    
		    RaiseEvent Added(pORMRelation)
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pForeignColumn As String, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Add(New ORMRelationHasMany(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pForeignColumn As String, ParamArray pORMs As ORM) As ORM
		  Return Me.Add(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Add(New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, pFarColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, ParamArray pORMs As ORM) As ORM
		  Return Add(pPivotTableName, pForeignColumn, pFarColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddHard(pForeignColumn As String, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Add(New ORMRelationHasManyHard(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddHard(pForeignColumn As String, ParamArray pORMs As ORM) As ORM
		  Return Me.AddHard(pForeignColumn, pORMs)
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
		Function Append(pQueryExpression As QueryExpression) As ORM
		  Call Super.Append(pQueryExpression)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BelongsTo(pPks As Dictionary, pORM As ORM) As ORM
		  Return pORM.Where(pPks)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BelongsTo(pForeignKey As String, pORM As ORM) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "=", Me.Data(pForeignKey))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bind(pTableName As String, pForeignColumn As String) As ORM
		  Return Me.Join(pTableName).On(pTableName + "." + pForeignColumn, "=", Me.TableName + "." + Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  Return mChanged.Keys().Ubound > -1 Or mAdded.Keys().Ubound > -1 Or mRemoved.Keys.Ubound > -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed(pColumn as String) As Boolean
		  Return mChanged.HasKey(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clear() As ORM
		  // Clear changes, not data
		  
		  If Not RaiseEvent Clearing() Then
		    
		    mChanged.Clear()
		    mAdded.Clear()
		    mRemoved.Clear()
		    
		    RaiseEvent Cleared()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  Super.Constructor
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pCriterias As Dictionary)
		  Me.Constructor
		  
		  Call Me.Where(pCriterias)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pORM As ORM)
		  Me.Constructor(pORM.Pks)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pRecordSet As RecordSet)
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = pRecordSet.IdxField(pIndex).Value
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy() As ORM
		  Dim pConstructors() As Introspection.ConstructorInfo = Introspection.GetType(Me).GetConstructors
		  
		  Dim pParameters() As Variant
		  pParameters.Append(Me.Query)
		  
		  Dim pCopy As ORM = pConstructors(0).Invoke(pParameters)
		  
		  For Each pColumn As String In mData.Keys
		    pCopy.mData.Value(pColumn) = Me.mData.Value(pColumn)
		  Next
		  
		  For Each pColumn As String In mChanged.Keys
		    pCopy.mChanged.Value(pColumn) = Me.mChanged.Value(pColumn)
		  Next
		  
		  For Each pKey As Variant In mAdded.Keys
		    pCopy.mAdded.Value(pKey) = Me.mAdded.Value(pKey)
		  Next
		  
		  For Each pKey As Variant In mRemoved.Keys
		    pCopy.mRemoved.Value(pKey) = Me.mRemoved.Value(pKey)
		  Next
		  
		  Return pCopy
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountAll(pDatabase As Database) As Integer
		  Dim pColumns() As Variant
		  pColumns.Append(DB.Expression("COUNT(*) AS count"))
		  
		  Return Append(New SelectQueryExpression(pColumns)).From(TableName).Execute(pDatabase).Field("count").IntegerValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Create(pDatabase As Database, pCommit As Boolean = True) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Loaded Then
		    Raise new ORMException("Cannot create " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn) Then
		        pChanged.Value(pColumn) = mChanged.Value(pColumn)
		      End If
		    Next
		    
		    If pChanged.Count = 0 Then
		      // Insert NULL as primary key will increment it
		      DB.Insert(Me.TableName, Me.PrimaryKey).Values(DB.Expression("NULL")).Execute(pDatabase, pCommit)
		    Else
		      DB.Insert(Me.TableName, pChanged.Keys).Values(pChanged.Values).Execute(pDatabase, pCommit)
		    End If
		    
		    // Update mData from mChanged
		    For Each pKey As Variant In mChanged.Keys
		      Me.mData.Value(pKey) = Me.mChanged.Value(pKey)
		    Next
		    
		    // Clear changes, they are saved in mData
		    Call Me.mChanged.Clear
		    
		    If Me.PrimaryKeys.Ubound = 0 Then // Refetching the primary key work only with a single primary key
		      
		      // Biggest primary key
		      Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		      From(Me.TableName). _
		      OrderBy(Me.PrimaryKey, "DESC"). _
		      Execute(pDatabase).Field(Me.PrimaryKey).Value
		      
		      // Best guess for SQLite
		      If pDatabase IsA SQLiteDatabase Then
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		      End If
		      
		      // Best guess for MySQL when available
		      If pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		      End If
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mRemoved.Values
		      Call pRelation.Remove(Me, pDatabase)
		    Next
		    
		    For Each pRelation As ORMRelation In mAdded.Values
		      Call pRelation.Add(Me, pDatabase)
		    Next
		    
		    // Clear pending relationships
		    mAdded.Clear
		    mRemoved.Clear
		    
		    RaiseEvent Created
		    
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
		Sub Data(pColumn As String, Assigns pValue As Variant)
		  Call Data(pColumn, pValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As String, pValue As Variant) As ORM
		  If Not RaiseEvent Changing(pColumn) Then
		    
		    // If it is different than the original data, it has changed
		    If Initial(pColumn) <> pValue Then
		      mChanged.Value(pColumn) = pValue
		    ElseIf mChanged.HasKey(pColumn) Then
		      mChanged.Remove(pColumn)
		    End If
		    
		    RaiseEvent Changed(pColumn)
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Deflate(pORM As ORM) As ORM
		  // @deprecated
		  
		  Call pORM.Inflate(Me)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(pDatabase As Database, pCommit As Boolean = True) As ORM
		  if Not Loaded() then
		    Raise new ORMException("Cannot delete " + TableName() + " model because it is not loaded.")
		  end
		  
		  If Not RaiseEvent Deleting() Then
		    
		    DB.Delete(Me.TableName).Where(Me.Pks).Execute(pDatabase, pCommit)
		    
		    // Empty mData
		    Call mData.Clear()
		    
		    // Empty mChanges
		    Call mChanged.Clear()
		    
		    // Empty pending relationships
		    Call mAdded.Clear()
		    Call mRemoved.Clear()
		    
		    RaiseEvent Deleted()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As String
		  // Dump ORM content for logs
		  Dim pDump As String = "Dumping " + QueryCompiler.Value(Me.Pk) + "@" + QueryCompiler.TableName(Me.TableName) + EndOfLine
		  
		  // If Me.Changed Then
		  Dim pChanged() As String
		  
		  For Each pKey As String In Me.Data.Keys
		    
		    pChanged.Append(QueryCompiler.Column(pKey) + ": " + QueryCompiler.Value(Me.Initial(pKey)))
		    
		    If Me.Initial(pKey) <> Me.Data(pKey) Then
		      pChanged(pChanged.Ubound) = pChanged(pChanged.Ubound) +  " => " + QueryCompiler.Value(Me.Data(pKey))
		    End If
		    
		  Next
		  
		  pDump = pDump + "Changed: " + Join(pChanged, ", ") + EndOfLine
		  
		  Dim pAdd As String
		  
		  For Each pKey As Variant In Me.Add.Keys
		    pAdd = pAdd + " " + ORMRelation(pKey).Dump
		  Next
		  
		  pDump = pDump + "Added: " + pAdd + EndOfLine
		  
		  Dim pRemove As String
		  
		  For Each pKey As Variant In Me.Remove.Keys
		    pRemove = pRemove + " " + ORMRelation(pKey).Dump
		  Next
		  
		  pDump = pDump + "Removed: " + pRemove + EndOfLine
		  
		  Return pDump
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldSchema(pDatabase As Database) As RecordSet
		  Return pDatabase.FieldSchema(Me.TableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pDatabase As Database) As ORM
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Variant
		    
		    // Prepend table to prevent collision with join
		    For Each pColumn As String In Me.TableColumns(pDatabase)
		      pColumns.Append(TableName + "." + pColumn)
		    Next
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As RecordSet = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase)
		    
		    If pRecordSet <> Nil Then
		      
		      // Fetch record set
		      For pIndex As Integer = 1 To pRecordSet.FieldCount
		        mData.Value(pRecordSet.IdxField(pIndex).Name) = pRecordSet.IdxField(pIndex).Value
		      Next
		      
		      pRecordSet.Close
		      
		    End If
		    
		    RaiseEvent Found()
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll(pDatabase As Database) As RecordSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As Variant In TableColumns(pDatabase)
		    pColumns.Append(TableName + "." + pColumn)
		  Next
		  
		  Return Append(new SelectQueryExpression(pColumns)).From(Me.TableName).Execute(pDatabase)
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
		Function Has(pForeignColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pORM.TableName)._
		  Where(pORM.Pks). _
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pPivotTableName As String, pForeignColumn As String, pDatabase As Database) As Boolean
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  // Tells if this model is in HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  AndWhere(pFarColumn, "=", pORM.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasMany(pORM As ORM, pForeignColumns() As String) As ORM
		  // pForeignColumns must be specified in the same order as PrimaryKeys
		  
		  For pIndex As Integer = 0 To Me.PrimaryKeys.Ubound
		    Call pORM.Where(pForeignColumns(pIndex), "=", Me.Pks.Value(Me.PrimaryKeys(pIndex)))
		  Next
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasMany(pORM As ORM, pForeignColumn As String) As ORM
		  Return pORM.Where(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasManyThrough(pORM As ORM, pPivotTableName As String, pForeignColumn As String, pFarColumn As String) As ORM
		  // Pk must not be compiled as a column
		  Return pORM.Join(pPivotTableName).On(pForeignColumn, "=", DB.Expression(QueryCompiler.Value(Me.Pk)))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumn As String) As ORM
		  Return HasMany(pORM, pForeignColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pCriterias As Dictionary) As ORM
		  Call Super.Having(pCriterias)
		  
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
		  // @deprecated
		  
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
		  
		  pORM.mAdded.Clear
		  
		  // Use a copy of mAdd to avoid external changes
		  For Each pKey As Variant In mAdded.Keys()
		    pORM.mAdded.Value(pKey) = mAdded.Value(pKey)
		  Next
		  
		  pORM.mRemoved.Clear
		  
		  // Use a copy of mRemove to avoid external changes
		  For Each pKey As Variant In mRemoved.Keys()
		    pORM.mRemoved.Value(pKey) = mRemoved.Value(pKey)
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
		Function LeftJoin(pTableName As String) As ORM
		  Call Super.LeftJoin(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As String, pTableAlias As String) As ORM
		  Call Super.LeftJoin(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As String) As ORM
		  Call Super.LeftOuterJoin(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As String, pTableAlias As String) As ORM
		  Call Super.LeftOuterJoin(pTableName, pTableAlias)
		  
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
		  For Each pPrimaryKey As String In Me.PrimaryKeys
		    If Me.Initial(pPrimaryKey) Is Nil Then
		      Return False
		    End If
		  Next
		  
		  Return True
		  
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
		Function Operator_Convert(pRecordSet As RecordSet) As ORM
		  Me.Constructor(pRecordSet)
		  
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
		  Return Me.Initial(Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Pk(Assigns pValue As Variant)
		  Me.Data(Me.PrimaryKey) = pValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pks() As Dictionary
		  Dim pDictionary As New Dictionary
		  
		  For Each pPrimaryKey As String In Me.PrimaryKeys
		    pDictionary.Value(pPrimaryKey) = Me.Initial(pPrimaryKey)
		  Next
		  
		  Return pDictionary
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKey() As String
		  // Retourne la colonne de la clé primaire
		  Return "id"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKeys() As String()
		  Return Array(Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKeys(pIndex As Integer) As String
		  Dim pPrimaryKeys() As String = Me.PrimaryKeys
		  
		  Return pPrimaryKeys(pIndex)
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
		  Dim pRemoved As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each pKey As Variant In mRemoved.Keys()
		    pRemoved.Value(pKey) = mRemoved.Value(pKey)
		  Next
		  
		  Return pRemoved
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pORMRelation As ORMRelation) As ORM
		  If Not RaiseEvent Removing(pORMRelation) Then
		    
		    If mAdded.HasKey(pORMRelation) Then
		      mAdded.Remove(pORMRelation)
		    Else
		      mRemoved.Value(pORMRelation) = pORMRelation
		    End If
		    
		    RaiseEvent Removed(pORMRelation)
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pForeignColumn As String, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Remove(New ORMRelationHasMany(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pForeignColumn As String, ParamArray pORMs As ORM) As ORM
		  Return Me.Remove(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pFarKeys() As Variant) As ORM
		  For Each pFarKey As Variant In pFarKeys
		    Call Remove(New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, pFarColumn, pFarKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, ParamArray pFarKeys As Variant) As ORM
		  Return Remove(pPivotTableName, pForeignColumn, pFarColumn, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveHard(pForeignColumn As String, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Remove(New ORMRelationHasManyHard(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveHard(pForeignColumn As String, ParamArray pORMs As ORM) As ORM
		  Return Me.RemoveHard(pForeignColumn, pORMs)
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
		    
		  End If
		  
		  Return Me
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
		  Dim pDictionary As New Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Call Super.Set(pDictionary)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableColumns(pDatabase As Database) As String()
		  Dim pColumns() As String
		  
		  Dim pRecordSet As RecordSet = pDatabase.FieldSchema(TableName)
		  
		  While Not pRecordSet.EOF
		    pColumns.Append(pRecordSet.Field("ColumnName").StringValue)
		    pRecordSet.MoveNext
		  WEnd
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Raise New ORMException("TableName must be implemented or be called from its implementation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unload() As ORM
		  // Empties data, not changes
		  
		  If Not RaiseEvent Unloading Then
		    
		    For Each pPrimaryKey As String In PrimaryKeys
		      If mData.HasKey(pPrimaryKey) Then
		        mData.Remove(pPrimaryKey)
		      End If
		    Next
		    
		    RaiseEvent Unloaded
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnloadAll() As ORM
		  // Empties data, not changes
		  
		  If Not RaiseEvent UnloadingAll Then
		    
		    mData.Clear
		    
		    RaiseEvent UnloadedAll
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pDatabase As Database, pCommit As Boolean = True) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Loaded() then
		    Raise new ORMException("Cannot update " + TableName() + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn) Then
		        pChanged.Value(pColumn) = mChanged.Value(pColumn)
		      End If
		    Next
		    
		    If pChanged.Count > 0 Then
		      DB.Update(TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, pCommit)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.Clear
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mRemoved.Values()
		      Call pRelation.Remove(Me, pDatabase)
		    Next
		    
		    For Each pRelation As ORMRelation In mAdded.Values()
		      Call pRelation.Add(Me, pDatabase)
		    Next
		    // Clear pending relationships
		    mAdded.Clear()
		    mRemoved.Clear()
		    
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
		  Call Super.Where(pCriterias)
		  
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

	#tag Method, Flags = &h0
		Function XMLValue(pXmlDocument As XmlDocument) As XmlNode
		  // Shallow export
		  Dim pXmlNode As XmlNode = pXmlDocument.CreateElement(Me.TableName)
		  
		  // Adds each column as an Attribute
		  For Each pColumn As String In Data.Keys
		    pXmlNode.SetAttribute(pColumn, Data(pColumn))
		  Next
		  
		  Return pXmlNode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function XMLValue(pXmlDocument As XmlDocument, pDatabase As Database) As XmlNode
		  // Deep export
		  Return Me.XMLValue(pXmlDocument)
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Added(pORMRelation As ORMRelation)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Adding(pORMRelation As ORMRelation) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Changed(pColumn As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Changing(pColumn As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Cleared()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Clearing() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Close()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Created()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event CreatePane()
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
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Removed(pORMRelation As ORMRelation)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Removing(pORMRelation As ORMRelation) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Saved()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Saving() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Unloaded()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UnloadedAll()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Unloading() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UnloadingAll() As Boolean
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
		Private mAdded As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRemoved As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Handle"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MouseX"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MouseY"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Window"
			Group="Behavior"
			InitialValue="0"
			Type="Window"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mInitialParent"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mWindow"
			Group="Behavior"
			InitialValue="0"
			Type="Window"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
