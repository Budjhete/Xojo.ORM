#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag Event
		Sub Close()
		  RaiseEvent Close
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  mChanged.Clear
		  
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
		  Return Me.Add(pPivotTableName, pForeignColumn, pFarColumn, pORMs)
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
		Function BelongsTo(pORM As ORM, pForeignKey As String) As ORM
		  // Return the related model in belongs to relationship
		  // @todo support multiple primary keys
		  
		  Return pORM.Where(pORM.PrimaryKey, "=", Me.Data(pForeignKey))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bind(pTableName As String, pForeignColumn As String) As ORM
		  // Join operation for BelongsTo related models.
		  // @todo support for multiple primary keys
		  
		  Return Me.Join(pTableName).On(pTableName + "." + pForeignColumn, "=", Me.TableName + "." + Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  'For Each pKey As String In mChanged.Keys
		  'System.DebugLog "ORM change : " + pKey
		  'Next
		  'For Each pKey As String In mAdded.Keys
		  'System.DebugLog "ORM added : " + pKey
		  'Next
		  'Try  // FIXME #8033
		  ''For Each pKey As String In mRemoved.Keys
		  ''System.DebugLog "ORM removed : " + pKey
		  ''Next
		  'Catch e As TypeMismatchException
		  'System.DebugLog "ORM removed error: " + e.Message
		  'End Try
		  
		  
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
		  
		  If Not RaiseEvent Clearing Then
		    
		    mChanged = nil
		    mChanged = new Dictionary
		    'mChanged.Clear
		    
		    mAdded = nil
		    mAdded = new Dictionary
		    'mAdded.Clear
		    
		    mRemoved = nil
		    mRemoved = new Dictionary
		    'mRemoved.Clear
		    
		    RaiseEvent Cleared
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ClearAll() As ORM
		  // Clear everything
		  
		  If Not RaiseEvent Clearing Then
		    
		    mData = nil
		    mData = new Dictionary
		    'mData.Clear
		    
		    mChanged = nil
		    mChanged = new Dictionary
		    'mChanged.Clear
		    
		    mRemoved = nil
		    mRemoved = new Dictionary
		    'mRemoved.Clear
		    
		    mAdded = nil
		    mAdded = new Dictionary
		    'mAdded.clear
		    
		    RaiseEvent Cleared
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pCriterias As Dictionary)
		  // Basic ORM constructor
		  
		  Super.Constructor
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		  
		  Call Me.Where(pCriterias)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pPks As Dictionary, pDatabase As Database)
		  // Initialize an ORM with primary keys and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(pPks)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pORM As ORM)
		  // Initialize the ORM with the primary key of another ORM
		  
		  Me.Constructor(pORM.Pks)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(ParamArray pCriterias() As Pair)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  For Each pCriteria As Pair In pCriterias
		    pDictionary.Value(pCriteria.Left) = pCriteria.Right
		  Next
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pRecordSet As RecordSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pRecordSet As RecordSet, pColumnType as Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name) )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pPk As Variant, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey: pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy() As ORM
		  // Returns a copy of this ORM
		  Dim pORM As New ORM
		  
		  // Copy the QueryBuilder
		  For Each pQueryExpression As QueryExpression In Me.mQuery
		    pORM.mQuery.Append(pQueryExpression)
		  Next
		  
		  For Each pColumn As String In mData.Keys
		    pORM.mData.Value(pColumn) = Me.mData.Value(pColumn)
		  Next
		  
		  For Each pColumn As String In mChanged.Keys
		    pORM.mChanged.Value(pColumn) = Me.mChanged.Value(pColumn)
		  Next
		  
		  For Each pKey As Variant In mAdded.Keys
		    pORM.mAdded.Value(pKey) = Me.mAdded.Value(pKey)
		  Next
		  
		  For Each pKey As Variant In mRemoved.Keys
		    pORM.mRemoved.Value(pKey) = Me.mRemoved.Value(pKey)
		  Next
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy(pORM As ORM) As ORM
		  // Returns a copy of this ORM
		  // @deprecated
		  Call pORM.Deflate(Self)
		  
		  Return pORM
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
		Function Create(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If Loaded Then
		    Raise new ORMException("Cannot create " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  System.DebugLog "ORM.create is Creating ?"
		  
		  If Not RaiseEvent Creating Then
		    'System.DebugLog "ORM.create not creating"
		    
		    pDatabase.Begin
		    System.DebugLog "ORM.create database.begin"
		    
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = Me.Data
		    System.DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    System.DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      System.DebugLog "ORM.create pColum = " + pColumn.StringValue
		      
		      If pRaw.HasKey(pColumn) Then
		        System.DebugLog "ORM.create "+pColumn.StringValue+" = " + pRaw.Value(pColumn).StringValue
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    System.DebugLog "ORM.create DB.Insert"
		    
		    DB.Insert(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Variant In mChanged.Keys()
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    'System.DebugLog "ORM.Create.mChanged about to clear : " + me.Name
		    // Clear changes, they are saved in mData
		    //Call Me.mChanged.Clear
		    me.mChanged = nil
		    me.mChanged = new Dictionary
		    
		    System.DebugLog "ORM.Create.mChanged cleared"
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.Ubound = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		      Else
		        // Biggest primary key
		        Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		        From(Me.TableName). _
		        OrderBy(Me.PrimaryKey, "DESC"). _
		        Execute(pDatabase).Field(Me.PrimaryKey).Value
		      End If
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mRemoved.Values
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each pRelation As ORMRelation In mAdded.Values
		      Call pRelation.Add(Me, pDatabase, False)
		    Next
		    
		    'System.DebugLog "ORM.Create.mAdded about to clear"
		    
		    // Clear pending relationships
		    //mAdded.Clear
		    me.mAdded = nil
		    me.mAdded = new Dictionary
		    
		    System.DebugLog "ORM.Create.mAdded cleared"
		    
		    
		    'System.DebugLog "ORM.Create.mRemoved about to clear"
		    
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    //mRemoved.Clear
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    System.DebugLog "ORM.Create.mRemoved cleared"
		    
		    
		    pDatabase.Commit
		    
		    RaiseEvent Created
		    System.DebugLog "ORM.Create Done"
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
		Function Find(pDatabase As Database, pExpiration As Date = Nil, pColumnsType() as DB.DataType = Nil) As ORM
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
		    Execute(pDatabase, pExpiration)
		    
		    dim pRecordSetType as RecordSet = pDatabase.FieldSchema(Me.TableName)
		    
		    dim pColumnType as new Dictionary
		    
		    while not pRecordSetType.EOF
		      pColumnType.Value(pRecordSetType.Field("ColumnName").StringValue) = pRecordSetType.Field("FieldType").IntegerValue
		      pRecordSetType.MoveNext
		    wend
		    // Clear any existing data
		    mData.Clear
		    
		    // Fetch record set
		    If pRecordSet.RecordCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 1 To pRecordSet.FieldCount
		        
		        Dim pColumn As String = pRecordSet.IdxField(pIndex).Name
		        
		        if pColumnType <> nil then
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pColumn))
		        else
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex)
		        end if
		        
		        // @todo check if mChanged.Clear is not more appropriate
		        If mChanged.HasKey(pColumn) And mChanged.Value(pColumn) = mData.Value(pColumn) Then
		          mChanged.Remove(pColumn)
		        End If
		        
		      Next
		      
		      pRecordSet.Close
		      
		    End If
		    
		    RaiseEvent Found
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindAll(pDatabase As Database, pExpiration As Date = Nil) As RecordSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As Variant In TableColumns(pDatabase)
		    pColumns.Append(TableName + "." + pColumn)
		  Next
		  
		  Return Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
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
		Protected Function HasMany(pORM As ORM, ParamArray pForeignColumns() As String) As ORM
		  Return Me.HasMany(pORM, pForeignColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasManyThrough(pORM As ORM, pPivotTableName As String, pForeignColumn As String, pFarColumn As String) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", Me.Pk) ._
		  AndWhere(pFarColumn, "=", pORM.Pk))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumns() As String) As ORM
		  Return HasMany(pORM, pForeignColumns())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumn As String) As ORM
		  Return HasMany(pORM, pForeignColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumn As String, pKeyIndex as integer) As ORM
		  // pForeignColumns must be specified in the same order as PrimaryKeys
		  
		  Call pORM.Where(pForeignColumn, "=", Me.Pks.Value(Me.PrimaryKeys(pKeyIndex)))
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOneThrough(pORM As ORM, pPivotTableName As String, pForeignColumn As String, pFarColumn As String) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", Me.Pk)_
		  )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOneThrough(pORM As ORM, pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pForeignValue as variant) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", pForeignValue)_
		  )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pCriterias As Dictionary) As ORM
		  Call Super.Having(pCriterias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pColumn As Variant, pOperator As String, pValue As Variant) As ORM
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
		Attributes( Deprecated )  Function Inflate(pORM As ORM) As ORM
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
		Function Join(pTableName As QueryExpression, pTableAlias As String) As ORM
		  Call Super.Join(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As string) As ORM
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
		Function JSONValue() As JSONItem
		  // Shallow export
		  
		  Dim pJSONItem As New JSONItem
		  
		  // Adds each column as an Attribute
		  For Each pColumn As String In Me.Data.Keys
		    System.DebugLog pColumn
		    dim v as Variant = Me.Data(pColumn)
		    System.DebugLog "type : " + str(v.Type)
		    if v.Type = 6 then
		      pJSONItem.Value(pColumn) = v.DoubleValue
		    else
		      pJSONItem.Value(pColumn) = v
		    end if
		    System.DebugLog pJSONItem.ToString
		  Next
		  
		  Return pJSONItem
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function JSONValue(pDatabase As Database) As JSONItem
		  // Deep export
		  
		  // You must override this method to provide a custom export for your model
		  
		  Return Me.JSONValue
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
		Function On(pColumn As Variant, pOperator As String, pValue As Variant, pType as DataType) As ORM
		  Call Super.On(pColumn, pOperator, pValue, pType)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnClose() As ORM
		  Call Super.OnClose()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnOpen() As ORM
		  Call Super.OnOpen()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(pORM As ORM) As Integer
		  // @todo implement comparison for multiple primary keys
		  
		  If pORM Is Nil Then
		    Return 1
		  End If
		  
		  If Me.TableName = pORM.TableName And Me.Pk = pORM.Pk Then
		    Return 0
		  End If
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumns() As Variant,  pDirections() As String, pComparators() as String) As ORM
		  Call Super.OrderBy(pColumns, pDirections, pComparators)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As Variant, pDirection As String = "ASC", pComparator as String = "") As ORM
		  Call Super.OrderBy(pColumn, pDirection, pComparator)
		  
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
		Function OrOn(pColumn As String, pOperator As String, pValue As Variant) As ORM
		  Call Super.OrOn(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pColumn As String, pOperator As String, pValue As Variant, pType as DataType) As ORM
		  Call Super.OrOn(pColumn, pOperator, pValue, pType)
		  
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
		Sub RaiseEventFound()
		  RaiseEvent Found
		End Sub
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
		Function Replace(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Loaded Then
		    Raise new ORMException("Cannot replace " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    pDatabase.Begin
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = Me.Data
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      If pRaw.HasKey(pColumn) Then
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    DB.Replace(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Variant In mChanged.Keys()
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear changes, they are saved in mData
		    Call Me.mChanged.Clear
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.Ubound = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		      Else
		        // Biggest primary key
		        Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		        From(Me.TableName). _
		        OrderBy(Me.PrimaryKey, "DESC"). _
		        Execute(pDatabase).Field(Me.PrimaryKey).Value
		      End If
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mRemoved.Values
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each pRelation As ORMRelation In mAdded.Values
		      Call pRelation.Add(Me, pDatabase, False)
		    Next
		    
		    // Clear pending relationships
		    mAdded.Clear
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    mRemoved.Clear
		    
		    pDatabase.Commit
		    
		    RaiseEvent Created
		    
		  End If
		  
		  Return Me
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
		    Elseif mReplaced then
		      Call Replace(pDatabase)
		    else
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
		  
		  Dim pRecordSet As RecordSet = pDatabase.FieldSchema(Me.TableName)
		  
		  If pRecordSet Is Nil Then
		    Raise New ORMException(Me.TableName + " is not an existing table.")
		  End If
		  
		  While Not pRecordSet.EOF
		    pColumns.Append(pRecordSet.Field("ColumnName").StringValue.DefineEncoding(Encodings.UTF8))
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
		  // Empties only the primary keys
		  
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
		  // Empties all data, but not changes
		  
		  If Not RaiseEvent UnloadingAll Then
		    
		    mData = nil
		    mData = new Dictionary
		    'mData.Clear
		    
		    RaiseEvent UnloadedAll
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnloadFull() As ORM
		  // Empties only the primary keys
		  
		  If Not RaiseEvent UnloadingAll Then
		    
		    For Each pPrimaryKey As String In PrimaryKeys
		      If mData.HasKey(pPrimaryKey) Then
		        mData.Remove(pPrimaryKey)
		      End If
		      If mChanged.HasKey(pPrimaryKey) then
		        mChanged.Remove(pPrimaryKey)
		      End If
		      If mRemoved.HasKey(pPrimaryKey) then
		        mRemoved.Remove(pPrimaryKey)
		      End If
		      If mAdded.HasKey(pPrimaryKey) then
		        mAdded.Remove(pPrimaryKey)
		      End If
		    Next
		    
		    mData = nil
		    mData = new Dictionary
		    'mData.Clear
		    
		    mChanged = nil
		    mChanged = new Dictionary
		    'mChanged.Clear
		    
		    mRemoved = nil
		    mRemoved = new Dictionary
		    'mRemoved.Clear
		    
		    mAdded = nil
		    mAdded = new Dictionary
		    'mAdded.clear
		    
		    RaiseEvent UnloadedAll
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    pDatabase.Begin
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn) Then
		        pChanged.Value(pColumn) = mChanged.Value(pColumn)
		      End If
		    Next
		    
		    If pChanged.Count > 0 Then
		      DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, False)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.Clear
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In mRemoved.Values()
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each pRelation As ORMRelation In mAdded.Values()
		      Call pRelation.Add(Me, pDatabase, False)
		    Next
		    
		    // Clear pending relationships
		    //mAdded.Clear()
		    mAdded = nil
		    mAdded = new Dictionary
		    
		    // AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!   // not the first time ?
		    //mRemoved.Clear()
		    mRemoved = nil
		    mRemoved = new Dictionary
		    
		    pDatabase.Commit
		    
		    RaiseEvent Updated()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateCache(pDatabase as Database, pDebut as date, pFin as Date)
		  Raise New ORMException("UpdateCache not implemented in this model")
		End Sub
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
		Function Where(pLeft As Variant, pOperator As String, pRight As Variant) As ORM
		  Call Super.Where(pLeft, pOperator, pRight)
		  
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
		  For Each pColumn As String In Me.Data.Keys
		    pXmlNode.SetAttribute(pColumn, Me.Data(pColumn))
		  Next
		  
		  Return pXmlNode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function XMLValue(pXmlDocument As XmlDocument, pDatabase As Database) As XmlNode
		  // Deep export
		  
		  // You must override this method to provide a custom export for your model
		  
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


	#tag Note, Name = Dependences
		##Include QueryBuilder
		
		For desktop use : QueryBuilder
		For Web use : /Web/QueryBuilder
		
	#tag EndNote

	#tag Note, Name = Has
		
		Ne sert qu'à vérifier les relations Has Many Through
	#tag EndNote


	#tag Property, Flags = &h0
		FinishLoaded As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mAdded As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mChanged As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mRemoved As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		mReplaced As Boolean = False
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="FinishLoaded"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
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
			Name="mReplaced"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
