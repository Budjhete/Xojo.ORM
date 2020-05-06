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
		Function Add() As Xojo.Core.Dictionary
		  Dim pAdded As New Xojo.Core.Dictionary
		  
		  For Each AddedEntry As Xojo.Core.DictionaryEntry In mAdded
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
		Function Add(pForeignColumn As Text, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Add(New ORMRelationHasMany(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pForeignColumn As Text, ParamArray pORMs As ORM) As ORM
		  Return Me.Add(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Add(New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, pFarColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Add(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, ParamArray pORMs As ORM) As ORM
		  Return Me.Add(pPivotTableName, pForeignColumn, pFarColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddHard(pForeignColumn As Text, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Add(New ORMRelationHasManyHard(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddHard(pForeignColumn As Text, ParamArray pORMs As ORM) As ORM
		  Return Me.AddHard(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndHaving(pLeft As Auto, pOperator As Text, pRight As Auto) As ORM
		  Call Super.AndHaving(pLeft, pOperator, pRight)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pLeft As Auto, pOperator As Text, pRight As Auto) As ORM
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
		    
		    dim pD as new xojo.core.Dictionary
		    If mData.HasKey("estActif") Then
		      dim BouActive as Boolean = mData.Value("estActif")
		      pd.Value("estActif") = not BouActive
		    End If
		    
		    If pD.Count > 0 Then
		      DB.Update(Me.TableName).Set(pD).Where(Me.Pks).Execute(pDatabase, pCommit)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Auto In mChanged.Keys
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
		Function BelongsTo(pORM As ORM, pForeignKey As Text) As ORM
		  // Return the related model in belongs to relationship
		  // @todo support multiple primary keys
		  
		  Return pORM.Where(pORM.PrimaryKey, "=", Me.Data(pForeignKey))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bind(pTableName As Text, pForeignColumn As Text) As ORM
		  // Join operation for BelongsTo related models.
		  // @todo support for multiple primary keys
		  
		  Return Me.Join(pTableName).On(pTableName + "." + pForeignColumn, "=", Me.TableName + "." + Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed() As Boolean
		  'For Each pKey As Text In mChanged.Keys
		  'System.DebugLog "ORM change : " + pKey
		  'Next
		  'For Each pKey As Text In mAdded.Keys
		  'System.DebugLog "ORM added : " + pKey
		  'Next
		  'Try  // FIXME #8033
		  ''For Each pKey As Text In mRemoved.Keys
		  ''System.DebugLog "ORM removed : " + pKey
		  ''Next
		  'Catch e As TypeMismatchException
		  'System.DebugLog "ORM removed error: " + e.Message
		  'End Try
		  
		  
		  Return mChanged.Count > 0 Or mAdded.Count > 0 Or mRemoved.Count > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Changed(pColumn as Text) As Boolean
		  Return mChanged.HasKey(pColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clear() As ORM
		  // Clear changes, not data
		  
		  If Not RaiseEvent Clearing Then
		    
		    mChanged = nil
		    mChanged = new Xojo.Core.Dictionary
		    'mChanged.Clear
		    
		    mAdded = nil
		    mAdded = new Xojo.Core.Dictionary
		    'mAdded.Clear
		    
		    mRemoved = nil
		    mRemoved = new Xojo.Core.Dictionary
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
		    mData = new Xojo.Core.Dictionary
		    'mData.Clear
		    
		    mChanged = nil
		    mChanged = new Xojo.Core.Dictionary
		    'mChanged.Clear
		    
		    mRemoved = nil
		    mRemoved = new Xojo.Core.Dictionary
		    'mRemoved.Clear
		    
		    mAdded = nil
		    mAdded = new Xojo.Core.Dictionary
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
		  
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As Auto, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Dim d as new Xojo.Core.Dictionary
		  d.Value(Me.PrimaryKey) = pPk
		  
		  Me.Constructor(d)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPks As Dictionary, pDatabase As iOSSQLiteDatabase)
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
		  
		  Dim d as new Xojo.Core.Dictionary
		  d.Value(Me.PrimaryKey) = pPk
		  Me.Constructor(d)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As integer, pDatabase As iOSSQLiteDatabase)
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pRecordSet as iOSSQLiteRecordSet, pDB as iOSSQLiteDatabase)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pDB)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Sub Constructor(pRecordSet as iOSSQLiteRecordSet, pColumnType as Xojo.Core.Dictionary)
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
		  
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
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
		Sub Constructor(pRecordSet as RecordSet, pColumnType as Xojo.Core.Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name).AutoIntegerValue )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Sub Constructor(pLeft as Text, pRight as Auto)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  pDictionary.Value(pLeft) = pRight
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPrimaryKey as Text, pKeyValue as integer)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  pDictionary.Value(pPrimaryKey) = pKeyValue
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPk As Text, pDatabase As iOSSQLiteDatabase)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pPrimaryKey as Text, pKeyValue as Text)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  pDictionary.Value(pPrimaryKey) = pKeyValue
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Constructor(pCriterias as Xojo.Core.Dictionary, LoadFromJSON as Boolean = False)
		  Using Xojo.Core
		  // Basic ORM constructor
		  
		  Super.Constructor
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		  
		  if LoadFromJSON then
		    mData = pCriterias
		  else
		    Call Me.Where(pCriterias)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(pPks As Xojo.Core.Dictionary, pDatabase As Database)
		  // Initialize an ORM with primary keys and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(pPks)
		  
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
		  
		  For Each entry As Xojo.Core.DictionaryEntry In mData
		    pORM.mData.Value(entry.Key) = entry.Value
		  Next
		  
		  For Each ChangeEntry As Xojo.Core.DictionaryEntry In mChanged
		    pORM.mChanged.Value(ChangeEntry.key) = ChangeEntry.Value
		  Next
		  
		  For Each AddedEntry As Xojo.Core.DictionaryEntry In mAdded
		    pORM.mAdded.Value(AddedEntry.key) = AddedEntry.Value
		  Next
		  
		  For Each RemovedEntry As Xojo.Core.DictionaryEntry In mRemoved
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
		  
		  For Each pDataEntry As Xojo.Core.DictionaryEntry In cORM.mData
		    me.mData.Value(pDataEntry.Key) = pDataEntry.Value
		  Next
		  
		  For Each pColumnEntry As Xojo.Core.DictionaryEntry In cORM.mChanged
		    me.mChanged.Value(pColumnEntry.Key) = pColumnEntry.Value
		  Next
		  
		  For Each pAddedEntry As Xojo.Core.DictionaryEntry In cORM.mAdded
		    me.mAdded.Value(pAddedEntry.Key) = pAddedEntry.Value
		  Next
		  
		  For Each pRemovedEntry As Xojo.Core.DictionaryEntry In cORM.mRemoved
		    me.mRemoved.Value(pRemovedEntry.Key) = pRemovedEntry.Value
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function CountAll(pDatabase As Database) As Integer
		  Dim pColumns() As Auto
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
		    Dim pRaw As Xojo.Core.Dictionary = Me.Data
		    System.DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Xojo.Core.Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    System.DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      System.DebugLog "ORM.create pColum = " + pColumn.AutoTextValue
		      
		      If pRaw.HasKey(pColumn) Then
		        System.DebugLog "ORM.create "+pColumn.AutoTextValue+" = " + pRaw.Value(pColumn).AutoTextValue
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    System.DebugLog "ORM.create DB.Insert"
		    
		    DB.Insert(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Auto In mChanged.Keys()
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    'System.DebugLog "ORM.Create.mChanged about to clear : " + me.Name
		    // Clear changes, they are saved in mData
		    //Call Me.mChanged.Clear
		    me.mChanged = nil
		    me.mChanged = new Xojo.Core.Dictionary
		    
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
		    me.mAdded = new Xojo.Core.Dictionary
		    
		    System.DebugLog "ORM.Create.mAdded cleared"
		    
		    
		    'System.DebugLog "ORM.Create.mRemoved about to clear"
		    
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    //mRemoved.Clear
		    me.mRemoved = nil
		    me.mRemoved = new Xojo.Core.Dictionary
		    
		    System.DebugLog "ORM.Create.mRemoved cleared"
		    
		    
		    pDatabase.Commit
		    
		    RaiseEvent Created
		    System.DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Create(pDatabase As iOSSQLiteDatabase) As ORM
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
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      System.DebugLog "ORM.create pColum = " + pColumn.AutoTextValue
		      
		      If pRaw.HasKey(pColumn) Then
		        System.DebugLog "ORM.create "+pColumn.AutoTextValue+" = " + pRaw.Value(pColumn).AutoTextValue
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    System.DebugLog "ORM.create DB.Insert"
		    
		    DB.Insert(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Auto In mChanged.Keys()
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
		      Execute(pDatabase).Field(Me.PrimaryKey).Value
		      
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
		Function CreateTable(pDatabase as Database) As Boolean
		  if pDatabase isa MySQLCommunityServer then
		    'Try
		    Dim sql As Text
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    Dim mPrimaryKeys as Text = "PRIMARY KEY ("
		    Dim mUniqueKeys as Text = "UNIQUE ("
		    sql = "CREATE TABLE `"+me.TableName+"` ( "
		    for each dField as Xojo.Core.DictionaryEntry in Schema
		      dim field as ORMField = dField.Value
		      sql = sql + EndOfLine_ + "`"+ dField.Key + "` " 
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
		    if HasPrimaryKeys then sql = sql + ", "+EndOfLine_ +mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ")"
		    if HasUniqueKeys then sql = sql + ", "+EndOfLine_ +mUniqueKeys.Left(mUniqueKeys.Length - 1) + ")"
		    
		    sql = sql +");"
		    pDatabase.ExecuteSQL(sql)
		    
		    'Catch error As DatabaseExeception
		    'MessageBox("Database error: " + error.Message)
		    'End Try
		    
		  else
		    'Try
		    Dim sql As Text
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    Dim mPrimaryKeys as Text = "PRIMARY KEY ("
		    Dim mUniqueKeys as Text = "UNIQUE ("
		    sql = "CREATE TABLE `"+me.TableName+"` ( "
		    for each dField as Xojo.Core.DictionaryEntry in Schema
		      dim field as ORMField = dField.Value
		      sql = sql + EndOfLine_ + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase)
		      if field.Type(pDatabase) = "DECIMAL" then
		        sql = sql +field.Length
		      end if
		      sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
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
		    if HasPrimaryKeys then sql = sql + ", "+EndOfLine_ +mPrimaryKeys.Left(mPrimaryKeys.Length - 1) + ")"
		    if HasUniqueKeys then sql = sql + ", "+EndOfLine_ +mUniqueKeys.Left(mUniqueKeys.Length - 1) + ")"
		    
		    sql = sql +");"
		    pDatabase.ExecuteSQL(sql)
		    
		    'Catch error As DatabaseExeception
		    'MessageBox("Database error: " + error.Message)
		    'End Try
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Data() As Xojo.Core.Dictionary
		  Using Xojo.Core
		  Dim pData As Dictionary = Initial()
		  
		  // Merge mChanged over mData
		  
		  For Each ChangedEntry As DictionaryEntry In mChanged
		    pData.Value(ChangedEntry.Key) = ChangedEntry.Value
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As Text) As Auto
		  // Getter for data
		  If mChanged.HasKey(pColumn) Then
		    Return mChanged.Value(pColumn)
		  End If
		  
		  Return mData.Lookup(pColumn, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(pColumn As Text, Assigns pValue As Auto)
		  Call Data(pColumn, pValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(pColumn As Text, pValue As Auto) As ORM
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
		Function Data(pData as Xojo.Core.Dictionary) As ORM
		  For Each pDataEntry As Xojo.Core.DictionaryEntry In pData
		    Call Data(pDataEntry.Key, pDataEntry.Value)
		  Next
		  
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
		Function Dump() As Text
		  // Dump ORM content for logs
		  Using Xojo.Core
		  Dim pDump As Text = "Dumping " + QueryCompiler.Value(Me.Pk) + "@" + QueryCompiler.TableName(Me.TableName)
		  
		  // If Me.Changed Then
		  Dim pChanged() As Text
		  
		  For Each DataEntry As DictionaryEntry In Me.Data
		    
		    pChanged.Append(QueryCompiler.Column(DataEntry.Key) + ": " + QueryCompiler.Value(Me.Initial(DataEntry.Key)))
		    
		    If Me.Initial(DataEntry.Key.AutoTextValue) <> Me.Data(DataEntry.Key.AutoTextValue) Then
		      pChanged(pChanged.Ubound) = pChanged(pChanged.Ubound) +  " => " + QueryCompiler.Value(Me.Data(DataEntry.Key.AutoTextValue))
		    End If
		    
		  Next
		  
		  pDump = pDump + "Changed: " + Text.Join(pChanged, ", ") + EndOfLine_
		  
		  Dim pAdd As Text
		  
		  For Each AddEntry As DictionaryEntry In Me.Add
		    pAdd = pAdd + " " + ORMRelation(AddEntry.key).Dump
		  Next
		  
		  pDump = pDump + "Added: " + pAdd + EndOfLine_
		  
		  Dim pRemove As Text
		  
		  For Each RemoveEntry As DictionaryEntry In Me.Remove
		    pRemove = pRemove + " " + ORMRelation(RemoveEntry.Key).Dump
		  Next
		  
		  pDump = pDump + "Removed: " + pRemove + EndOfLine_
		  
		  Return pDump
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Find(pDatabase as Database, pExpiration as Xojo.Core.Date = Nil, pColumnsType() as DB.DataType = Nil, pFiringFoundEvent as Boolean = True) As ORM
		  Using Xojo.Core
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Auto
		    
		    // Prepend table to prevent collision with join
		    For Each pColumn As Text In Me.TableColumns(pDatabase)
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
		      pColumnType.Value(pRecordSetType.Field("ColumnName").TextValue) = pRecordSetType.Field("FieldType").IntegerValue
		      pRecordSetType.MoveNext
		    wend
		    // Clear any existing data
		    mData.Clear
		    
		    // Fetch record set
		    If pRecordSet.RecordCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 1 To pRecordSet.FieldCount
		        
		        Dim pColumn As Text = pRecordSet.IdxField(pIndex).Name.DefineEncoding(Encodings.UTF8).ToText
		        
		        if pColumnType <> nil then
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pColumn).AutoIntegerValue)
		        else
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase)
		        end if
		        
		        // @todo check if mChanged.Clear is not more appropriate
		        If mChanged.HasKey(pColumn) And mChanged.Value(pColumn) = mData.Value(pColumn) Then
		          mChanged.Remove(pColumn)
		        End If
		        
		      Next
		      
		      pRecordSet.Close
		      
		    End If
		    
		    if pFiringFoundEvent then RaiseEvent Found
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Find(pDatabase as IOSSQLiteDatabase, pExpiration as Date = Nil, pColumnsType() as DB.DataType = Nil) As ORM
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Auto
		    
		    // Prepend table to prevent collision with join
		    For Each pColumn As Text In Me.TableColumns(pDatabase)
		      pColumns.Append(TableName + "." + pColumn)
		    Next
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As iOSSQLiteRecordSet = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase)
		    
		    dim pRecordSetType as iOSSQLiteRecordSet = pDatabase.FieldSchema(Me.TableName)
		    
		    dim pColumnType as new Dictionary
		    
		    while not pRecordSetType.EOF
		      pColumnType.Value(pRecordSetType.Field("ColumnName").TextValue) = pRecordSetType.Field("FieldType").IntegerValue
		      pRecordSetType.MoveNext
		    wend
		    // Clear any existing data
		    mData.Clear
		    
		    // Fetch record set
		    If pRecordSet.RecordCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 1 To pRecordSet.FieldCount
		        
		        Dim pColumn As Text = pRecordSet.IdxField(pIndex).Name
		        
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
		      
		    End If
		    
		    RaiseEvent Found
		    
		  End If
		  
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FindAll(pDatabase as Database, pExpiration as Xojo.Core.Date = Nil, pOtherColumn() as Auto = nil) As RecordSet
		  Dim pColumns() As Auto
		  
		  For Each pColumn As Auto In TableColumns(pDatabase)
		    pColumns.Append(TableName + "." + pColumn)
		  Next
		  
		  For Each nColumn as Auto in pOtherColumn
		    pColumns.Append(nColumn)
		  Next
		  
		  Return Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function FindAll(pDatabase As iOSSQLiteDatabase, pExpiration As Date = Nil) As iOSSQLiteRecordSet
		  Dim pColumns() As Auto
		  
		  For Each pColumn As Auto In TableColumns(pDatabase)
		    pColumns.Append(TableName + "." + pColumn)
		  Next
		  
		  Return Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As Auto) As ORM
		  Call Super.GroupBy(pColumns)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(ParamArray pColumns As Auto) As ORM
		  Call Super.GroupBy(pColumns)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pForeignColumn As Text, pORM As ORM, pDatabase As Database) As Boolean
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pORM.TableName)._
		  Where(pORM.Pks). _
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pPivotTableName As Text, pForeignColumn As Text) As QueryBuilder
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pPivotTableName As Text, pForeignColumn As Text, pDatabase As Database) As Boolean
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Has(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, pORM As ORM, pDatabase As Database) As Boolean
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
		Protected Function HasMany(pORM As ORM, ParamArray pForeignColumns() As Text) As ORM
		  Return Me.HasMany(pORM, pForeignColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasMany(pORM As ORM, pForeignColumns() As Text) As ORM
		  // pForeignColumns must be specified in the same order as PrimaryKeys
		  
		  For pIndex As Integer = 0 To Me.PrimaryKeys.Ubound
		    Call pORM.Where(pForeignColumns(pIndex), "=", Me.Pks.Value(Me.PrimaryKeys(pIndex)))
		  Next
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasManyThrough(pORM As ORM, pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", Me.Pk) ._
		  AndWhere(pFarColumn, "=", pORM.Pk))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumns() As Text) As ORM
		  Return HasMany(pORM, pForeignColumns())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM As ORM, pForeignColumn As Text) As ORM
		  Return HasMany(pORM, pForeignColumn)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOne(pORM as ORM, pForeignColumn as Text, pKeyIndex as integer) As ORM
		  // pForeignColumns must be specified in the same order as PrimaryKeys
		  
		  Call pORM.Where(pForeignColumn, "=", Me.Pks.Value(Me.PrimaryKeys(pKeyIndex)))
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOneThrough(pORM As ORM, pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", Me.Pk)_
		  )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasOneThrough(pORM as ORM, pPivotTableName as Text, pForeignColumn as Text, pFarColumn as Text, pForeignValue as Auto) As ORM
		  Return pORM.Where(pORM.PrimaryKey, "IN", DB.Find(pFarColumn). _
		  From(pPivotTableName). _
		  Where(pForeignColumn, "=", pForeignValue)_
		  )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pColumn As Auto, pOperator As Text, pValue As Auto) As ORM
		  Call Super.Having(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pCriterias As Xojo.Core.Dictionary) As ORM
		  Call Super.Having(pCriterias)
		  
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
		  Using Xojo.Core
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
		Function Initial() As Xojo.Core.Dictionary
		  Using Xojo.Core
		  Dim pData As New Dictionary
		  
		  // Use a copy of mData to avoid external changes
		  For Each DataEntry As DictionaryEntry In mData
		    pData.Value(DataEntry.Key) = DataEntry.Value
		  Next
		  
		  Return pData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Initial(pColumn As Text) As Auto
		  Return mData.Lookup(pColumn, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertBaseData(pDatabase as Database)
		  #Pragma BreakOnExceptions False
		  
		  dim rCol as string
		  for each cCol as Xojo.Core.DictionaryEntry in Schema
		    rCol = rCol + "`"+cCol.Key+ "`, "
		  next
		  rcol = rCol.left(rcol.Length -2)
		  
		  for i as integer = 0 to SchemaDefaultDatas.LastRowIndex
		    dim strrr() as TEXT = SchemaDefaultDatas(i)
		    
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
		Function Join(pTableName As QueryExpression, pTableAlias As Text) As ORM
		  Call Super.Join(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As Text) As ORM
		  Call Super.Join(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As Text, pTableAlias As Text) As ORM
		  Call Super.Join(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function JSONValue() As Xojo.Core.Dictionary
		  Using Xojo.Core
		  // Shallow export
		  
		  Dim pJSONItem As New Xojo.Core.Dictionary
		  
		  // Adds each column as an Attribute
		  For Each pDataKeyColumn As DictionaryEntry In Me.Data
		    System.DebugLog pDataKeyColumn.key
		    dim v as Auto = pDataKeyColumn.Value
		    'System.DebugLog "type : " + v.Type.StringValue
		    if v.Type = 6 then
		      pJSONItem.Value(pDataKeyColumn.Key) = v.AutoDoubleValue
		    else
		      pJSONItem.Value(pDataKeyColumn.Key) = v
		    end if
		    System.DebugLog pDataKeyColumn.Key + ":" + pDataKeyColumn.Value
		  Next
		  
		  Return pJSONItem
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function JSONValue() As Xojo.Core.Dictionary
		  // Shallow export
		  
		  Dim pJSONItem As New Xojo.Core.Dictionary
		  
		  // Adds each column as an Attribute
		  For Each pColumn As String In Me.Data.Keys
		    if pColumn = "logo" then
		      System.DebugLog "logo"
		    end if
		    System.DebugLog pColumn
		    dim v as Auto = Me.Data(pColumn.DefineEncoding(Encodings.UTF8).ToText)
		    System.DebugLog "type : " + v.TypeText
		    Select Case v.Type
		    case 6
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8).ToText) = v.AutoDoubleValue
		    case 8, 37
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8).ToText) = v.AutoTextValue
		    else
		      pJSONItem.Value(pColumn.DefineEncoding(Encodings.UTF8).ToText) = v
		    End Select
		    'System.DebugLog pJSONItem.ToText
		  Next
		  
		  Return pJSONItem
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Function JSONValue(pDatabase As Database) As Xojo.Core.Dictionary
		  // Deep export
		  
		  // You must override this method to provide a custom export for your model
		  
		  Return Me.JSONValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As Text) As ORM
		  Call Super.LeftJoin(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As Text, pTableAlias As Text) As ORM
		  Call Super.LeftJoin(pTableName, pTableAlias)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As Text) As ORM
		  Call Super.LeftOuterJoin(pTableName)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As Text, pTableAlias As Text) As ORM
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
		  For Each pPrimaryKey As Text In Me.PrimaryKeys
		    If Me.Initial(pPrimaryKey) = Nil Then
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
		Function On(pColumn As Auto, pOperator As Text, pValue As Auto) As ORM
		  Call Super.On(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn as Auto, pOperator as Text, pValue as Auto, pType as DataType) As ORM
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
		Function OrderBy(pColumns() as Auto, pDirections() as Text, pComparators() as Text) As ORM
		  Call Super.OrderBy(pColumns, pDirections, pComparators)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn as Auto, pDirection as Text = "ASC", pComparator as Text = "") As ORM
		  Call Super.OrderBy(pColumn, pDirection, pComparator)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pColumn As Text, pOperator As Text, pValue As Auto) As ORM
		  Call Super.OrHaving(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pColumn As Text, pOperator As Text, pValue As Auto) As ORM
		  Call Super.OrOn(pColumn, pOperator, pValue)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pColumn as Text, pOperator as Text, pValue as Auto, pType as DataType) As ORM
		  Call Super.OrOn(pColumn, pOperator, pValue, pType)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pColumn As Text, pOperator As Text, pValue As Auto) As ORM
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
		Function Pk() As Auto
		  // Initial primary key value
		  Return Me.Initial(Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Pk(Assigns pValue As Auto)
		  Me.Data(Me.PrimaryKey) = pValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pks() As Xojo.Core.Dictionary
		  Using Xojo.Core
		  
		  Dim pDictionary As New Dictionary
		  
		  For Each pPrimaryKey As Text In Me.PrimaryKeys
		    pDictionary.Value(pPrimaryKey) = Me.Initial(pPrimaryKey)
		  Next
		  
		  Return pDictionary
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKey() As Text
		  // Retourne la colonne de la clé primaire
		  Return "id"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKeys() As Text()
		  Return Array(Me.PrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKeys(pIndex As Integer) As Text
		  Dim pPrimaryKeys() As Text = Me.PrimaryKeys
		  
		  Return pPrimaryKeys(pIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RaiseEventFound()
		  RaiseEvent Found
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Reload(pDatabase As Database) As ORM
		  // Save primary key, the model will be unloaded
		  
		  Dim pk As Auto = Pk()
		  
		  Call Unload()
		  
		  // Empty data, not changes and reload data
		  Return Where(PrimaryKey(), "=", pk).Find(pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove() As Xojo.Core.Dictionary
		  Using Xojo.Core
		  
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
		Function Remove(pForeignColumn As Text, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Remove(New ORMRelationHasMany(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pForeignColumn As Text, ParamArray pORMs As ORM) As ORM
		  Return Me.Remove(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, pFarKeys() As Auto) As ORM
		  For Each pFarKey As Auto In pFarKeys
		    Call Remove(New ORMRelationHasManyThrough(pPivotTableName, pForeignColumn, pFarColumn, pFarKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, ParamArray pFarKeys As Auto) As ORM
		  Return Remove(pPivotTableName, pForeignColumn, pFarColumn, pFarKeys)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveHard(pForeignColumn As Text, pORMs() As ORM) As ORM
		  For Each pORM As ORM In pORMs
		    Call Me.Remove(New ORMRelationHasManyHard(pForeignColumn, pORM))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveHard(pForeignColumn As Text, ParamArray pORMs As ORM) As ORM
		  Return Me.RemoveHard(pForeignColumn, pORMs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Replace(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  Using Xojo.Core
		  
		  If Loaded Then
		    Raise new ORMException("Cannot replace " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    pDatabase.Begin
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Xojo.Core.Dictionary = Me.Data
		    
		    // pData contains at least all primary keys
		    Dim pData As Xojo.Core.Dictionary = Me.Pks
		    
		    // Take only columns defined in the model
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      If pRaw.HasKey(pColumn) Then
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    DB.Replace(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Auto In mChanged.Keys()
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Replace(pDatabase As iOSSQLiteDatabase) As ORM
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
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      If pRaw.HasKey(pColumn) Then
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    DB.Replace(Me.TableName, pData.Keys).Values(pData.Values).Execute(pDatabase, False)
		    
		    // Merge mChanged into mData
		    For Each pKey As Auto In mChanged.Keys()
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
		      Execute(pDatabase).Field(Me.PrimaryKey).Value
		      
		    End If
		    
		    // Execute pendings relationships
		    For Each dRelation As Xojo.Core.DictionaryEntry In mRemoved
		      Dim pRelation as ORMRelation = dRelation.value
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each dRelation as Xojo.Core.DictionaryEntry In mAdded
		      dim pRelation As ORMRelation = dRelation.Value
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
		  mChanged.Clear
		  mAdded.Clear
		  mRemoved.Clear
		  
		  Call Super.Reset()
		  
		  Return Me
		End Function
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Save(pDatabase As iOSSQLiteDatabase) As ORM
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Set(ParamArray pValues As Pair) As ORM
		  Using Xojo.Core
		  
		  Dim pDictionary As New Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Call Super.Set(pDictionary)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Xojo.Core.Dictionary) As ORM
		  Call Super.Set(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableCheck(pDatabase as Database) As Boolean
		  dim rows as RowSet = pDatabase.TableColumns(TableName)
		  
		  SchemaCurrent = new Xojo.Core.Dictionary
		  
		  If rows <> Nil Then
		    if rows.RowCount>0 then
		      For Each row As DatabaseRow In rows
		        dim col as new ORMField
		        col.Type = FieldType(row.Column("FieldType").IntegerValue)
		        col.PrimaryKey = row.Column("IsPrimary").BooleanValue
		        col.NotNull = row.Column("NotNull").BooleanValue
		        if pDatabase isa MySQLCommunityServer then
		          col.Length = row.Column("Length").StringValue.DefineEncoding(Encodings.UTF8).ToText
		        else
		          col.DefaultValue = row.Column("Length").StringValue.DefineEncoding(Encodings.UTF8).ToText
		        end if
		        SchemaCurrent.value(row.Column("ColumnName").StringValue) = col
		      Next
		      rows.Close
		    else
		      SchemaToCreateTable = true
		    End If
		  End If
		  
		  SchemaToAdd = new Xojo.Core.Dictionary
		  SchemaToAlter = new Xojo.Core.Dictionary
		  
		  for each dField as Xojo.Core.DictionaryEntry in Schema
		    if NOT SchemaCurrent.HasKey(dField.key) then
		      SchemaToAdd.value(dField.key) = dField.Value
		    else
		      dim cCurrent as ORMField = SchemaCurrent.value(dField.Key)
		      dim cReal as ORMField = dField.Value
		      
		      if cCurrent.Type(pDatabase)<>cReal.type(pDatabase) then
		        SchemaToAlter.Value(dField.Key) = cReal
		      end if
		    end if
		  next
		  
		  SchemaToRemoveColumn = new Xojo.Core.Dictionary
		  
		  for each dField as Xojo.Core.DictionaryEntry in SchemaCurrent
		    if NOT Schema.HasKey(dField.key) then
		      SchemaToRemoveColumn.value(dField.key) = dField.Value
		    end if
		  next
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function TableColumns(pDatabase As Database) As Text()
		  Dim pColumns() As Text
		  
		  Dim pRecordSet As RecordSet = pDatabase.FieldSchema(Me.TableName)
		  
		  If pRecordSet Is Nil Then
		    Raise New ORMException(Me.TableName + " is not an existing table.")
		  End If
		  
		  While Not pRecordSet.EOF
		    pColumns.Append(pRecordSet.Field("ColumnName").StringValue.DefineEncoding(Encodings.UTF8).ToText)
		    pRecordSet.MoveNext
		  WEnd
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function TableColumns(pDatabase As iOSSQLiteDatabase) As Text()
		  Dim pColumns() As Text
		  
		  Dim pRecordSet As iOSSQLiteRecordSet = pDatabase.SQLSelect("SELECT * FROM "+me.TableName+" LIMIT 1")
		  
		  If pRecordSet Is Nil Then
		    Raise New ORMException(Me.TableName + " is not an existing table. Or empty")
		    
		  End If
		  
		  While Not pRecordSet.EOF
		    '.DefineEncoding(Encodings.UTF8))
		    pColumns.Append(pRecordSet.Field("ColumnName").TextValue)
		    pRecordSet.MoveNext
		  Wend
		  
		  Return pColumns
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableCreate(pDatabase as Database) As Boolean
		  Dim sql As Text
		  dim HasPrimaryKeys as boolean = false
		  dim HasUniqueKeys as Boolean = false
		  Dim mPrimaryKeys as Text = "PRIMARY KEY ("
		  Dim mUniqueKeys as Text = "UNIQUE ("
		  sql = "CREATE TABLE `"+me.TableName+"` ( "
		  for each dField as Xojo.Core.DictionaryEntry in Schema
		    dim field as ORMField = dField.Value
		    sql = sql + Text.EndOfLine + "`"+ dField.Key + "`" 
		    sql = sql + field.Type(pDatabase)
		    if pDatabase isa MySQLCommunityServer then
		      sql = sql +" " +field.Length
		    else
		      if field.Type = ORMField.TypeList.DECIMAL then sql = sql +" " +field.Length
		      
		    end if
		    
		    sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		    if pDatabase isa SQLiteDatabase then
		      if field.PrimaryKey then  sql = sql + " PRIMARY KEY"
		    end if
		    sql = sql +"," 
		    
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
		Function TableName() As Text
		  Raise New ORMException("TableName must be implemented or be called from its implementation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableUpdate(pDatabase as Database) As Boolean
		  if pDatabase isa MySQLCommunityServer then
		    
		    for each dField as Xojo.Core.DictionaryEntry in SchemaToAdd
		      Dim sql As Text
		      
		      sql = "ALTER TABLE `"+me.TableName+"` ADD "
		      
		      dim field as ORMField = dField.Value
		      sql = sql + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase) +field.Length
		      sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		      sql = sql +";"
		      pDatabase.ExecuteSQL(sql)
		    next
		    
		    for each dField as Xojo.Core.DictionaryEntry in SchemaToAlter
		      Dim sql As Text
		      
		      
		      sql = "ALTER TABLE `"+me.TableName+"` CHANGE "
		      
		      dim field as ORMField = dField.Value
		      sql = sql + "`"+ dField.Key + "` " 
		      sql = sql + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase) +field.Length
		      sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		      sql = sql +";"
		      try
		        pDatabase.ExecuteSQL(sql)
		      catch error as DatabaseException
		        Return false
		      end try
		    next
		    
		    
		    
		  else
		    if SchemaToCreateTable then
		      Return TableCreate(pDatabase)
		    else
		      for each dField as Xojo.Core.DictionaryEntry in SchemaToAdd
		        Dim sql As Text
		        
		        sql = "ALTER TABLE `"+me.TableName+"` ADD "
		        
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + field.Type(pDatabase)
		        if field.Type = ORMField.TypeList.DECIMAL then  sql = sql + field.Length
		        sql = sql +";"
		        pDatabase.ExecuteSQL(sql)
		      next
		      
		      If SchemaToAlter.Count > 0 then
		        dim selectSQL as string = "SELECT "
		        dim collSelect as string
		        for each dSelect as Xojo.Core.DictionaryEntry in  Schema
		          collSelect = collSelect +"`"+ dSelect.key + "`, "
		        next
		        selectSQL = selectSQL + collSelect.Left(collSelect.Length -2)
		        
		        selectSQL = selectSQL + " FROM `" + me.TableName+"`"
		        dim rr as RowSet = pDatabase.SelectSQL(selectSQL)
		        if rr.RowCount>0 then
		          dim insertSQL as String =  "INSERT INTO `"+me.TableName+"` ("+collSelect.Left(collSelect.Length -2)+") VALUES "
		          
		          While Not rr.AfterLastRow
		            insertSQL = insertSQL + "("
		            For i As Integer = 0 To rr.LastColumnIndex
		              dim colVal as string
		              if rr.ColumnAt(i)<>nil then
		                if rr.ColumnAt(i).StringValue = "true" or rr.ColumnAt(i).StringValue = "false" then colval = rr.ColumnAt(i).BooleanValue.SQLValue.StringValue
		                colval =  "'" + rr.ColumnAt(i).StringValue.ReplaceAll("'", "''") + "',"
		              else
		                colVal = "NULL"
		              end if
		              insertSQL = insertSQL + colval
		            Next
		            insertSQL = insertSQL.Left(insertSQL.Length -1)
		            insertSQL = insertSQL + "),"
		            
		            rr.MoveToNextRow
		          Wend
		          rr.Close
		          insertSQL = insertSQL.Left(insertSQL.Length -1)
		          
		          pDatabase.ExecuteSQL("ALTER TABLE `"+me.TableName+"` RENAME TO '"+me.TableName+"_TMP';")
		          if TableCreate(pDatabase) then
		            Try
		              pDatabase.ExecuteSQL(insertSQL)
		              
		            Catch error As DatabaseException
		              Return false
		            End Try
		            pDatabase.ExecuteSQL("PRAGMA foreign_keys = OFF;")
		            pDatabase.ExecuteSQL("DROP TABLE '"+me.TableName+"_TMP';")
		            'pDatabase.ExecuteSQL("COMMIT;")
		            pDatabase.ExecuteSQL("PRAGMA foreign_keys = ON;")
		          end if
		        end if
		      end if
		    end if
		    
		  end if
		  SchemaToCreateTable = false
		  SchemaToAdd = nil
		  SchemaToAlter = nil
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TimeStampKey() As Text
		  // Retourne la colonne de la clé primaire
		  Return "timestamp"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unload() As ORM
		  // Empties only the primary keys
		  
		  If Not RaiseEvent Unloading Then
		    
		    For Each pPrimaryKey As Text In PrimaryKeys
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
		  Using Xojo.Core
		  
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
		    
		    For Each pPrimaryKey As Text In PrimaryKeys
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
		    mData = new Xojo.Core.Dictionary
		    'mData.Clear
		    
		    mChanged = nil
		    mChanged = new Xojo.Core.Dictionary
		    'mChanged.Clear
		    
		    mRemoved = nil
		    mRemoved = new Xojo.Core.Dictionary
		    'mRemoved.Clear
		    
		    mAdded = nil
		    mAdded = new Xojo.Core.Dictionary
		    'mAdded.clear
		    
		    RaiseEvent UnloadedAll
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Update(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  Using Xojo.Core
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    pDatabase.Begin
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn) Then
		        pChanged.Value(pColumn) = mChanged.Value(pColumn)
		      End If
		    Next
		    
		    If pChanged.Count > 0 Then
		      DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, False)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Auto In mChanged.Keys
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Update(pDatabase As iOSSQLiteDatabase) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    pDatabase.Begin
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Auto In Me.TableColumns(pDatabase)
		      If mChanged.HasKey(pColumn) Then
		        pChanged.Value(pColumn) = mChanged.Value(pColumn)
		      End If
		    Next
		    
		    If pChanged.Count > 0 Then
		      DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, False)
		    End If
		    
		    // Merge mData with mChanged
		    For Each dKey as Xojo.Core.DictionaryEntry In mChanged
		      dim pKey As Auto = dKey.Key
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.Clear
		    
		    // Execute pendings relationships
		    For Each dRemoved as Xojo.Core.DictionaryEntry In mRemoved
		      dim pRelation As ORMRelation = dRemoved.Value
		      
		      Call pRelation.Remove(Me, pDatabase, False)
		    Next
		    
		    For Each dAdded as Xojo.Core.DictionaryEntry In mAdded
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
		    
		    pDatabase.Commit
		    
		    RaiseEvent Updated()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub UpdateCache(pDatabase as Database, pDebut as Xojo.Core.date, pFin as Xojo.Core.Date)
		  Raise New ORMException("UpdateCache not implemented in this model")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(ParamArray pValues() As Auto) As ORM
		  Call Super.Values(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Auto) As ORM
		  Call Super.Values(pValues)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pLeft As Auto, pOperator As Text, pRight As Auto) As ORM
		  Call Super.Where(pLeft, pOperator, pRight)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pCriterias As Xojo.Core.Dictionary) As ORM
		  Call Super.Where(pCriterias)
		  
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
		  For Each DataEntry As Xojo.Core.DictionaryEntry In Me.Data
		    pXmlNode.SetAttribute(DataEntry.Key.AutoTextValue, DataEntry.Value.AutoTextValue)
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
		Event Changed(pColumn As Text)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Changing(pColumn As Text) As Boolean
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
		ColumnsList As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		FinishLoaded As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mAdded As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mChanged As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mData As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mRemoved As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		mReplaced As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Schema As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaCurrent As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaDefaultDatas() As Auto
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaMadantoryData() As auto
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToAdd As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToAlter As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToCreateTable As boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaToRemoveColumn As Xojo.Core.Dictionary
	#tag EndProperty


	#tag ViewBehavior
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
	#tag EndViewBehavior
End Class
#tag EndClass
