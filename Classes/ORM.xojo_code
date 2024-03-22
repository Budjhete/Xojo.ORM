#tag Class
Protected Class ORM
Inherits QueryBuilder
Implements Reports.Dataset
	#tag CompatibilityFlags = ( TargetConsole and ( Target32Bit or Target64Bit ) ) or ( TargetWeb and ( Target32Bit or Target64Bit ) ) or ( TargetDesktop and ( Target32Bit or Target64Bit ) ) or ( TargetIOS and ( Target64Bit ) ) or ( TargetAndroid and ( Target64Bit ) )
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
		  
		  For Each AddedEntry As DictionaryEntry In mAdded
		    pAdded.Value(AddedEntry.Key) = AddedEntry.Value
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
		Function Append(pQueryBuilder As QueryBuilder) As ORM
		  // Append another QueryBuilder
		  Call Super.Append(pQueryBuilder.mQuery)
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Append(pQueryExpression As QueryExpression) As ORM
		  Call Super.Append(pQueryExpression)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Archive(pDatabase As Database, pCommit As Boolean = True) As ORM
		  if Not Loaded() then
		    Raise new ORMException("Cannot archive " + TableName() + " model because it is not loaded.")
		  end
		  
		  If Not RaiseEvent Updating() Then
		    pDatabase.Begin
		    
		    dim pD as new Dictionary
		    If mData.HasKey("estActif") Then
		      dim BouActive as Boolean = mData.Value("estActif").BooleanValue
		      pd.Value("estActif") = not BouActive
		    End If
		    
		    If pD.Count > 0 Then
		      DB.Update(Me.TableName).Set(pD).Where(Me.Pks).Execute(pDatabase, pCommit)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.Clear
		    
		    pDatabase.Commit
		    
		    RaiseEvent Updated()
		  End If
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
		  'For Each pKey as String In mChanged.Keys
		  'System.DebugLog "ORM change : " + pKey
		  'Next
		  'For Each pKey as String In mAdded.Keys
		  'System.DebugLog "ORM added : " + pKey
		  'Next
		  'Try  // FIXME #8033
		  ''For Each pKey as String In mRemoved.Keys
		  ''System.DebugLog "ORM removed : " + pKey
		  ''Next
		  'Catch e As TypeMismatchException
		  'System.DebugLog "ORM removed error: " + e.Message
		  'End Try
		  
		  
		  Return mChanged.KeyCount > 0 Or mAdded.KeyCount > 0 Or mRemoved.KeyCount > 0
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target64Bit))
		Sub Constructor()
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetWeb and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Sub Constructor(pRecordSet As DatabaseRow)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex-1).Name) = DB.Extract(pRecordSet, pIndex-1)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pCriterias as Dictionary, LoadFromJSON as Boolean = False)
		  // Basic ORM constructor
		  
		  Super.Constructor
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		  
		  if LoadFromJSON then
		    mData = pCriterias
		    if mData.Value(me.PrimaryKey)>0 then
		      RaiseEvent Found
		    else
		      RaiseEvent NoFound
		    end if
		  else
		    Call Me.Where(pCriterias)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pPks As Dictionary, pDatabase As Database)
		  // Initialize an ORM with primary keys and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(pPks)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPks As Dictionary, pDatabase As SQLiteDatabase)
		  // Initialize an ORM with primary keys and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(pPks)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As integer, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Dim d as new Dictionary
		  d.Value(Me.PrimaryKey) = pPk
		  Me.Constructor(d)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As integer, pDatabase As SQLiteDatabase)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pRecordSet As iOSSQLiteRecordSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = pRecordSet.IdxField(pIndex).Value //DB.Extract(pRecordSet, pIndex)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Sub Constructor(pRecordSet as iOSSQLiteRecordSet, pColumnType as Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name).IntegerValue )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pORM As ORM)
		  // Initialize the ORM with the primary key of another ORM
		  
		  Me.Constructor(pORM.Pks)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pRecordSet As RecordSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pRecordSet As RecordSet, pDB as Database)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pDB)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pRecordSet as RecordSet, pColumnType as Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name).IntegerValue )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetWeb and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Sub Constructor(pRecordSet As RowSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex-1).Name) = DB.Extract(pRecordSet, pIndex-1)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetWeb and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Sub Constructor(pRecordSet as RowSet, pDB as Database)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pDB)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target64Bit))
		Sub Constructor(pIdentificationMethod as String)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPrimaryKey as String, pKeyValue as integer)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  pDictionary.Value(pPrimaryKey) = pKeyValue
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As String, pDatabase As SQLiteDatabase)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPrimaryKey as String, pKeyValue as String)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  pDictionary.Value(pPrimaryKey) = pKeyValue
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Sub Constructor(pLeft as String, pRight as Variant)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  pDictionary.Value(pLeft) = pRight
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As Variant, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Dim d as new Dictionary
		  d.Value(Me.PrimaryKey) = pPk
		  
		  Me.Constructor(d)
		  
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
		  
		  For Each entry As DictionaryEntry In mData
		    pORM.mData.Value(entry.Key) = entry.Value
		  Next
		  
		  For Each ChangeEntry As DictionaryEntry In mChanged
		    pORM.mChanged.Value(ChangeEntry.key) = ChangeEntry.Value
		  Next
		  
		  For Each AddedEntry As DictionaryEntry In mAdded
		    pORM.mAdded.Value(AddedEntry.key) = AddedEntry.Value
		  Next
		  
		  For Each RemovedEntry As DictionaryEntry In mRemoved
		    pORM.mRemoved.Value(RemovedEntry.key) = RemovedEntry.Value
		  Next
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Copy(cORM as ORM)
		  // Copy the QueryBuilder
		  For Each pQueryExpression As QueryExpression In cORM.mQuery
		    me.mQuery.Append(pQueryExpression)
		  Next
		  
		  For Each pDataEntry As DictionaryEntry In cORM.mData
		    me.mData.Value(pDataEntry.Key) = pDataEntry.Value
		  Next
		  
		  For Each pColumnEntry As DictionaryEntry In cORM.mChanged
		    me.mChanged.Value(pColumnEntry.Key) = pColumnEntry.Value
		  Next
		  
		  For Each pAddedEntry As DictionaryEntry In cORM.mAdded
		    me.mAdded.Value(pAddedEntry.Key) = pAddedEntry.Value
		  Next
		  
		  For Each pRemovedEntry As DictionaryEntry In cORM.mRemoved
		    me.mRemoved.Value(pRemovedEntry.Key) = pRemovedEntry.Value
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function CountAll(pDatabase As Database) As Integer
		  Dim pColumns() As Variant
		  pColumns.Append(DB.Expression("COUNT(*) AS count"))
		  
		  Return Append(New SelectQueryExpression(pColumns)).From(TableName).Execute(pDatabase).Field("count").IntegerValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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
		    'System.DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    'System.DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase).Keys
		      System.DebugLog "ORM.create pColum = " + pColumn.StringValue
		      
		      If pRaw.HasKey(pColumn) Then
		        System.DebugLog "ORM.create "+pColumn.StringValue+" = " + pRaw.Value(pColumn.StringValue)
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    'System.DebugLog "ORM.create DB.Insert"
		    
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
		    
		    'System.DebugLog "ORM.Create.mChanged cleared"
		    
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
		    
		    'System.DebugLog "ORM.Create.mAdded cleared"
		    
		    
		    'System.DebugLog "ORM.Create.mRemoved about to clear"
		    
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    //mRemoved.Clear
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    'System.DebugLog "ORM.Create.mRemoved cleared"
		    
		    
		    pDatabase.Commit
		    
		    RaiseEvent Created
		    System.DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target64Bit)) or  (TargetDesktop and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Function Create(pConnexion As KanjoSocket) As Boolean
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If me.Loaded Then
		    Raise new ORMException("Cannot create " + me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = me.Data
		    
		    // pData contains at least all primary keys
		    'Dim pData As Dictionary = me.Pks
		    '
		    '// Take only columns defined in the model
		    'For Each pColumn As DictionaryEntry In me.ColumnsList
		    '
		    'If pRaw.HasKey(pColumn.Key) Then
		    'pData.Value(pColumn.Key) = pRaw.Value(pColumn.Key)
		    'End If
		    'Next
		    
		    if pRaw.KeyCount >0 then
		      'pConnexion.BodyRequest = GenerateJSON(pRaw)
		      'pConnexion.SendMessage(pConnexion.HeaderRequest(pConnexion.PUT, pConnexion.mURL))
		      'pConnexion.BodyRequest = ""
		    End If
		    
		    
		    'System.DebugLog "ORM.Create.mChanged about to clear : " + me.Name
		    // Clear changes, they are saved in mData
		    //Call Me.mChanged.Clear
		    me.mChanged = nil
		    me.mChanged = new Dictionary
		    
		    'todo: check if the primary key is auto increment
		    'If pORM.PrimaryKeys.Ubound = 0 Then // Refetching the primary key work only with a single primary key
		    '
		    '// Biggest primary key
		    'pORM.mData.Value(pORM.PrimaryKey) = DB.Find(pORM.PrimaryKey). _
		    'From(pORM.TableName). _
		    'OrderBy(pORM.PrimaryKey, "DESC"). _
		    'Execute(pDatabase).Field(pORM.PrimaryKey).Value
		    '
		    'End If
		    
		    // Execute pendings relationships
		    For Each pRelation As ORMRelation In me.mRemoved.Values
		      Call pRelation.Remove(me, pConnexion)
		    Next
		    
		    For Each pRelation As ORMRelation In me.mAdded.Values
		      Call pRelation.Add(me, pConnexion)
		    Next
		    
		    // Clear pending relationships
		    //mAdded.Clear
		    me.mAdded = nil
		    me.mAdded = new Dictionary
		    
		    
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    //mRemoved.Clear
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    RaiseEvent Created
		  End If
		  
		  'Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Create(pDatabase As SQLiteDatabase) As ORM
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
		    For Each pColumn As String In Me.TableColumns(pDatabase)
		      System.DebugLog "ORM.create pColum = " + pColumn
		      
		      If pRaw.HasKey(pColumn) Then
		        System.DebugLog "ORM.create "+pColumn+" = " + pRaw.Value(pColumn)
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
		      
		      
		      // Biggest primary key
		      Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		      From(Me.TableName). _
		      OrderBy(Me.PrimaryKey, "DESC"). _
		      Execute(pDatabase).Column(Me.PrimaryKey).Value
		      
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
		    
		    
		    pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    System.DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function CreateTable(pDatabase as Database, pSuffix as String = "") As Boolean
		  if pDatabase isa MySQLCommunityServer then
		    'Try
		    Dim sql As String
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    dim HasKeys as Boolean = false
		    Dim mPrimaryKeys as String = "PRIMARY KEY ("
		    Dim mUniqueKeys as String = "UNIQUE ("
		    'dim mKeys as string = 
		    sql = "CREATE TABLE `"+me.TableName+pSuffix+"` ( "
		    for each dField as DictionaryEntry in Schema
		      dim field as ORMField = dField.Value
		      sql = sql + EndOfLine + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase) +field.Length
		      sql = sql + " " + field.NotNull
		      if field.Type(pDatabase) <> "DECIMAL" then sql = sql + " " + field.DefaultValue(pDatabase)
		      sql = sql + " " + field.Extra(pDatabase)
		      sql = sql + ","
		      if field.PrimaryKey then
		        HasPrimaryKeys = HasPrimaryKeys OR true
		        mPrimaryKeys  = mPrimaryKeys + "`"+dField.key+"`"+ ","
		      end if
		      
		      if field.Unique then
		        HasUniqueKeys = HasUniqueKeys OR true
		        mUniqueKeys  = mUniqueKeys + "`"+dField.key+"`"+ ","
		      end if
		      
		      
		      
		    next
		    sql = sql.left(sql.Length -1)
		    if HasPrimaryKeys then sql = sql + ", "+EndOfLine +mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ")"
		    if HasUniqueKeys then sql = sql + ", "+EndOfLine +mUniqueKeys.Left(mUniqueKeys.Length - 1) + ")"
		    
		    sql = sql +");"
		    try
		      pDatabase.ExecuteSQL(sql)
		      
		    Catch error As DatabaseException
		      System.DebugLog "Database error: " + error.Message
		      Return false
		    End Try
		    Return true
		  else
		    
		    Dim sql As String
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    dim CanHavePrimaryKeys as Boolean = true
		    Dim mPrimaryKeys as String = "PRIMARY KEY ("
		    Dim mUniqueKeys as String = "UNIQUE ("
		    
		    sql = "CREATE TABLE `"+me.TableName+pSuffix+"` ( "
		    
		    for each dField as DictionaryEntry in Schema
		      dim field as ORMField = dField.Value
		      sql = sql + EndOfLine + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase)
		      if field.Type(pDatabase) = "DECIMAL" then
		        sql = sql +field.Length
		      end if
		      sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		      
		      
		      if field.Extra = ORMField.ExtraList.AutoIncremente then 
		        if field.PrimaryKey then sql = sql + " PRIMARY KEY AUTOINCREMENT"
		        CanHavePrimaryKeys = false
		      end if
		      
		      if field.PrimaryKey then
		        HasPrimaryKeys = HasPrimaryKeys OR true
		        mPrimaryKeys  = mPrimaryKeys + "`"+dField.key+"`"+ ","
		      end if
		      
		      sql = sql + " " + field.Extra(pDatabase)
		      sql = sql + ","
		      
		      
		      if field.Unique then
		        HasUniqueKeys = HasUniqueKeys OR true
		        mUniqueKeys  = mUniqueKeys + "`"+dField.key+"`"+ ","
		      end if
		      
		      
		      
		      
		    next
		    
		    sql = sql.left(sql.Length -1)
		    if HasPrimaryKeys and CanHavePrimaryKeys then sql = sql + ", "+EndOfLine +mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ")"
		    if HasUniqueKeys then sql = sql + ", "+EndOfLine +mUniqueKeys.Left(mUniqueKeys.Length - 1) + ")"
		    
		    sql = sql +");"
		    Try
		      pDatabase.ExecuteSQL(sql)
		      
		    Catch error As DatabaseException
		      System.DebugLog "Database error: " + error.Message
		      Return false
		    End Try
		    Return true
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Data() As Dictionary
		  Dim pData As Dictionary = Initial()
		  
		  // Merge mChanged over mData
		  
		  For Each ChangedEntry As DictionaryEntry In mChanged
		    pData.Value(ChangedEntry.Key) = ChangedEntry.Value
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pData as Dictionary) As ORM
		  For Each pDataEntry As DictionaryEntry In pData
		    Call Data(pDataEntry.Key, pDataEntry.Value)
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
		    if ParentORM<>nil then
		      ParentORM.RaiseChange
		    End If
		    
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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
		  
		  Dim pDump As string = "Dumping " + QueryCompiler.Value(Me.Pk) + "@" + QueryCompiler.TableName(Me.TableName)
		  
		  // If Me.Changed Then
		  Dim pChanged() As string
		  
		  For Each DataEntry As DictionaryEntry In Me.Data
		    
		    pChanged.Append(QueryCompiler.Column(DataEntry.Key) + ": " + QueryCompiler.Value(Me.Initial(DataEntry.Key)))
		    
		    If Me.Initial(DataEntry.Key.StringValue) <> Me.Data(DataEntry.Key.StringValue) Then
		      pChanged(pChanged.Ubound) = pChanged(pChanged.Ubound) +  " => " + QueryCompiler.Value(Me.Data(DataEntry.Key.StringValue))
		    End If
		    
		  Next
		  
		  pDump = pDump + "Changed: " + String.FromArray(pChanged, ", ") + EndOfLine
		  
		  Dim pAdd As String
		  
		  For Each AddEntry As DictionaryEntry In Me.Add
		    pAdd = pAdd + " " + ORMRelation(AddEntry.key).Dump
		  Next
		  
		  pDump = pDump + "Added: " + pAdd + EndOfLine
		  
		  Dim pRemove As String
		  
		  For Each RemoveEntry As DictionaryEntry In Me.Remove
		    pRemove = pRemove + " " + ORMRelation(RemoveEntry.Key).Dump
		  Next
		  
		  pDump = pDump + "Removed: " + pRemove + EndOfLine
		  
		  Return pDump
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EOF() As Boolean
		  // Part of the Reports.Dataset interface.
		  
		  If mRow > 0Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Field(idx As Integer) As Variant
		  // Part of the Reports.Dataset interface.
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Field(name As String) As Variant
		  // Part of the Reports.Dataset interface.
		  
		  Return me.Data(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldExtra(pValue as String) As ORMField.ExtraList
		  
		  if pValue.Contains("auto_increment") then
		    Return ORMField.ExtraList.AutoIncremente
		  else
		    Return ORMField.ExtraList.None
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldLength(pValue as String) As String
		  if pValue.Contains("(") then
		    dim debut, fin as integer
		    debut = pValue.IndexOf("(")
		    dim newValue as String = pValue.Middle(debut+1).DefineEncoding(Encodings.UTF8)
		    fin = newValue.IndexOf(")")
		    dim finalvalue as String = newValue.left(fin)
		    
		    return finalvalue
		  else
		    return ""
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FieldSchema(pDatabase As Database) As RecordSet
		  Return pDatabase.FieldSchema(Me.TableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldType(pValue as Integer) As ORMField.TypeList
		  Select Case pValue
		    
		    'case 0 //null
		    'Return NIL
		  case 1
		    Return ORMField.TypeList.BOOLEAN
		  case 2
		    Return ORMField.TypeList.INTEGER
		  case 3
		    Return ORMField.TypeList.INTEGER
		  case 4
		    Return ORMField.TypeList.TEXT
		  case 5
		    Return ORMField.TypeList.TEXT
		  case 6
		    Return ORMField.TypeList.DECIMAL
		  case 7
		    Return ORMField.TypeList.DECIMAL
		  case 8 //DATE
		    Return ORMField.TypeList.DATETIME
		  case 9 // TIME
		    Return ORMField.TypeList.DATETIME
		  case 10
		    Return ORMField.TypeList.TIMESTAMP
		  case 11
		    Return ORMField.TypeList.DECIMAL
		  case 12
		    Return ORMField.TypeList.BOOLEAN
		  case 13
		    Return ORMField.TypeList.DECIMAL
		  case 14
		    Return ORMField.TypeList.BLOB
		  case 15
		    Return ORMField.TypeList.BLOB
		  case 16
		    Return ORMField.TypeList.BLOB
		  case 17
		    Return ORMField.TypeList.BLOB
		  case 18
		    Return ORMField.TypeList.TEXT
		  case 19
		    Return ORMField.TypeList.INTEGER
		  case 255  // unknown
		    Return ORMField.TypeList.TEXT
		  else
		    Return ORMField.TypeList.TEXT
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldType(pValue as String) As ORMField.TypeList
		  
		  if pValue.Contains("tinyint") then
		    Return ORMField.TypeList.BOOLEAN
		  elseif pValue.Contains("varchar") then
		    Return ORMField.TypeList.VARCHAR
		  elseif pValue.Contains("smallint") then
		    Return ORMField.TypeList.SMALLINT
		  elseif pValue.Contains("int") then
		    Return ORMField.TypeList.INTEGER
		  elseif pValue.Contains("decimal") then
		    Return ORMField.TypeList.DECIMAL
		  elseif pValue.Contains("char") then
		    Return ORMField.TypeList.VARCHAR
		  elseif pValue.Contains("longblob") then
		    Return ORMField.TypeList.LONGBLOB
		  elseif pValue.Contains("blob") then
		    Return ORMField.TypeList.BLOB
		  elseif pValue.Contains("longblob") then
		    Return ORMField.TypeList.LONGBLOB
		  elseif pValue.Contains("timestamp") then
		    Return ORMField.TypeList.TIMESTAMP
		  elseif pValue.Contains("datetime") then
		    Return ORMField.TypeList.DATETIME
		  elseif pValue.Contains("date") then
		    Return ORMField.TypeList.DATE
		  elseif pValue.Contains("String") then
		    Return ORMField.TypeList.TEXT
		  elseif pValue.Contains("text") then
		    Return ORMField.TypeList.TEXT
		  elseif pValue.Contains("longtext") then
		    Return ORMField.TypeList.LongTEXT
		  else
		    Return ORMField.TypeList.VARCHAR
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target64Bit))
		Function Find(pDatabase as Database, pExpiration as DateTime = Nil, pColumnsType() as DB.DataType = Nil, pFiringFoundEvent as Boolean = True) As ORM
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Variant
		    
		    // Prepend table to prevent collision with join
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      pColumns.Append(TableName + "." + pColumn)
		    Next
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As Rowset = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase)
		    
		    dim pRecordSetType as RowSet = pDatabase.TableColumns(Me.TableName)
		    
		    dim pColumnType as new Dictionary
		    
		    while not pRecordSetType.AfterLastRow
		      pColumnType.Value(pRecordSetType.Column("ColumnName").StringValue) = pRecordSetType.Column("FieldType").IntegerValue
		      pRecordSetType.MoveToNextRow
		    wend
		    // Clear any existing data
		    mData.Clear
		    
		    // Fetch record set
		    If pRecordSet.RowCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 1 To pRecordSet.ColumnCount
		        
		        Dim pColumn As String = pRecordSet.ColumnAt(pIndex).Name
		        
		        if pColumnType <> nil then
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase) //DB.Extract(pRecordSet, pIndex, pColumnType.Value(pColumn).IntegerValue)
		        else
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase)
		        end if
		        
		        // @todo check if mChanged.Clear is not more appropriate
		        If mChanged.HasKey(pColumn) And mChanged.Value(pColumn) = mData.Value(pColumn) Then
		          mChanged.Remove(pColumn)
		        End If
		        
		      Next
		      
		      pRecordSet.Close
		      
		      RaiseEvent Found
		      
		    else
		      
		      RaiseEvent NoFound
		    End If
		    
		    
		    
		  End If
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Find(pDatabase as Database, pExpiration as DateTime = Nil, pColumnsType() as DB.DataType = Nil, pFiringFoundEvent as Boolean = True) As ORM
		  
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Variant
		    
		    // Prepend table to prevent collision with join
		    dim pColumnType as Dictionary = Me.TableColumns(pDatabase)
		    For Each pColumn As Variant In pColumnType.Keys
		      pColumns.Append(TableName + "." + pColumn.StringValue)
		    Next
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As RecordSet = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase, pExpiration)
		    
		    
		    // Clear any existing data
		    mData.Clear
		    
		    // Fetch record set
		    If pRecordSet.RecordCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 1 To pRecordSet.FieldCount
		        
		        Dim pColumn As String = pRecordSet.IdxField(pIndex).Name.DefineEncoding(Encodings.UTF8)
		        
		        if pColumnType <> nil then
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pColumn).IntegerValue)
		        else
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase)
		        end if
		        
		        // @todo check if mChanged.Clear is not more appropriate
		        If mChanged.HasKey(pColumn) And mChanged.Value(pColumn) = mData.Value(pColumn) Then
		          mChanged.Remove(pColumn)
		        End If
		        
		      Next
		      
		      pRecordSet.Close
		      
		      if pFiringFoundEvent then RaiseEvent Found
		      
		    else
		      // clear existing data
		      call me.Unload.Clear
		      
		      if pFiringFoundEvent then RaiseEvent NoFound
		      
		    End If
		    
		    
		    
		  End If
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function FindAll(pDatabase As Database, pExpiration As DateTime = Nil) As RowSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As Variant In TableColumns(pDatabase)
		    pColumns.Append(TableName + "." + pColumn)
		  Next
		  
		  Dim RR as RowSet = Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		  
		  return RR
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FindAll(pDatabase as Database, pExpiration as DateTime = Nil, pOtherColumn() as Variant = nil) As RecordSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As Variant In TableColumns(pDatabase).Keys
		    pColumns.Append(TableName + "." + pColumn.StringValue)
		  Next
		  
		  For Each nColumn as Variant in pOtherColumn
		    pColumns.Append(nColumn)
		  Next
		  
		  dim RR as recordSet = Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		  
		  Return rr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FindAll(pDatabase as Database, pOtherColumn() as Variant) As RecordSet
		  Dim pColumns() As Variant
		  
		  pColumns.Append(TableName + "." + PrimaryKey)
		  
		  For Each nColumn as Variant in pOtherColumn
		    pColumns.Append(nColumn)
		  Next
		  
		  Dim rr as RecordSet = Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase)
		  
		  return rr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FindFull(pDatabase As Database) As ORM
		  return self.Find(pDatabase)
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pForeignColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pORM.TableName)._
		  Where(pORM.Pks). _
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pPivotTableName As String, pForeignColumn As String) As QueryBuilder
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pPivotTableName As String, pForeignColumn As String, pDatabase As Database) As Boolean
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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
		Protected Function HasMany(pORM As ORM, ParamArray pForeignColumns() As String) As ORM
		  Return Me.HasMany(pORM, pForeignColumns)
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
		Protected Function HasOne(pORM as ORM, pForeignColumn as String, pKeyIndex as integer) As ORM
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
		Protected Function HasOneThrough(pORM as ORM, pPivotTableName as String, pForeignColumn as String, pFarColumn as String, pForeignValue as Variant) As ORM
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
		  For Each DataEntry As DictionaryEntry In mData
		    pORM.mData.Value(DataEntry.Key) = DataEntry.Value
		  Next
		  
		  // Clear mChanged
		  pORM.mChanged.Clear()
		  
		  // Use a copy of mChanged to avoid external changes
		  For Each ChangedEntry As DictionaryEntry In mChanged
		    pORM.mChanged.Value(ChangedEntry.Key) = ChangedEntry.Value
		  Next
		  
		  pORM.mAdded.Clear
		  
		  // Use a copy of mAdd to avoid external changes
		  For Each AddedEntry As DictionaryEntry In mAdded
		    pORM.mAdded.Value(AddedEntry.Key) = AddedEntry.Value
		  Next
		  
		  pORM.mRemoved.Clear
		  
		  // Use a copy of mRemove to avoid external changes
		  For Each RemovedEntry As DictionaryEntry In mRemoved
		    pORM.mRemoved.Value(RemovedEntry.Key) = RemovedEntry.Value
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial() As Dictionary
		  Dim pData As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each DataEntry As DictionaryEntry In mData
		    pData.Value(DataEntry.Key) = DataEntry.Value
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial(pColumn As String) As Variant
		  Return mData.Lookup(pColumn, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub InsertBaseData(pDatabase as Database)
		  #Pragma BreakOnExceptions False
		  
		  dim rCol as string
		  for each cCol as DictionaryEntry in Schema
		    rCol = rCol + "`"+cCol.Key+ "`, "
		  next
		  rcol = rCol.left(rcol.Length -2)
		  
		  for i as integer = 0 to SchemaMadantoryData.LastRowIndex
		    dim strrr() as String = SchemaMadantoryData(i)
		    
		    dim sql as string = "INSERT INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    
		    for each st as string in strrr
		      if st="NULL" or st = "CURRENT_TIMESTAMP" then
		        sql = sql +""+st+", "
		      else
		        sql = sql +"'"+st+"', "
		      end if
		    next
		    sql = sql.Left(sql.Length-2) + ");"
		    try
		      pDatabase.ExecuteSQL(sql)
		    catch Err as DatabaseException
		      System.DebugLog me.TableName + "- " + sql + " : " + err.Reason
		    end try
		  next
		  
		  
		  for i as integer = 0 to SchemaDefaultDatas.LastRowIndex
		    dim strrr() as String = SchemaDefaultDatas(i)
		    
		    dim sql as string = "INSERT INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    
		    for each st as string in strrr
		      if st="NULL" or st = "CURRENT_TIMESTAMP" then
		        sql = sql +""+st+", "
		      else
		        sql = sql +"'"+st+"', "
		      end if
		    next
		    sql = sql.Left(sql.Length-2) + ");"
		    try
		      pDatabase.ExecuteSQL(sql)
		    catch Err as DatabaseException
		      System.DebugLog me.TableName + "- " + sql + " : " + err.Reason
		    end try
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As QueryExpression, pTableAlias As String) As ORM
		  Call Super.Join(pTableName, pTableAlias)
		  
		  Return Me
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
		Function JSONValue() As Dictionary
		  // Shallow export
		  
		  Dim pJSONItem As New Dictionary
		  
		  // Adds each column as an Attribute
		  For Each pColumn As String In Me.Data.Keys
		    if pColumn = "logo" then
		      System.DebugLog "logo"
		    end if
		    'System.DebugLog pColumn
		    dim v as Variant = Me.Data(pColumn.DefineEncoding(Encodings.UTF8))
		    'System.DebugLog "type : " + v.TypeText.ToString
		    Select Case v.Type
		    case 6
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8)) = v.DoubleValue
		    case 8, 37
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8)) = v.StringValue
		    else
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8)) = v
		    End Select
		    'System.DebugLog pJSONItem.ToText
		  Next
		  
		  Return pJSONItem
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Function JSONValue(pDatabase As Database) As Dictionary
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
		    If Me.Initial(pPrimaryKey) = Nil Then
		      Return False
		    End If
		  Next
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub LoadJSON(pCriterias as Dictionary)
		  // use it to bypass database search
		  // not swetable to manage changes
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		  
		  mData = pCriterias
		  if mData.Lookup(me.PrimaryKey, 0)>0 then
		    RaiseEvent Found
		  else
		    RaiseEvent NoFound
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NextRecord() As Boolean
		  // Part of the Reports.Dataset interface.
		  
		  mRow = mRow + 1
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
		Function On(pColumn as Variant, pOperator as String, pValue as Variant, pType as DataType) As ORM
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
		Function OrderBy(pColumns() as Variant, pDirections() as String, pComparators() as String) As ORM
		  Call Super.OrderBy(pColumns, pDirections, pComparators)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn as Variant, pDirection as String = "ASC", pComparator as String = "") As ORM
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
		Function OrOn(pColumn as String, pOperator as String, pValue as Variant, pType as DataType) As ORM
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
		Function OrWhereOpen() As ORM
		  // Calling the overridden superclass method.
		  Call Super.OrWhereOpen()
		  
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
		Sub RaiseChange()
		  RaiseEvent Changed(PrimaryKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RaiseEventFound()
		  if me.Loaded Then
		    RaiseEvent Found
		  else
		    RaiseEvent NoFound
		  end if
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
		  For Each RemovedEntry As DictionaryEntry In mRemoved
		    pRemoved.Value(RemovedEntry.Key) = RemovedEntry.Value
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
		  // EXEMPLE : 
		  //Call MainORM.Remove("SecondTableNameToRemoveDataFrom", "PKColumn1RelativeToMainORMPK", "PKColumn2RelativeToRelativeORM", LoadedRelativeORM)
		  
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target64Bit)) or  (TargetDesktop and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Function Replace(pConnexion As KanjoSocket) As Boolean
		  '// Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  '
		  'If Loaded Then
		  'Raise new ORMException("Cannot replace " + Me.TableName + " model because it is already loaded.")
		  'End
		  '
		  'If Not RaiseEvent Creating Then
		  '
		  'pDatabase.Begin
		  '
		  '// Take a merge of mData and mChanged
		  'Dim pRaw As Dictionary = Me.Data
		  '
		  '// pData contains at least all primary keys
		  'Dim pData As Dictionary = Me.Pks
		  '
		  '// Take only columns defined in the model
		  'For Each pColumn As Variant In Me.TableColumns(pDatabase)
		  'If pRaw.HasKey(pColumn) Then
		  'pData.Value(pColumn) = pRaw.Value(pColumn)
		  'End If
		  'Next
		  '
		  'DB.Replace(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		  '
		  '// Merge mChanged into mData
		  'For Each pKey As Variant In mChanged.Keys()
		  'mData.Value(pKey) = mChanged.Value(pKey)
		  'Next
		  '
		  '// Clear changes, they are saved in mData
		  'Call Me.mChanged.Clear
		  '
		  '// todo: check if the primary key is auto increment
		  'If Me.PrimaryKeys.Ubound = 0 Then // Refetching the primary key work only with a single primary key
		  '// Biggest primary key
		  'Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		  'From(Me.TableName). _
		  'OrderBy(Me.PrimaryKey, "DESC"). _
		  'Execute(pDatabase).Field(Me.PrimaryKey).Value
		  '
		  'End If
		  '
		  '// Execute pendings relationships
		  'For Each dRelation As DictionaryEntry In mRemoved
		  'Dim pRelation as ORMRelation = dRelation.value
		  'Call pRelation.Remove(Me, pDatabase, False)
		  'Next
		  '
		  'For Each dRelation as DictionaryEntry In mAdded
		  'dim pRelation As ORMRelation = dRelation.Value
		  'Call pRelation.Add(Me, pDatabase, False)
		  'Next
		  '
		  '// Clear pending relationships
		  'mAdded.Clear
		  '// FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		  'mRemoved.Clear
		  '
		  'pDatabase.Commit
		  '
		  'RaiseEvent Created
		  '
		  'End If
		  '
		  'Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Replace(pDatabase As SQLiteDatabase) As ORM
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
		      // Biggest primary key
		      Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		      From(Me.TableName). _
		      OrderBy(Me.PrimaryKey, "DESC"). _
		      Execute(pDatabase).Column(Me.PrimaryKey).Value
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each dRelation As DictionaryEntry In mRemoved
		      Dim pRelation as ORMRelation = dRelation.value
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each dRelation as DictionaryEntry In mAdded
		      dim pRelation As ORMRelation = dRelation.Value
		      Call pRelation.Add(Me, pDatabase, False)
		    Next
		    
		    // Clear pending relationships
		    mAdded.Clear
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    mRemoved.Clear
		    
		    pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As ORM
		  mChanged.Clear
		  mAdded.Clear
		  mRemoved.Clear
		  
		  Call Super.Reset()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Run()
		  // Part of the Reports.Dataset interface.
		  
		  mRow = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target64Bit)) or  (TargetDesktop and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Function Save(pConnexion As KanjoSocket) As Boolean
		  dim bSaved as boolean = false
		  If Not RaiseEvent Saving Then
		    
		    If Loaded() Then
		      bSaved = Update(pConnexion)
		    Elseif mReplaced then
		      bSaved = Replace(pConnexion)
		    else
		      bSaved = Create(pConnexion)
		    End
		    
		    RaiseEvent Saved
		    Return bSaved
		  End If
		  Return bSaved
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Save(pDatabase As SQLiteDatabase) As ORM
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Set(ParamArray pValues As Pair) As ORM
		  
		  
		  Dim pDictionary As New Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Call Super.Set(pDictionary)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function TableCheck(pDatabase as Database) As Boolean
		  #Pragma BreakOnExceptions False
		  
		  dim rows as RowSet 
		  SchemaCurrent = new Dictionary
		  
		  if (pDatabase isa MySQLCommunityServer) then
		    try
		      rows = pDatabase.SelectSQL("DESCRIBE "+ TableName+";")
		    Catch e as DatabaseException
		      System.DebugLog "Db " + TableName + " not exist"
		      SchemaToCreateTable = true
		    end try
		    dim rowsU as rowset = pDatabase.SelectSQL("select stat.column_name from information_schema.statistics stat join information_schema.table_constraints tco on stat.table_schema = tco.table_schema and"+_
		    " stat.table_name = tco.table_name and stat.index_name = tco.constraint_name where stat.non_unique = 0 and stat.table_schema not in ('information_schema', 'sys', 'performance_schema', 'mysql') and constraint_type = 'UNIQUE' and stat.table_name = '"+TableName+"' group by stat.table_name, stat.column_name")
		    dim dU as new Dictionary
		    if rowsU <> Nil then
		      if rowsU.RowCount>0 then
		        For Each rowU As DatabaseRow In rowsU
		          dU.Value( rowU.Column("column_name").StringValue) = true
		        Next
		      end if
		    end if
		    
		    If rows <> Nil Then
		      if rows.RowCount>0 then
		        For Each row As DatabaseRow In rows
		          dim col as new ORMField
		          col.Type = FieldType(row.Column("Type").StringValue)
		          col.PrimaryKey = row.Column("Key").StringValue = "PRI"
		          col.NotNull = row.Column("Null").StringValue = "NO"
		          col.Length = FieldLength(row.Column("Type").StringValue)
		          col.DefaultValue = row.Column("Default").StringValue.DefineEncoding(Encodings.UTF8)
		          col.Extra = FieldExtra(row.Column("Extra").StringValue)
		          col.Unique = dU.Lookup(row.Column("Field").StringValue, false)
		          SchemaCurrent.value(row.Column("Field").StringValue) = col
		        Next
		        rows.Close
		      else
		        SchemaToCreateTable = true
		      End If
		    End If
		  else
		    // Get table columns
		    rows = pDatabase.TableColumns(TableName)
		    // Gest Table keys
		    dim rowsU as rowset = pDatabase.SelectSQL("PRAGMA index_list("+TableName+");")
		    dim dU as new Dictionary
		    if rowsU <> Nil then
		      if rowsU.RowCount>0 then
		        For Each rowU As DatabaseRow In rowsU
		          if rowU.Column("origin").StringValue = "u" then
		            dim rowsUCol as rowset = pDatabase.SelectSQL("PRAGMA index_info("+rowU.Column("name").StringValue+");")
		            if rowsUCol <> Nil then
		              if rowsUCol.RowCount>0 then
		                For Each rowUCol As DatabaseRow In rowsUCol
		                  dU.Value( rowUCol.Column("name").StringValue) = true
		                Next
		              end if
		            end if
		          end if
		        Next
		      end if
		    end if
		    
		    If rows <> Nil Then
		      if rows.RowCount>0 then
		        For Each row As DatabaseRow In rows
		          dim col as new ORMField
		          col.Type = FieldType(row.Column("FieldType").IntegerValue)
		          col.PrimaryKey = row.Column("IsPrimary").BooleanValue
		          col.NotNull = row.Column("NotNull").BooleanValue
		          col.DefaultValue = row.Column("Length").StringValue.DefineEncoding(Encodings.UTF8)
		          col.Unique = dU.Lookup(row.Column("ColumnName").StringValue, false)
		          SchemaCurrent.value(row.Column("ColumnName").StringValue) = col
		          
		        Next
		        rows.Close
		      else
		        SchemaToCreateTable = true
		      End If
		    End If
		  end if
		  
		  
		  
		  SchemaToAdd = new Dictionary
		  SchemaToAlter = new Dictionary
		  
		  for each dField as DictionaryEntry in Schema
		    if NOT SchemaCurrent.HasKey(dField.key) then
		      SchemaToAdd.value(dField.key) = dField.Value
		    else
		      dim cCurrent as ORMField = SchemaCurrent.value(dField.Key)
		      dim cReal as ORMField = dField.Value
		      
		      if cCurrent.Type(pDatabase)<>cReal.type(pDatabase) or cCurrent.Unique<>cReal.Unique or cCurrent.PrimaryKey<>cReal.PrimaryKey or cCurrent.NotNull<>cReal.NotNull  then
		        SchemaToAlter.Value(dField.Key) = cReal
		      end if
		    end if
		  next
		  
		  SchemaToRemoveColumn = new Dictionary
		  
		  for each dField as DictionaryEntry in SchemaCurrent
		    if NOT Schema.HasKey(dField.key) then
		      SchemaToRemoveColumn.value(dField.key) = dField.Value
		    end if
		  next
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetDesktop and (Target64Bit))
		Function TableColumns() As Dictionary
		  Dim pColumns() As String
		  
		  'BuildSchema()
		  
		  for each entr as DictionaryEntry in me.Schema
		    pColumns.Append(entr.Key.StringValue)
		  next
		  
		  Return me.Schema
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableColumns(pDatabase As Database) As Dictionary
		  if db.DatabaseSchemaCache.Lookup(me.TableName, nil)<>nil then Return db.DatabaseSchemaCache.Value(me.TableName)
		  
		  Dim pColumns As new Dictionary
		  Try
		    Dim pRecordSet As RowSet = pDatabase.TableColumns(Me.TableName)
		    
		    For Each c As DatabaseRow In pRecordSet
		      'If c.ColumnAt(0).StringValue = "" Then 
		      'System.DebugLog "Iterator has a BUG!"
		      'Exit
		      'End
		      pColumns.Value(c.Column("ColumnName").StringValue) = c.Column("FieldType").IntegerValue
		    Next
		    db.DatabaseSchemaCache.Value(me.TableName) = pColumns
		    Return pColumns
		    
		  Catch error As DatabaseException
		    Raise New ORMException(Me.TableName + " is not an existing table.")
		    
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Function TableColumns(pDatabase As SQLiteDatabase) As String()
		  Dim pColumns() As String
		  
		  Dim pRecordSet As RowSet = pDatabase.SelectSQL("SELECT * FROM "+me.TableName+" LIMIT 1")
		  
		  If pRecordSet Is Nil Then
		    Raise New ORMException(Me.TableName + " is not an existing table. Or empty")
		    
		  End If
		  
		  While Not pRecordSet.AfterLastRow
		    '.DefineEncoding(Encodings.UTF8))
		    pColumns.Append(pRecordSet.Column("ColumnName").StringValue)
		    pRecordSet.MoveToNextRow
		  Wend
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( deprecated = true )  Function TableCreate(pDatabase as Database, pSuffix as String = "") As Boolean
		  Dim sql As String
		  dim HasPrimaryKeys as boolean = false
		  dim HasUniqueKeys as Boolean = false
		  Dim mPrimaryKeys as String = "PRIMARY KEY ("
		  Dim mUniqueKeys as String = "UNIQUE ("
		  sql = "CREATE TABLE `"+me.TableName+pSuffix+"` ( "
		  for each dField as DictionaryEntry in Schema
		    dim field as ORMField = dField.Value
		    sql = sql + Text.EndOfLine + "`"+ dField.Key + "` " 
		    sql = sql + field.Type(pDatabase)
		    if pDatabase isa MySQLCommunityServer then
		      sql = sql +field.Length
		    else
		      if field.Type = ORMField.TypeList.DECIMAL then sql = sql +" " +field.Length
		      
		    end if
		    
		    sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		    'if pDatabase isa SQLiteDatabase then
		    'if field.PrimaryKey then  sql = sql + " PRIMARY KEY"
		    'end if
		    sql = sql + " " + field.Extra(pdatabase) +"," 
		    
		    if field.PrimaryKey then
		      HasPrimaryKeys = HasPrimaryKeys OR true
		      mPrimaryKeys  = mPrimaryKeys + "`"+dField.key+"`,"
		    end if
		    
		    if field.Unique then
		      HasUniqueKeys = HasUniqueKeys OR true
		      mUniqueKeys  = mUniqueKeys + "`"+dField.key+"`,"
		    end if
		  next
		  sql = sql.left(sql.Length -1)
		  if HasPrimaryKeys then sql = sql + ", "+Text.EndOfLine +mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ")"
		  if HasUniqueKeys then sql = sql + ", "+Text.EndOfLine +mUniqueKeys.Left(mUniqueKeys.Length - 1) + ")"
		  
		  sql = sql +");"
		  pDatabase.ExecuteSQL(sql)
		  
		  return true
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Raise New ORMException("TableName must be implemented or be called from its implementation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function TableUpdate(pDatabase as Database) As Boolean
		  if pDatabase isa MySQLCommunityServer then
		    if SchemaToCreateTable then
		      Return CreateTable(pDatabase)
		    else
		      pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 0;")
		      
		      dim HasPrimaryKeys as boolean = false
		      dim HasUniqueKeys as Boolean = false
		      Dim mPrimaryKeys as String = "ALTER TABLE `"+me.TableName+"` ADD PRIMARY KEY ("
		      Dim mUniqueKeys as String = "ALTER TABLE `"+me.TableName+"` ADD UNIQUE INDEX `unique"+System.Random.InRange(0, 1000).ToString+"`("
		      
		      // we remove all index and uni ckey
		      dim rIndexs as RowSet
		      Try
		        dim sss as string = "SELECT table_name AS `Table`, index_name AS `Index`, GROUP_CONCAT(column_name ORDER BY seq_in_index) AS `Columns` FROM information_schema.statistics WHERE table_schema = '" + pDatabase.DatabaseName + "' AND table_name = '"+me.TableName+"' GROUP BY 1,2;"
		        rIndexs = pDatabase.SelectSQL(sss)
		        
		        For Each row As DatabaseRow In rIndexs
		          if row.Column("Index").StringValue <> "PRIMARY" then
		            dim ddd as string = "ALTER TABLE `" + me.TableName + "` DROP INDEX `"+row.Column("Index").StringValue+"`;"
		            pDatabase.ExecuteSQL(ddd)
		          end if
		        Next
		        rIndexs.Close
		      Catch derror As DatabaseException
		        System.DebugLog "Error by droping keys on " + me.TableName + " : " + derror.Message
		        mLogs =  mlogs + "Error by droping keys on " + me.TableName + " : " + derror.Message + EndOfLine
		      End Try
		      
		      // remove unused columns
		      for each dField as DictionaryEntry in SchemaToRemoveColumn
		        pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		        Dim sql As String
		        sql = "ALTER TABLE `"+me.TableName+"` DROP COLUMN "
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        
		        System.DebugLog sql
		        
		        try
		          pDatabase.ExecuteSQL(sql)
		        Catch Error as DatabaseException
		          System.DebugLog "drop "+me.TableName+" DB error : " + Error.Message
		          mLogs =  mlogs + "drop "+me.TableName+" DB error : " + Error.Message + EndOfLine
		        end try
		        
		        pDatabase.ExecuteSQL("UNLOCK TABLES;")
		      next dField
		      
		      // add new columns
		      for each dField as DictionaryEntry in SchemaToAdd
		        pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		        Dim sql As String
		        
		        sql = "ALTER TABLE `"+me.TableName+"` ADD "
		        
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + field.Type(pDatabase) +field.Length
		        sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		        if field.Extra = ORMField.ExtraList.AutoIncremente then
		          sql = sql + " " + field.Extra(pdatabase)  +  " , ADD PRIMARY KEY (`" + dField.Key + "`);"
		        end if
		        
		        if field.PrimaryKey then
		          HasPrimaryKeys = HasPrimaryKeys OR true
		          mPrimaryKeys  = mPrimaryKeys + "`"+dField.key+"`"+ ","
		        end if
		        
		        if field.Unique then
		          HasUniqueKeys = HasUniqueKeys OR true
		          mUniqueKeys  = mUniqueKeys + "`"+dField.key+"`"+ ","
		        end if
		        
		        sql = sql + ";"
		        System.DebugLog sql
		        try
		          pDatabase.ExecuteSQL(sql)
		        Catch Error as DatabaseException
		          System.DebugLog "DB ADD "+me.TableName+"  error : " + Error.Message
		          mLogs =  mlogs + "DB ADD "+me.TableName+"  error : " + Error.Message + EndOfLine
		        end try
		        
		        pDatabase.ExecuteSQL("UNLOCK TABLES;")
		      next
		      
		      // alter table's columns
		      for each dField as DictionaryEntry in SchemaToAlter
		        
		        pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		        
		        Dim sql As String
		        
		        sql = "ALTER TABLE `"+me.TableName+"` CHANGE "
		        
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + field.Type(pDatabase) +field.Length
		        sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		        sql = sql + " " + field.Extra(pdatabase)  +";"
		        
		        if field.PrimaryKey then
		          HasPrimaryKeys = HasPrimaryKeys OR true
		          mPrimaryKeys  = mPrimaryKeys + "`"+dField.key+"`"+ ","
		        end if
		        
		        if field.Unique then
		          HasUniqueKeys = HasUniqueKeys OR true
		          mUniqueKeys  = mUniqueKeys + "`"+dField.key+"`"+ ","
		        end if
		        System.DebugLog sql
		        
		        try
		          pDatabase.ExecuteSQL(sql)
		          
		        catch error as DatabaseException
		          pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		          pDatabase.ExecuteSQL("UNLOCK TABLES;")
		          System.DebugLog "db alter "+me.TableName+ " : "+ error.Message
		          mLogs =  mlogs + "db alter "+me.TableName+ " : "+ error.Message + EndOfLine
		        end try
		        
		        pDatabase.ExecuteSQL("UNLOCK TABLES;")
		        
		      next
		      pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		      try
		        if HasPrimaryKeys then
		          
		          '// check if duplicate on : 
		          dim rr as RowSet = pDatabase.SelectSQL("SHOW INDEX FROM `"+me.TableName+"` where Key_name = 'PRIMARY';")
		          
		          if rr is nil then
		            System.DebugLog mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ");"
		            pDatabase.ExecuteSQL(mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ");")
		          end if
		        end if
		      Catch Error as DatabaseException
		        System.DebugLog "PrimaryKey on  "+me.TableName+" error : " + Error.Message
		        mLogs =  mlogs + "PrimaryKey on  "+me.TableName+" error : " + Error.Message + EndOfLine
		      end try
		      try
		        if HasUniqueKeys then
		          System.DebugLog mUniqueKeys.Left(mUniqueKeys.Length - 1) + ");"
		          pDatabase.ExecuteSQL(mUniqueKeys.Left(mUniqueKeys.Length - 1) + ");")
		        end if
		      Catch Error as DatabaseException
		        System.DebugLog "UniqueKey on  "+me.TableName+" error : " + Error.Message
		        mLogs =  mlogs + "UniqueKey on  "+me.TableName+" error : " + Error.Message + EndOfLine
		      end try
		      
		      
		      // INDEXING DB
		      
		      for each dField as DictionaryEntry in SchemaIndex
		        
		        Dim sql As String
		        
		        sql = "ALTER TABLE `"+me.TableName+"` ADD INDEX `"+ dField.Key + "`  ( "
		        
		        dim fields() as string = dField.Value
		        
		        For Each name As String In fields
		          sql = sql + "`"+ name + "`, " 
		        Next
		        
		        sql = sql.Left(sql.Length - 2) + ");"
		        
		        try
		          System.DebugLog sql
		          pDatabase.ExecuteSQL(sql)
		        Catch Error as DatabaseException
		          System.DebugLog "Indexing on  "+me.TableName+" error : " + Error.Message
		          mLogs =  mlogs + "Indexing on  "+me.TableName+" error : " + Error.Message + EndOfLine
		        end try
		        
		      next
		      
		      pDatabase.ExecuteSQL("UNLOCK TABLES;")
		      
		      pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		      
		    end if
		    
		  else
		    if SchemaToCreateTable then
		      Return CreateTable(pDatabase)
		    else
		      pDatabase.ExecuteSQL("PRAGMA legacy_alter_table=OFF;")
		      pDatabase.ExecuteSQL("PRAGMA foreign_keys = OFF;")
		      
		      for each dField as DictionaryEntry in SchemaToAdd
		        Dim sql As String
		        
		        sql = "ALTER TABLE `"+me.TableName+"` ADD "
		        
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + field.Type(pDatabase)
		        if field.Type = ORMField.TypeList.DECIMAL then  sql = sql + field.Length
		        sql = sql +";"
		        try
		          pDatabase.ExecuteSQL(sql)
		        Catch Error as DatabaseException
		          System.DebugLog "DB error : " + Error.Message
		        end try
		      next
		      
		      If SchemaToAlter.Count > 0 then
		        dim selectSQL as string = "SELECT "
		        dim collSelect as string
		        for each dSelect as DictionaryEntry in  Schema
		          collSelect = collSelect +"`"+ dSelect.key + "`, "
		        next
		        selectSQL = selectSQL + collSelect.Left(collSelect.Length -2)
		        
		        selectSQL = selectSQL + " FROM `" + me.TableName+"`;"
		        dim rr as RowSet = pDatabase.SelectSQL(selectSQL)
		        if rr.RowCount>0 then
		          
		          dim insertSQL as String
		          if pDatabase isa MySQLCommunityServer then
		            insertSQL = "INSERT IGNORE INTO `"+me.TableName+"_TMP`  ("+collSelect.Left(collSelect.Length -2)+") VALUES "
		          else
		            insertSQL = "INSERT OR IGNORE INTO `"+me.TableName+"_TMP`  ("+collSelect.Left(collSelect.Length -2)+") VALUES "
		          end if
		          
		          
		          dim countrecord as integer = rr.RowCount
		          While Not rr.AfterLastRow
		            insertSQL = insertSQL + "("
		            For i As Integer = 0 To rr.LastColumnIndex
		              dim colVal as string
		              if rr.ColumnAt(i).Value<>nil then
		                if rr.ColumnAt(i).StringValue = "true" or rr.ColumnAt(i).StringValue = "false" then 
		                  colval = rr.ColumnAt(i).BooleanValue.SQLValue.StringValue + ","
		                else
		                  colval =  "'" + rr.ColumnAt(i).StringValue.ReplaceAll("'", "''") + "',"
		                end if
		              else
		                colVal = "NULL" + ","
		              end if
		              insertSQL = insertSQL + colval
		            Next
		            insertSQL = insertSQL.Left(insertSQL.Length -1)
		            insertSQL = insertSQL + "),"
		            
		            rr.MoveToNextRow
		          Wend
		          rr.Close
		          insertSQL = insertSQL.Left(insertSQL.Length -1)+";"
		          
		          if CreateTable(pDatabase, "_TMP") then
		            Try
		              pDatabase.ExecuteSQL(insertSQL)
		              dim rrtest as RowSet = pDatabase.SelectSQL("SELECT 1 FROM `" + me.TableName+"_TMP`;")
		              if rrtest.RowCount= countrecord then
		                pDatabase.ExecuteSQL("DROP TABLE '"+me.TableName+"';")
		                pDatabase.ExecuteSQL("ALTER TABLE `"+me.TableName+"_TMP` RENAME TO '"+me.TableName+"';")
		              else
		                System.DebugLog "kErreur insertion données dans : " +me.TableName
		                mLogs =  mlogs + "kErreur insertion données dans : " +me.TableName + EndOfLine
		              end if
		              
		              
		            Catch error As DatabaseException
		              Return false
		            End Try
		            
		            'pDatabase.ExecuteSQL("COMMIT;")
		          end if
		          
		        end if
		        
		      end if
		      pDatabase.ExecuteSQL("PRAGMA foreign_keys = ON;")
		      
		    end if
		    
		  end if
		  SchemaToCreateTable = false
		  SchemaToAdd = nil
		  SchemaToAlter = nil
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TimeStampKey() As String
		  // Retourne la colonne de la clé primaire
		  Return "timestamp"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type(fieldName as string) As integer
		  #PRAGMA unused fieldName
		  
		  // Part of the Reports.Dataset interface.
		  
		  // All columns in a ListBox are Text/String
		  // Types described here:
		  // http://docs.xojo.com/index.php/Database.FieldSchema
		  Return 5 // value for Text
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
		    if mData.HasKey(TimeStampKey) then
		      mData.Remove(TimeStampKey)
		    End If
		    
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Update(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    pDatabase.Begin
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase).Keys
		      If mChanged.HasKey(pColumn.StringValue) Then
		        pChanged.Value(pColumn.StringValue) = mChanged.Value(pColumn.StringValue)
		      End If
		    Next
		    
		    If pChanged.Count > 0 Then
		      //System.DebugLog DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Compile
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target64Bit)) or  (TargetDesktop and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Function Update(pConnexion As KanjoSocket) As Boolean
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not me.Loaded then
		    Raise new ORMException("Cannot update " + me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    'For Each pColumn As DictionaryEntry In me.TableColumns()
		    'If me.mChanged.HasKey(pColumn.Key) Then
		    'pChanged.Value(pColumn.Key) = me.mChanged.Value(pColumn.Value)
		    'End If
		    'Next
		    
		    if pChanged.KeyCount >0 then
		      'pConnexion.BodyRequest = GenerateJSON(pChanged)
		      'pConnexion.SendMessage(pConnexion.HeaderRequest(pConnexion.POST, pConnexion.mURL+me.Pk.StringValue))
		      'pConnexion.BodyRequest = ""
		    End If
		    
		    // Merge mData with mChanged
		    For Each dKey as DictionaryEntry In me.mChanged
		      dim pKey As Variant = dKey.Key
		      me.mData.Value(pKey) = me.mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    me.mChanged.Clear
		    
		    // Execute pendings relationships
		    For Each dRemoved as DictionaryEntry In me.mRemoved
		      dim pRelation As ORMRelation = dRemoved.Value
		      
		      Call pRelation.Remove(me, pConnexion)
		    Next
		    
		    For Each dAdded as DictionaryEntry In me.mAdded
		      Dim pRelation As ORMRelation = dAdded.Value
		      Call pRelation.Add(me, pConnexion)
		    Next
		    
		    // Clear pending relationships
		    //mAdded.Clear()
		    me.mAdded = nil
		    me.mAdded = new Dictionary
		    
		    // AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!   // not the first time ?
		    //mRemoved.Clear()
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    
		    RaiseEvent Updated()
		    return true
		  End If
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Update(pDatabase As SQLiteDatabase) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    pDatabase.Begin
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn.StringValue) Then
		        pChanged.Value(pColumn.StringValue) = mChanged.Value(pColumn.StringValue)
		      End If
		    Next
		    
		    If pChanged.KeyCount > 0 Then
		      DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, False)
		    End If
		    
		    // Merge mData with mChanged
		    For Each dKey as DictionaryEntry In mChanged
		      dim pKey As Variant = dKey.Key
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.Clear
		    
		    // Execute pendings relationships
		    For Each dRemoved as DictionaryEntry In mRemoved
		      dim pRelation As ORMRelation = dRemoved.Value
		      
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each dAdded as DictionaryEntry In mAdded
		      Dim pRelation As ORMRelation = dAdded.Value
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
		    
		    pDatabase.CommitTransaction
		    
		    RaiseEvent Updated()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub UpdateCache(pDatabase as Database, pDebut as DateTime, pFin as DateTime)
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function XMLValue(pXmlDocument As XmlDocument) As XmlNode
		  // Shallow export
		  
		  Dim pXmlNode As XmlNode = pXmlDocument.CreateElement(Me.TableName)
		  
		  // Adds each column as an Attribute
		  For Each DataEntry As DictionaryEntry In Me.Data
		    pXmlNode.SetAttribute(DataEntry.Key.StringValue, DataEntry.Value.StringValue)
		  Next
		  
		  Return pXmlNode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
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
		Event NoFound()
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
		FinishLoaded As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		isNew As Boolean = True
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

	#tag Property, Flags = &h0
		mRow As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ParentORM As ORM
	#tag EndProperty

	#tag Property, Flags = &h0
		Schema As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaCurrent As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaDefaultDatas() As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaIndex As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaMadantoryData() As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToAdd As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToAlter As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToCreateTable As boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToRemoveColumn As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="mLogs"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FinishLoaded"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mReplaced"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SchemaToCreateTable"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="isNew"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mRow"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
