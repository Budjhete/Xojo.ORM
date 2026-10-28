#tag Class
Protected Class ORM
Inherits QueryBuilder
	#tag CompatibilityFlags = ( TargetConsole and ( Target32Bit or Target64Bit ) ) or ( TargetWeb and ( Target32Bit or Target64Bit ) ) or ( TargetDesktop and ( Target32Bit or Target64Bit ) ) or ( TargetIOS and ( Target64Bit ) ) or ( TargetAndroid and ( Target64Bit ) )
	#tag Event
		Sub Close()
		  RaiseEvent Close
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  mChanged.RemoveAll
		  
		  RaiseEvent Open
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function AcquireEditLock(pDatabase As Database, context As String = "", durationMinutes As Integer = 30) As ModelORMRecordLock
		  If Not ShouldUseRecordLock Then Return Nil
		  
		  Dim activeLock As ModelORMRecordLock = ModelORMRecordLock.AcquireForORM(pDatabase, Me, ORM.CurrentEditSessionKey, ORM.CurrentEditUtilisateurNo, ORM.CurrentEditUsername, context, durationMinutes)
		  If activeLock <> Nil And activeLock.sessionKey.Trim <> ORM.CurrentEditSessionKey.Trim Then
		    Raise New ORMException("La fiche " + Me.TableName + " est verrouillee par " + LockOwnerName(activeLock) + ".")
		  End If
		  
		  Return activeLock
		End Function
	#tag EndMethod

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
		    If Not ExternalTransaction Then pDatabase.BeginTransaction
		    
		    dim pD as new Dictionary
		    If mData.HasKey("estActif") Then
		      dim BouActive as Boolean = mData.Value("estActif").BooleanValue
		      pd.Value("estActif") = not BouActive
		    End If
		    
		    If pD.KeyCount > 0 Then
		      DB.Update(Me.TableName).Set(pD).Where(Me.Pks).Execute(pDatabase, pCommit)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.RemoveAll
		    
		    If Not ExternalTransaction Then pDatabase.CommitTransaction
		    
		    RaiseEvent Updated()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataColumnIndex(pColNames() as String, pName as String) As Integer
		  for i as integer = 0 to pColNames.LastIndex
		    if pColNames(i) = pName then
		      return i
		    end if
		  next
		  return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataEscapeSQLString(pValue as String) As String
		  return pValue.ReplaceAll("'", "''")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataInsertFullRow(pDatabase as Database, pColNames() as String, pRow() as String) As Boolean
		  dim rcol as String
		  for each n as String in pColNames
		    rcol = rcol + "`" + n + "`, "
		  next
		  rcol = rcol.Left(rcol.Length - 2)
		  
		  dim sql as String = "INSERT INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		  for each st as String in pRow
		    if st = "NULL" or st = "CURRENT_TIMESTAMP" then
		      sql = sql + st + ", "
		    else
		      sql = sql + "'" + BaseDataEscapeSQLString(st) + "', "
		    end if
		  next
		  sql = sql.Left(sql.Length - 2) + ");"
		  
		  try
		    pDatabase.ExecuteSQL(sql)
		  catch err as DatabaseException
		    DebugLog me.TableName + " - " + sql + " : " + err.Message
		    mLogs = mLogs + "Base data INSERT error on " + me.TableName + ": " + err.Message + EndOfLine
		    return false
		  end try
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataInsertIgnoreFullRow(pDatabase as Database, pColNames() as String, pRow() as String) As Boolean
		  dim rcol as String
		  for each n as String in pColNames
		    rcol = rcol + "`" + n + "`, "
		  next
		  rcol = rcol.Left(rcol.Length - 2)
		  
		  dim sql as String
		  #If Not TargetIOS And Not TargetAndroid Then
		    if pDatabase isa MySQLCommunityServer then
		      sql = "INSERT IGNORE INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    else
		      sql = "INSERT OR IGNORE INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    end if
		  #Else
		    sql = "INSERT OR IGNORE INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		  #EndIf
		  
		  for each st as String in pRow
		    if st = "NULL" or st = "CURRENT_TIMESTAMP" then
		      sql = sql + st + ", "
		    else
		      sql = sql + "'" + BaseDataEscapeSQLString(st) + "', "
		    end if
		  next
		  sql = sql.Left(sql.Length - 2) + ");"
		  
		  try
		    pDatabase.ExecuteSQL(sql)
		  catch err as DatabaseException
		    DebugLog me.TableName + " - " + sql + " : " + err.Message
		    mLogs = mLogs + "Base data INSERT IGNORE error on " + me.TableName + ": " + err.Message + EndOfLine
		    return false
		  end try
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataPrimaryKeyLookupUsable(pColNames() as String, pRow() as String) As Boolean
		  dim pks() as String = PrimaryKeys()
		  for each pkName as String in pks
		    dim ix as integer = BaseDataColumnIndex(pColNames, pkName)
		    if ix < 0 or ix > pRow.LastIndex then
		      return false
		    end if
		    if pRow(ix) = "NULL" then
		      return false
		    end if
		  next
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataSchemaColumnNames() As String()
		  dim names() as String
		  for each cCol as DictionaryEntry in Schema
		    names.Add(cCol.Key.StringValue)
		  next
		  return names
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataSQLLiteralForCell(pCell as String) As String
		  if pCell = "NULL" or pCell = "CURRENT_TIMESTAMP" then
		    return pCell
		  end if
		  return "'" + BaseDataEscapeSQLString(pCell) + "'"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataUpdateNonPrimaryColumns(pDatabase as Database, pColNames() as String, pRow() as String) As Boolean
		  dim pkSet as New Dictionary
		  dim pks() as String = PrimaryKeys()
		  for each pkName as String in pks
		    pkSet.Value(pkName) = true
		  next
		  
		  dim setParts as String
		  for i as integer = 0 to pColNames.LastIndex
		    dim cname as String = pColNames(i)
		    if pkSet.HasKey(cname) then
		      continue
		    end if
		    // Clé primaire physique (ex. id auto-inc.) : PrimaryKeys() peut ne lister que la clé métier.
		    if Schema.HasKey(cname) then
		      dim sf as ORMField = Schema.Value(cname)
		      if sf.PrimaryKey then
		        continue
		      end if
		    end if
		    dim st as String = pRow(i)
		    if st = "NULL" or st = "CURRENT_TIMESTAMP" then
		      setParts = setParts + "`" + cname + "` = " + st + ", "
		    else
		      setParts = setParts + "`" + cname + "` = '" + BaseDataEscapeSQLString(st) + "', "
		    end if
		  next
		  
		  if setParts = "" then
		    return true
		  end if
		  setParts = setParts.Left(setParts.Length - 2)
		  
		  dim w as String = BaseDataWherePrimaryKey(pColNames, pRow)
		  if w = "" then
		    return false
		  end if
		  
		  dim sql as String = "UPDATE `" + me.TableName + "` SET " + setParts + " WHERE " + w + ";"
		  try
		    pDatabase.ExecuteSQL(sql)
		  catch err as DatabaseException
		    DebugLog me.TableName + " - " + sql + " : " + err.Message
		    mLogs = mLogs + "Base data UPDATE error on " + me.TableName + ": " + err.Message + EndOfLine
		    return false
		  end try
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseDataWherePrimaryKey(pColNames() as String, pRow() as String) As String
		  dim parts as String
		  dim pks() as String = PrimaryKeys()
		  for each pkName as String in pks
		    dim ix as integer = BaseDataColumnIndex(pColNames, pkName)
		    if ix < 0 or ix > pRow.LastIndex then
		      return ""
		    end if
		    dim v as String = pRow(ix)
		    if v = "NULL" then
		      parts = parts + "`" + pkName + "` IS NULL AND "
		    else
		      parts = parts + "`" + pkName + "` = " + BaseDataSQLLiteralForCell(v) + " AND "
		    end if
		  next
		  if parts = "" then
		    return ""
		  end if
		  return parts.Left(parts.Length - 5)
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
		    
		    mRelations = nil
		    mRelations = new Dictionary
		    
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
		    
		    mRelations = nil
		    mRelations = new Dictionary
		    
		    RaiseEvent Cleared
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor()
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pRecordSet As DatabaseRow)
		  // Initialize the ORM from a RowSet row (For Each row As DatabaseRow In rowSet)
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex - 1).Name) = DB.Extract(pRecordSet, pIndex - 1)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pCriterias as Dictionary, LoadFromJSON as Boolean = False)
		  // Basic ORM constructor
		  
		  Super.Constructor
		  If SchemaIndex Is Nil Then SchemaIndex = New Dictionary
		  If SchemaIndexes Is Nil Then SchemaIndexes = New Dictionary
		  If SchemaForeignKeys Is Nil Then SchemaForeignKeys = New Dictionary
		  
		  mData = New Dictionary
		  mChanged = New Dictionary
		  mAdded = New Dictionary
		  mRemoved = New Dictionary
		  mRelations = New Dictionary
		  
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pPk As integer, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Dim d as new Dictionary
		  d.Value(Me.PrimaryKey) = pPk
		  Me.Constructor(d)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pPk As integer, pDatabase As SQLiteDatabase)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pRecordSet As RowSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex-1).Name) = DB.Extract(pRecordSet, pIndex-1)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pRecordSet as RowSet, pDB as Database)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.ColumnCount
		    mData.Value(pRecordSet.ColumnAt(pIndex-1).Name) = DB.Extract(pRecordSet, pIndex-1, pDB)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pIdentificationMethod as String)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pPk As String, pDatabase As Database)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pPrimaryKey as String, pKeyValue as integer)
		  // ORM constructor with a ParamArray of initial criteria
		  // Also used for the empty constructor
		  
		  Dim pDictionary As New Dictionary
		  
		  pDictionary.Value(pPrimaryKey) = pKeyValue
		  
		  Me.Constructor(pDictionary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Constructor(pPk As String, pDatabase As SQLiteDatabase)
		  // Initialize an ORM with a primary key and the call Find
		  // This can be used to fetch your model by its primary key on a single line
		  
		  Me.Constructor(Me.PrimaryKey, pPk)
		  
		  Call Me.Find(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
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

	#tag Method, Flags = &h1000, CompatibilityFlags = false
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
		    pORM.mQuery.Add(pQueryExpression)
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
		    me.mQuery.Add(pQueryExpression)
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

	#tag Method, Flags = &h0, CompatibilityFlags = API2Only and ( (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit)) )
		Function CountAll(pDatabase As Database) As Integer
		  Dim pColumns() As Variant
		  pColumns.Add(DB.Expression("COUNT(*) AS count"))
		  
		  Return Append(New SelectQueryExpression(pColumns)).From(TableName).Execute(pDatabase).Column("count").IntegerValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Create() As Dictionary
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If me.Loaded Then
		    Raise new ORMException("Cannot create " + me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = me.Data
		    
		    //pData contains at least all primary keys
		    Dim pData As Dictionary = me.Pks
		    
		    // Take only columns defined in the model
		    For Each pColumn As DictionaryEntry In me.TableColumns
		      
		      If pRaw.HasKey(pColumn.Key) Then
		        pData.Value(pColumn.Key) = pRaw.Value(pColumn.Key)
		      End If
		    Next
		    
		    
		    dim nRelations as Dictionary
		    
		    For each dRelations as DictionaryEntry in me.mRelations
		      dim nORMs() as ORM = dRelations.Value
		      dim dORMdata() as Dictionary
		      for each nORM as ORM in nORMs
		        dORMdata.Add(nORM.Save)
		      Next
		      nRelations.Value(dRelations.Key) = dORMdata
		    Next
		    
		    pData.Value("relations") = nRelations
		    
		    me.mRelations = nil
		    me.mRelations = new Dictionary
		    
		    me.mChanged = nil
		    me.mChanged = new Dictionary
		    
		    
		    me.mAdded = nil
		    me.mAdded = new Dictionary
		    
		    
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    
		    RaiseEvent Created
		    
		    Return pData
		    
		  End If
		  
		  Return nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Create(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If Loaded Then
		    Raise new ORMException("Cannot create " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  DebugLog "ORM.create is Creating ?"
		  
		  If Not RaiseEvent Creating Then
		    'System.DebugLog "ORM.create not creating"
		    
		    If Not ExternalTransaction Then pDatabase.BeginTransaction
		    DebugLog "ORM.create database.begin"
		    
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = Me.Data
		    'System.DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    'System.DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase).Keys
		      DebugLog "ORM.create pColum = " + pColumn.StringValue
		      
		      If pRaw.HasKey(pColumn) Then
		        DebugLog "ORM.create "+pColumn.StringValue+" = " + pRaw.Value(pColumn.StringValue)
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
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		        #If Not TargetIOS And Not TargetAndroid
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		        #EndIf
		      Else
		        // Biggest primary key
		        Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		        From(Me.TableName). _
		        OrderBy(Me.PrimaryKey, "DESC"). _
		        Execute(pDatabase).Column(Me.PrimaryKey).IntegerValue
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
		    
		    
		    If Not ExternalTransaction Then pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Create(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If Loaded Then
		    Raise new ORMException("Cannot create " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  DebugLog "ORM.create is Creating ?"
		  
		  If Not RaiseEvent Creating Then
		    'System.DebugLog "ORM.create not creating"
		    
		    pDatabase.Begin
		    DebugLog "ORM.create database.begin"
		    
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = Me.Data
		    'System.DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    'System.DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase).Keys
		      DebugLog "ORM.create pColum = " + pColumn.StringValue
		      
		      If pRaw.HasKey(pColumn) Then
		        DebugLog "ORM.create "+pColumn.StringValue+" = " + pRaw.Value(pColumn.StringValue)
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
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		        #If Not TargetIOS And Not TargetAndroid
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		        #EndIf
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
		    DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Create(pDatabase As SQLiteDatabase) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  'System.DebugLog "ORM.create isloaded ?"
		  If Loaded Then
		    Raise new ORMException("Cannot create " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  DebugLog "ORM.create is Creating ?"
		  
		  If Not RaiseEvent Creating Then
		    'System.DebugLog "ORM.create not creating"
		    
		    pDatabase.Begin
		    DebugLog "ORM.create database.begin"
		    
		    
		    // Take a merge of mData and mChanged
		    Dim pRaw As Dictionary = Me.Data
		    DebugLog "ORM.create pRaw = data"
		    
		    
		    // pData contains at least all primary keys
		    Dim pData As Dictionary = Me.Pks
		    
		    'System.DebugLog "ORM.create pData = Pks"
		    
		    DebugLog "ORM.create take colums defined in model"
		    
		    // Take only columns defined in the model
		    For Each pColumn As String In Me.TableColumns(pDatabase)
		      DebugLog "ORM.create pColum = " + pColumn
		      
		      If pRaw.HasKey(pColumn) Then
		        DebugLog "ORM.create "+pColumn+" = " + pRaw.Value(pColumn)
		        pData.Value(pColumn) = pRaw.Value(pColumn)
		      End If
		    Next
		    
		    DebugLog "ORM.create DB.Insert"
		    
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
		    
		    DebugLog "ORM.Create.mChanged cleared"
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
		      
		      
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
		    
		    DebugLog "ORM.Create.mAdded cleared"
		    
		    
		    'System.DebugLog "ORM.Create.mRemoved about to clear"
		    
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    //mRemoved.Clear
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    DebugLog "ORM.Create.mRemoved cleared"
		    
		    
		    pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    DebugLog "ORM.Create Done"
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function CreateTable(pDatabase As Database, pSuffix As String = "", pCreateSQLiteIndexes As Boolean = True) As Boolean
		  NormalizeLegacySchemaIndexes
		  if pDatabase isa MySQLCommunityServer then
		    'Try
		    Dim sql As String
		    
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    'dim HasKeys as Boolean = false
		    Dim mPrimaryKeys as String = "PRIMARY KEY ("
		    Dim mUniqueKeys as String = "UNIQUE ("
		    'dim mKeys as string = 
		    sql = "CREATE TABLE `"+me.TableName+pSuffix+"` ( "
		    for each dField as DictionaryEntry in Schema
		      dim field as ORMField = dField.Value
		      sql = sql + EndOfLine + "`"+ dField.Key + "` " 
		      sql = sql + field.Type(pDatabase) +field.Length
		      sql = sql + " " + field.NotNull(pDatabase)
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
		    
		    For Each indexEntry As DictionaryEntry In SchemaIndex
		      Var indexColumns() As String = indexEntry.Value
		      sql = sql + ", " + EndOfLine + SQLIndexDefinition(indexEntry.Key.StringValue, New ORMIndex(indexColumns), True)
		    Next
		    For Each indexEntry As DictionaryEntry In SchemaIndexes
		      sql = sql + ", " + EndOfLine + SQLIndexDefinition(indexEntry.Key.StringValue, ORMIndex(indexEntry.Value), True)
		    Next
		    For Each foreignKeyEntry As DictionaryEntry In SchemaForeignKeys
		      sql = sql + ", " + EndOfLine + SQLForeignKeyDefinition(foreignKeyEntry.Key.StringValue, ORMForeignKey(foreignKeyEntry.Value))
		    Next
		    
		    sql = sql +");"
		    try
		      pDatabase.ExecuteSQL(sql)
		      
		    Catch error As DatabaseException
		      DebugLog "Database error: " + error.Message
		      Return false
		    End Try
		    Return true
		  else
		    
		    Dim sql As String
		    dim HasPrimaryKeys as boolean = false
		    dim HasUniqueKeys as Boolean = false
		    dim CanHavePrimaryKeys as Boolean = true
		    Var primaryKeyCount As Integer
		    For Each fieldEntry As DictionaryEntry In Schema
		      Var primaryField As ORMField = fieldEntry.Value
		      If primaryField.PrimaryKey Then primaryKeyCount = primaryKeyCount + 1
		    Next
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
		      
		      
		      // SQLite AUTOINCREMENT is only valid for a single INTEGER primary key.
		      if field.Extra = ORMField.ExtraList.AutoIncremente And field.PrimaryKey And primaryKeyCount = 1 then
		        sql = sql + " PRIMARY KEY AUTOINCREMENT"
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
		    
		    For Each indexEntry As DictionaryEntry In SchemaIndexes
		      Var configuredIndex As ORMIndex = ORMIndex(indexEntry.Value)
		      If configuredIndex.Unique Then
		        sql = sql + ", " + EndOfLine + "CONSTRAINT `" + indexEntry.Key.StringValue + "` UNIQUE (" + SQLColumnList(configuredIndex.Columns) + ")"
		      End If
		    Next
		    For Each foreignKeyEntry As DictionaryEntry In SchemaForeignKeys
		      sql = sql + ", " + EndOfLine + SQLForeignKeyDefinition(foreignKeyEntry.Key.StringValue, ORMForeignKey(foreignKeyEntry.Value))
		    Next
		    
		    sql = sql +");"
		    Try
		      pDatabase.ExecuteSQL(sql)
		      
		    Catch error As DatabaseException
		      DebugLog "Database error: " + error.Message
		      Return false
		    End Try
		    If pCreateSQLiteIndexes Then Return SQLiteCreateSchemaIndexes(pDatabase, pSuffix)
		    Return True
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function CurrentEditLock(pDatabase As Database) As ModelORMRecordLock
		  If Not ShouldUseRecordLock Then Return Nil
		  
		  Return ModelORMRecordLock.ActiveLock(pDatabase, Me.TableName, ModelORMRecordLock.RecordKeyFor(Me))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
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
		    Call SetData(pDataEntry.Key, pDataEntry.Value)
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub Data(pColumn As String, Assigns pValue As Variant)
		  Call SetData(pColumn, pValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Data(pColumn As String, pValue As Variant, pReturnSelf As Boolean = True) As ORM
		  #Pragma Unused pReturnSelf
		  
		  Return SetData(pColumn, pValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DataValuesAreEqual(pLeft As Variant, pRight As Variant) As Boolean
		  If pLeft = Nil Then Return pRight = Nil
		  If pRight = Nil Then Return False
		  
		  Dim pLeftIsText As Boolean = pLeft.Type = Variant.TypeString Or pLeft.Type = Variant.TypeText
		  Dim pRightIsText As Boolean = pRight.Type = Variant.TypeString Or pRight.Type = Variant.TypeText
		  
		  If pLeftIsText And pRightIsText Then
		    Return pLeft.StringValue.Compare(pRight.StringValue, ComparisonOptions.CaseSensitive) = 0
		  End If
		  
		  Return pLeft = pRight
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
		    Call ValidateEditLock(pDatabase, "delete")
		    
		    DB.Delete(Me.TableName).Where(Me.Pks).Execute(pDatabase, pCommit)
		    
		    // Empty mData
		    Call mData.RemoveAll()
		    
		    // Empty mChanges
		    Call mChanged.RemoveAll()
		    
		    // Empty pending relationships
		    Call mAdded.RemoveAll()
		    Call mRemoved.RemoveAll()
		    
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
		    
		    pChanged.Add(QueryCompiler.Column(DataEntry.Key) + ": " + QueryCompiler.Value(Me.Initial(DataEntry.Key)))
		    
		    If Not DataValuesAreEqual(Me.Initial(DataEntry.Key.StringValue), Me.Data(DataEntry.Key.StringValue)) Then
		      pChanged(pChanged.LastIndex) = pChanged(pChanged.LastIndex) +  " => " + QueryCompiler.Value(Me.Data(DataEntry.Key.StringValue))
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

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
		Function EOF() As Boolean
		  // Part of the Reports.Dataset interface.
		  
		  If mRow > 0Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
		Function Field(idx As Integer) As Variant
		  // Part of the Reports.Dataset interface.
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
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

	#tag Method, Flags = &h21
		Private Function FieldNeedAlter(pCurrent as ORMField, pExpected as ORMField, pDatabase as Database) As Boolean
		  if pCurrent is nil or pExpected is nil then
		    Return true
		  end if
		  
		  // SQLite stores VARCHAR/LONGTEXT as TEXT and SMALLINT as INTEGER.
		  // Compare the effective database types rather than their model aliases.
		  #If Not TargetIOS And Not TargetAndroid Then
		    If pCurrent.Type(pDatabase) <> pExpected.Type(pDatabase) Then Return True
		  #Else
		    If pCurrent.Type <> pExpected.Type Then Return True
		  #EndIf
		  
		  // Uniqueness belongs to an index, not to a column. It is synchronized by
		  // the legacy ORMField.Unique block or by the named SchemaIndexes entries.
		  
		  if pCurrent.PrimaryKey <> pExpected.PrimaryKey then
		    Return true
		  end if
		  
		  #If Not TargetIOS And Not TargetAndroid Then
		    If pCurrent.NotNull(pDatabase) <> pExpected.NotNull(pDatabase) Then Return True
		  #Else
		    If pCurrent.NotNull <> pExpected.NotNull Then Return True
		  #EndIf
		  
		  #If Not TargetIOS And Not TargetAndroid Then
		    if pDatabase isa MySQLCommunityServer then
		      if pCurrent.Length(pDatabase) <> pExpected.MigrationLength(pDatabase, pCurrent) then
		        Return true
		      end if
		      
		      // CURRENT_TIMESTAMP belongs to DEFAULT, not MySQL's EXTRA metadata.
		      Var currentAutoIncrement As Boolean = pCurrent.Extra = ORMField.ExtraList.AutoIncremente
		      Var expectedAutoIncrement As Boolean = pExpected.Extra = ORMField.ExtraList.AutoIncremente
		      if currentAutoIncrement <> expectedAutoIncrement then
		        Return true
		      end if
		      If pExpected.Extra = ORMField.ExtraList.CurrentTimeStamp Then
		        If pCurrent.DefaultValue(pDatabase) <> pExpected.DefaultValue(pDatabase) Then Return True
		      End If
		    end if
		  #Else
		    #Pragma Unused pDatabase
		  #EndIf
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function FieldSchema(pDatabase As Database) As RowSet
		  Return pDatabase.TableColumns(Me.TableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FieldType(pValue as Integer) As ORMField.TypeList
		  Select Case pValue
		    
		    'case 0 //null
		    'Return NIL
		  case 1
		    Return ORMField.TypeList.boolean
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
		    Return ORMField.TypeList.boolean
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
		  pValue = pValue.Trim.Lowercase
		  if pValue.Contains("tinyint") then
		    Return ORMField.TypeList.boolean
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
		  elseif pValue.Contains("string") then
		    Return ORMField.TypeList.TEXT
		  elseif pValue.Contains("longtext") then
		    Return ORMField.TypeList.LONGTEXT
		  elseif pValue.Contains("text") then
		    Return ORMField.TypeList.TEXT
		  else
		    Return ORMField.TypeList.VARCHAR
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Find(pDatabase as Database, pExpiration as DateTime = Nil, pColumnsType() as DB.DataType = Nil, pFiringFoundEvent as Boolean = True) As ORM
		  
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
		    
		    // Add SELECT and LIMIT 1 to the query, NOTE : Every compile adds QueriesExpressions in the model....
		    'System.DebugLog Append(new SelectQueryExpression(pColumns)). _
		    'From(Me.TableName). _
		    'Limit(1). _
		    'Compile
		    
		    Dim pRecordSet As RecordSet = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase, pExpiration)
		    
		    
		    // Clear any existing data
		    mData.RemoveAll
		    
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
		        If mChanged.HasKey(pColumn) And DataValuesAreEqual(mChanged.Value(pColumn), mData.Value(pColumn)) Then
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Find(pDatabase as Database, pExpiration as DateTime = Nil, pColumnsType() as DB.DataType = Nil, pFiringFoundEvent as Boolean = True) As ORM
		  If Loaded Then
		    Raise New ORMException("Cannot call find on a loaded model.")
		  End If
		  
		  If Not RaiseEvent Finding Then
		    
		    Dim pColumns() As Variant
		    
		    // Prepend table to prevent collision with join
		    dim pColumnType as Dictionary = Me.TableColumns(pDatabase)
		    For Each pColumn As Variant In pColumnType.Keys
		      pColumns.Add(TableName + "." + pColumn.StringValue)
		    Next
		    
		    // Add SELECT and LIMIT 1 to the query
		    Dim pRecordSet As Rowset = Append(new SelectQueryExpression(pColumns)). _
		    From(Me.TableName). _
		    Limit(1). _
		    Execute(pDatabase)
		    
		    // Clear any existing data
		    mData.RemoveAll
		    
		    // Fetch record set
		    If pRecordSet.RowCount = 1 Then // Empty RecordSet are filled with NULL, which is not desirable
		      
		      For pIndex As Integer = 0 To pRecordSet.ColumnCount-1
		        
		        Dim pColumn As String = pRecordSet.ColumnAt(pIndex).Name
		        
		        if pColumnType <> nil then
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase) //DB.Extract(pRecordSet, pIndex, pColumnType.Value(pColumn).IntegerValue)
		        else
		          mData.Value(pColumn) = DB.Extract(pRecordSet, pIndex, pDatabase)
		        end if
		        
		        // @todo check if mChanged.Clear is not more appropriate
		        If mChanged.HasKey(pColumn) And DataValuesAreEqual(mChanged.Value(pColumn), mData.Value(pColumn)) Then
		          mChanged.Remove(pColumn)
		        End If
		        
		      Next
		      
		      pRecordSet.Close
		      
		      if pFiringFoundEvent then RaiseEvent Found
		      
		    else
		      
		      pRecordSet.Close
		      
		      // clear existing data
		      call me.Unload.Clear
		      
		      if pFiringFoundEvent then RaiseEvent NoFound
		      
		    End If
		    
		    
		    
		  End If
		  Return Me
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Function FindAll(pDatabase As Database, pExpiration As DateTime = Nil) As RowSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As DictionaryEntry In TableColumns(pDatabase)
		    pColumns.Add(TableName + "." + pColumn.key)
		  Next
		  
		  Dim RR as RowSet = Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		  
		  return RR
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function FindAll(pDatabase as Database, pExpiration as DateTime = Nil, pOtherColumn() as Variant = nil) As RowSet
		  Dim pColumns() As Variant
		  
		  For Each pColumn As Variant In TableColumns(pDatabase).Keys
		    pColumns.Add(TableName + "." + pColumn.StringValue)
		  Next
		  
		  For Each nColumn as Variant in pOtherColumn
		    pColumns.Add(nColumn)
		  Next
		  
		  dim RR as RowSet = Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Execute(pDatabase, pExpiration)
		  
		  Return rr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function FindAll(pDatabase as Database, pOtherColumn() as Variant) As RecordSet
		  Dim pColumns() As Variant
		  
		  pColumns.Append(TableName + "." + PrimaryKey)
		  
		  For Each nColumn as Variant in pOtherColumn
		    pColumns.Append(nColumn)
		  Next
		  DebugLog Append(new SelectQueryExpression(pColumns)). _
		  From(Me.TableName). _
		  Compile
		  
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Has(pForeignColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pORM.TableName)._
		  Where(pORM.Pks). _
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Column("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Has(pForeignColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pORM.TableName)._
		  Where(pORM.Pks). _
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pPivotTableName As String, pForeignColumn As String) As QueryBuilder
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Has(pPivotTableName As String, pForeignColumn As String, pDatabase As Database) As Boolean
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Field("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Has(pPivotTableName As String, pForeignColumn As String, pDatabase As Database) As Boolean
		  // Tells if this model has at least one HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  Execute(pDatabase)._
		  Column("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Has(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pORM As ORM, pDatabase As Database) As Boolean
		  // Tells if this model is in HasManyThrough relationship
		  Return DB.Find(DB.Expression("COUNT(*) AS count"))._
		  From(pPivotTableName)._
		  Where(pForeignColumn, "=", Me.Pk)._
		  AndWhere(pFarColumn, "=", pORM.Pk)._
		  Execute(pDatabase)._
		  Column("count").BooleanValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Has(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pORM As ORM, pDatabase As Database) As Boolean
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
		  
		  For pIndex As Integer = 0 To Me.PrimaryKeys.LastIndex
		    Call pORM.Where(pForeignColumns(pIndex), "=", Me.Pks.Value(Me.PrimaryKeys(pIndex)))
		  Next
		  
		  Return pORM
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Protected Function HasMany(pORM As ORM, ParamArray pForeignColumns() As String) As ORM
		  Return Me.HasMany(pORM, pForeignColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = (TargetAndroid and (Target64Bit))
		Protected Function HasMany(pORM As ORM, pForeignColumn As String) As ORM
		  Dim pForeignColumns() As String
		  pForeignColumns.Add(pForeignColumn)
		  
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
		  pORM.mData.RemoveAll()
		  
		  // Use a copy of mData to avoid external changes
		  For Each DataEntry As DictionaryEntry In mData
		    pORM.mData.Value(DataEntry.Key) = DataEntry.Value
		  Next
		  
		  // Clear mChanged
		  pORM.mChanged.RemoveAll()
		  
		  // Use a copy of mChanged to avoid external changes
		  For Each ChangedEntry As DictionaryEntry In mChanged
		    pORM.mChanged.Value(ChangedEntry.Key) = ChangedEntry.Value
		  Next
		  
		  pORM.mAdded.RemoveAll
		  
		  // Use a copy of mAdd to avoid external changes
		  For Each AddedEntry As DictionaryEntry In mAdded
		    pORM.mAdded.Value(AddedEntry.Key) = AddedEntry.Value
		  Next
		  
		  pORM.mRemoved.RemoveAll
		  
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
		Function InsertBaseData(pDatabase as Database) As Boolean
		  #Pragma BreakOnExceptions False
		  dim errors as Boolean = false
		  dim rCol as string
		  for each cCol as DictionaryEntry in Schema
		    rCol = rCol + "`"+cCol.Key+ "`, "
		  next
		  rcol = rCol.left(rcol.Length -2)
		  
		  for i as integer = 0 to SchemaMadantoryData.LastIndex
		    dim strrr() as String = SchemaMadantoryData(i)
		    
		    dim sql as string = "INSERT INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    
		    for each st as string in strrr
		      if st="NULL" or st = "CURRENT_TIMESTAMP" then
		        sql = sql +""+st+", "
		      else
		        sql = sql +"'"+BaseDataEscapeSQLString(st)+"', "
		      end if
		    next
		    sql = sql.Left(sql.Length-2) + ");"
		    try
		      pDatabase.ExecuteSQL(sql)
		    catch Err as DatabaseException
		      DebugLog me.TableName + "- " + sql + " : " + err.Message
		      errors = errors or true
		    end try
		  next
		  
		  
		  for i as integer = 0 to SchemaDefaultDatas.LastIndex
		    dim strrr() as String = SchemaDefaultDatas(i)
		    
		    dim sql as string = "INSERT INTO `" + me.TableName + "` (" + rcol + ") VALUES ("
		    
		    for each st as string in strrr
		      if st="NULL" or st = "CURRENT_TIMESTAMP" then
		        sql = sql +""+st+", "
		      else
		        sql = sql +"'"+BaseDataEscapeSQLString(st)+"', "
		      end if
		    next
		    sql = sql.Left(sql.Length-2) + ");"
		    try
		      pDatabase.ExecuteSQL(sql)
		    catch Err as DatabaseException
		      DebugLog me.TableName + "- " + sql + " : " + err.Message
		      errors = errors or true
		      
		    end try
		  next
		  
		  Return not Errors
		End Function
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
		      DebugLog "logo"
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
		    'System.DebugLog pJSONItem.ToString
		  Next
		  
		  Return pJSONItem
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetWeb and (Target32Bit or Target64Bit))
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Load(pORM as ORM)
		  call me.UnloadFull
		  
		  mData = pORM.mData
		  
		  mChanged = pORM.mChanged
		  
		  mRemoved = pORM.mRemoved
		  
		  mAdded = pORM.mAdded
		  
		  mRelations =  pORM.mRelations
		End Sub
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

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub LoadFromIOSSQLiteRecordSet(pRecordSet As iOSSQLiteRecordSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = pRecordSet.IdxField(pIndex).Value //DB.Extract(pRecordSet, pIndex)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Sub LoadFromIOSSQLiteRecordSet(pRecordSet as iOSSQLiteRecordSet, pColumnType as Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name).IntegerValue )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Attributes( Deprecated )  Sub LoadFromRecordSet(pRecordSet As RecordSet)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex)  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Attributes( Deprecated )  Sub LoadFromRecordSet(pRecordSet As RecordSet, pDB as Database)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pDB)
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = false
		Attributes( Deprecated )  Sub LoadFromRecordSet(pRecordSet as RecordSet, pColumnType as Dictionary)
		  // Initialize the ORM with values from a RecordSet
		  
		  Me.Constructor
		  
		  For pIndex As Integer = 1 To pRecordSet.FieldCount
		    mData.Value(pRecordSet.IdxField(pIndex).Name) = DB.Extract(pRecordSet, pIndex, pColumnType.Value(pRecordSet.IdxField(pIndex).Name).IntegerValue )
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Sub LoadJSON(pCriterias as Dictionary, pRaiseEvent as Boolean = true)
		  // use it to bypass database search
		  // not swetable to manage changes
		  
		  'mData = New Dictionary
		  'mChanged = New Dictionary
		  'mAdded = New Dictionary
		  'mRemoved = New Dictionary
		  
		  'mData = pCriterias
		  
		  for Each ddd as DictionaryEntry in pCriterias
		    data(ddd.Key) = ddd.Value
		  next
		  
		  if pRaiseEvent then
		    if mData.Lookup(me.PrimaryKey, 0)>0 then
		      RaiseEvent Found
		    else
		      RaiseEvent NoFound
		    end if
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LockOwnerName(activeLock As ModelORMRecordLock) As String
		  If activeLock Is Nil Then Return "un autre utilisateur"
		  If activeLock.username.Trim <> "" Then Return activeLock.username.Trim
		  If activeLock.utilisateurNo > 0 Then Return "utilisateur #" + activeLock.utilisateurNo.ToString
		  
		  Return "un autre utilisateur"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function MySQLCurrentForeignKeys(pDatabase as Database) As Dictionary
		  dim foreignKeys as new Dictionary
		  
		  Try
		    dim sql as String = "SELECT k.constraint_name AS `Constraint`, GROUP_CONCAT(k.column_name ORDER BY k.ordinal_position) AS `Columns`, k.referenced_table_name AS `ReferencedTable`, GROUP_CONCAT(k.referenced_column_name ORDER BY k.ordinal_position) AS `ReferencedColumns`, r.update_rule AS `UpdateRule`, r.delete_rule AS `DeleteRule` FROM information_schema.key_column_usage k JOIN information_schema.referential_constraints r ON r.constraint_schema = k.constraint_schema AND r.table_name = k.table_name AND r.constraint_name = k.constraint_name WHERE k.table_schema = '" + pDatabase.DatabaseName + "' AND k.table_name = '" + me.TableName + "' AND k.referenced_table_name IS NOT NULL GROUP BY k.constraint_name, k.referenced_table_name, r.update_rule, r.delete_rule;"
		    dim rows as RowSet = pDatabase.SelectSQL(sql)
		    
		    if rows <> nil then
		      For Each row As DatabaseRow In rows
		        dim meta as new Dictionary
		        meta.Value("Columns") = MySQLNormalizeIndexColumns(row.Column("Columns").StringValue)
		        meta.Value("ReferencedTable") = row.Column("ReferencedTable").StringValue.Lowercase
		        meta.Value("ReferencedColumns") = MySQLNormalizeIndexColumns(row.Column("ReferencedColumns").StringValue)
		        meta.Value("UpdateRule") = row.Column("UpdateRule").StringValue.Uppercase
		        meta.Value("DeleteRule") = row.Column("DeleteRule").StringValue.Uppercase
		        foreignKeys.Value(row.Column("Constraint").StringValue) = meta
		      Next
		      rows.Close
		    end if
		  Catch error as DatabaseException
		    DebugLog "Error loading foreign keys on " + me.TableName + " : " + error.Message
		    mLogs =  mlogs + "Error loading foreign keys on " + me.TableName + " : " + error.Message + EndOfLine
		    Raise New ORMException("Cannot read foreign keys on " + Me.TableName + ": " + error.Message)
		  End Try
		  
		  Return foreignKeys
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function MySQLCurrentIndexes(pDatabase as Database) As Dictionary
		  dim indexes as new Dictionary
		  
		  Try
		    dim sql as String = "SELECT index_name AS `Index`, GROUP_CONCAT(column_name ORDER BY seq_in_index) AS `Columns`, MIN(non_unique) AS `NonUnique` FROM information_schema.statistics WHERE table_schema = '" + pDatabase.DatabaseName + "' AND table_name = '" + me.TableName + "' GROUP BY index_name;"
		    dim rows as RowSet = pDatabase.SelectSQL(sql)
		    
		    if rows <> nil then
		      For Each row As DatabaseRow In rows
		        dim meta as new Dictionary
		        meta.Value("Columns") = MySQLNormalizeIndexColumns(row.Column("Columns").StringValue)
		        meta.Value("NonUnique") = row.Column("NonUnique").IntegerValue <> 0
		        indexes.Value(row.Column("Index").StringValue) = meta
		      Next
		      rows.Close
		    end if
		  Catch error as DatabaseException
		    DebugLog "Error loading indexes on " + me.TableName + " : " + error.Message
		    mLogs =  mlogs + "Error loading indexes on " + me.TableName + " : " + error.Message + EndOfLine
		    Raise New ORMException("Cannot read indexes on " + Me.TableName + ": " + error.Message)
		  End Try
		  
		  Return indexes
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MySQLForeignKeyMatches(pForeignKeys As Dictionary, pName As String, pExpected As ORMForeignKey) As Boolean
		  If pForeignKeys Is Nil Or pExpected Is Nil Then Return False
		  If Not pForeignKeys.HasKey(pName) Then Return False
		  
		  Var meta As Dictionary = Dictionary(pForeignKeys.Value(pName))
		  If meta Is Nil Then Return False
		  Return meta.Lookup("Columns", "").StringValue = MySQLNormalizeIndexColumns(String.FromArray(pExpected.Columns, ",")) And _
		  meta.Lookup("ReferencedTable", "").StringValue = pExpected.ReferencedTable.Lowercase And _
		  meta.Lookup("ReferencedColumns", "").StringValue = MySQLNormalizeIndexColumns(String.FromArray(pExpected.ReferencedColumns, ",")) And _
		  meta.Lookup("UpdateRule", "").StringValue = pExpected.OnUpdate.Uppercase And _
		  meta.Lookup("DeleteRule", "").StringValue = pExpected.OnDelete.Uppercase
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MySQLHasIndexColumns(pIndexes as Dictionary, pColumns as String, pRequireUnique as Boolean = False) As Boolean
		  if pIndexes = nil then
		    Return false
		  end if
		  
		  dim expectedColumns as String = MySQLNormalizeIndexColumns(pColumns)
		  if expectedColumns = "" then
		    Return false
		  end if
		  
		  For Each entry As DictionaryEntry In pIndexes
		    dim meta as Dictionary = Dictionary(entry.Value)
		    dim currentColumns as String = meta.Lookup("Columns", "")
		    dim nonUnique as Boolean = meta.Lookup("NonUnique", true)
		    
		    if currentColumns = expectedColumns then
		      if (Not pRequireUnique) or (nonUnique = false) then
		        Return true
		      end if
		    end if
		  Next
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MySQLIndexExists(pIndexes as Dictionary, pIndexName as String) As Boolean
		  if pIndexes = nil then
		    Return false
		  end if
		  
		  Return pIndexes.HasKey(pIndexName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MySQLIndexNeededByForeignKey(pIndexName as String, pIndexColumns as String, pForeignKeys as Dictionary) As Boolean
		  if pForeignKeys = nil then
		    Return false
		  end if
		  
		  dim normalizedIndexColumns as String = MySQLNormalizeIndexColumns(pIndexColumns)
		  
		  For Each entry As DictionaryEntry In pForeignKeys
		    dim foreignKeyMeta as Dictionary = Dictionary(entry.Value)
		    dim fkColumns as String = MySQLNormalizeIndexColumns(foreignKeyMeta.Lookup("Columns", "").StringValue)
		    
		    if entry.Key.StringValue = pIndexName then
		      Return true
		    end if
		    
		    if fkColumns <> "" then
		      if normalizedIndexColumns = fkColumns then
		        Return true
		      end if
		      
		      if normalizedIndexColumns.Length > fkColumns.Length then
		        if normalizedIndexColumns.Left(fkColumns.Length) = fkColumns and normalizedIndexColumns.Middle(fkColumns.Length, 1) = "," then
		          Return true
		        end if
		      end if
		    end if
		  Next
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MySQLNormalizeIndexColumns(pColumns as String) As String
		  if pColumns = "" then
		    Return ""
		  end if
		  
		  dim normalizedColumns() as String
		  
		  For Each rawColumn As String In pColumns.Split(",")
		    dim normalizedColumn as String = rawColumn.ReplaceAll("`", "").Trim.Lowercase
		    if normalizedColumn <> "" then
		      normalizedColumns.Add(normalizedColumn)
		    end if
		  Next
		  
		  Return String.FromArray(normalizedColumns, ",")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
		Function NextRecord() As Boolean
		  // Part of the Reports.Dataset interface.
		  
		  mRow = mRow + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub NormalizeLegacySchemaIndexes()
		  If SchemaIndexes Is Nil Then SchemaIndexes = New Dictionary
		  If SchemaUniqueIndex Is Nil Then Return
		  
		  For Each indexEntry As DictionaryEntry In SchemaUniqueIndex
		    Dim indexColumns() As String = indexEntry.Value
		    If indexColumns.LastIndex >= 0 Then SchemaIndexes.Value(indexEntry.Key.StringValue) = New ORMIndex(indexColumns, True)
		  Next
		End Sub
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
		  Call Me.SetData(Me.PrimaryKey, pValue)
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

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or (TargetWeb and (Target32Bit or Target64Bit)) or (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function PrimaryKeyDuplicatePlan(pDatabase As Database, pPrimaryColumns() As String) As Dictionary()
		  // Plan first: an ambiguous group must never leave earlier groups partly deleted.
		  Var pPlans() As Dictionary
		  If pPrimaryColumns.LastIndex < 0 Then Return pPlans
		  Var pQuotedTable As String = "`" + Me.TableName.ReplaceAll("`", "``") + "`"
		  Var pKeySQL() As String
		  Var pNullSQL() As String
		  Var pWhereSQL() As String
		  Var pIsMySQL As Boolean = pDatabase IsA MySQLCommunityServer
		  For Each pName As String In pPrimaryColumns
		    Var pQuoted As String = "`" + pName.ReplaceAll("`", "``") + "`"
		    pKeySQL.Add(pQuoted)
		    pNullSQL.Add(pQuoted + " IS NULL")
		    If pIsMySQL Then
		      pWhereSQL.Add(pQuoted + " <=> ?")
		    Else
		      pWhereSQL.Add(pQuoted + " IS ?")
		    End If
		  Next
		  Var pNullRows As RowSet
		  Var pGroups As RowSet
		  Var pRows As RowSet
		  Try
		    pNullRows = pDatabase.SelectSQL("SELECT COUNT(*) FROM " + pQuotedTable + " WHERE " + String.FromArray(pNullSQL, " OR "))
		    Var pNullCount As Integer = pNullRows.ColumnAt(0).IntegerValue
		    pNullRows.Close
		    pNullRows = Nil
		    If pNullCount > 0 Then Raise New ORMException("Primary key migration on " + Me.TableName + " rejected: NULL key values.")
		    pGroups = pDatabase.SelectSQL("SELECT " + String.FromArray(pKeySQL, ",") + ", COUNT(*) FROM " + pQuotedTable + " GROUP BY " + String.FromArray(pKeySQL, ",") + " HAVING COUNT(*) > 1")
		    // Read the complete plan before touching any source row.
		    Var pGroupPlans() As Dictionary
		    For Each pGroup As DatabaseRow In pGroups
		      Var pParameters() As Variant
		      For pIndex As Integer = 0 To pPrimaryColumns.LastIndex
		        pParameters.Add(pGroup.ColumnAt(pIndex).Value)
		      Next
		      Var pPlan As New Dictionary
		      pPlan.Value("Parameters") = pParameters
		      pPlan.Value("RemoveCount") = pGroup.ColumnAt(pPrimaryColumns.Count).IntegerValue - 1
		      pGroupPlans.Add(pPlan)
		    Next
		    pGroups.Close
		    pGroups = Nil
		    If pGroupPlans.LastIndex < 0 Then Return pPlans
		    
		    Var pOrderColumns() As String
		    Const CreationColumnNames As String = "datecreation,created_at,createdat,creationdate"
		    Var pCreationNames() As String = CreationColumnNames.Split(",")
		    For Each pCandidate As String In pCreationNames
		      For Each pEntry As DictionaryEntry In Schema
		        Var pName As String = pEntry.Key.StringValue
		        If pName.Lowercase <> pCandidate Or pPrimaryColumns.IndexOf(pName) >= 0 Or Not SchemaCurrent.HasKey(pName) Then Continue
		        Var pField As ORMField = pEntry.Value
		        If pField.Type = ORMField.TypeList.DATE Or pField.Type = ORMField.TypeList.DATETIME Or pField.Type = ORMField.TypeList.TIMESTAMP Then
		          pOrderColumns.Add(pName)
		          Exit For
		        End If
		      Next
		      If pOrderColumns.LastIndex >= 0 Then Exit For
		    Next
		    For Each pEntry As DictionaryEntry In Schema
		      Var pName As String = pEntry.Key.StringValue
		      Var pField As ORMField = pEntry.Value
		      If pField.Extra = ORMField.ExtraList.AutoIncremente And pPrimaryColumns.IndexOf(pName) < 0 And SchemaCurrent.HasKey(pName) Then pOrderColumns.Add(pName)
		    Next
		    Var pNewestSQL() As String
		    Var pOldestSQL() As String
		    For Each pName As String In pOrderColumns
		      Var pQuoted As String = "`" + pName.ReplaceAll("`", "``") + "`"
		      pNewestSQL.Add(pQuoted + " DESC")
		      pOldestSQL.Add(pQuoted + " ASC")
		    Next
		    Var pWhere As String = String.FromArray(pWhereSQL, " AND ")
		    Var pNewest As String
		    Var pOldest As String
		    If pNewestSQL.LastIndex >= 0 Then
		      pNewest = " ORDER BY " + String.FromArray(pNewestSQL, ",")
		      pOldest = " ORDER BY " + String.FromArray(pOldestSQL, ",")
		    End If
		    For Each pPlan As Dictionary In pGroupPlans
		      Var pParameters() As Variant = pPlan.Value("Parameters")
		      pRows = pDatabase.SelectSQL("SELECT * FROM " + pQuotedTable + " WHERE " + pWhere + pNewest, pParameters)
		      Var pWinnerValues() As String
		      Var pWinnerNulls() As Boolean
		      Var pWinnerOrder() As String
		      Var pFirst As Boolean = True
		      Var pDifferentValues As Boolean
		      Var pIncompleteOrder As Boolean
		      For Each pRow As DatabaseRow In pRows
		        Var pSameValues As Boolean = True
		        Var pSameOrder As Boolean = True
		        For pIndex As Integer = 0 To pRows.LastColumnIndex
		          Var pValue As Variant = pRow.ColumnAt(pIndex).Value
		          Var pText As String = pRow.ColumnAt(pIndex).StringValue
		          If pFirst Then
		            pWinnerValues.Add(pText)
		            pWinnerNulls.Add(pValue.IsNull)
		          ElseIf pValue.IsNull <> pWinnerNulls(pIndex) Or pText.Compare(pWinnerValues(pIndex), ComparisonOptions.CaseSensitive) <> 0 Then
		            pSameValues = False
		          End If
		        Next
		        For pIndex As Integer = 0 To pOrderColumns.LastIndex
		          Var pValue As Variant = pRow.Column(pOrderColumns(pIndex)).Value
		          Var pText As String = pRow.Column(pOrderColumns(pIndex)).StringValue
		          If pValue.IsNull Or pText = "" Then pIncompleteOrder = True
		          If pFirst Then
		            pWinnerOrder.Add(pText)
		          ElseIf pText.Compare(pWinnerOrder(pIndex), ComparisonOptions.CaseSensitive) <> 0 Then
		            pSameOrder = False
		          End If
		        Next
		        If Not pFirst And Not pSameValues Then
		          pDifferentValues = True
		          If pSameOrder Then Raise New ORMException("Primary key migration on " + Me.TableName + " rejected: conflicting duplicates have no unambiguous creation order.")
		        End If
		        pFirst = False
		      Next
		      pRows.Close
		      pRows = Nil
		      If pIncompleteOrder And pDifferentValues Then Raise New ORMException("Primary key migration on " + Me.TableName + " rejected: incomplete creation order.")
		      pPlan.Value("WhereSQL") = pWhere
		      pPlan.Value("OrderSQL") = pOldest
		      pPlans.Add(pPlan)
		    Next
		    Return pPlans
		  Finally
		    If pRows <> Nil Then pRows.Close
		    If pGroups <> Nil Then pGroups.Close
		    If pNullRows <> Nil Then pNullRows.Close
		  End Try
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function ReleaseEditLock(pDatabase As Database) As Boolean
		  If Not ShouldUseRecordLock Then Return True
		  
		  Return ModelORMRecordLock.ReleaseForORM(pDatabase, Me, ORM.CurrentEditSessionKey)
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

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or (TargetWeb and (Target32Bit or Target64Bit)) or (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function RepairDuplicateDocumentNumbers(pDatabase As Database, pColumns() As String) As Boolean
		  // Only models with internal workstation-numbered documents opt into this repair.
		  If Not SchemaRenumberDuplicateNumbers Then Return False
		  If pColumns.Count <> 2 Or pColumns.IndexOf("numero") < 0 Or pColumns.IndexOf("type") < 0 Then Return False
		  If Not Schema.HasKey(PrimaryKey) Or Not Schema.HasKey("numero") Then Return False
		  Var pKeyField As ORMField = Schema.Value(PrimaryKey)
		  If Not pKeyField.PrimaryKey Or pKeyField.Type <> ORMField.TypeList.INTEGER Or pKeyField.Extra <> ORMField.ExtraList.AutoIncremente Then Return False
		  Const Digits As String = "0123456789"
		  Var pQuotedTable As String = "`" + Me.TableName.ReplaceAll("`", "``") + "`"
		  Var pQuotedKey As String = "`" + PrimaryKey.ReplaceAll("`", "``") + "`"
		  Var pIsMySQL As Boolean = pDatabase IsA MySQLCommunityServer
		  Var pSavepointOpen As Boolean
		  Var pAutocommitChanged As Boolean
		  Var pOriginalAutocommit As Integer
		  Var pOriginalForeignKeyChecks As Integer
		  Var pSucceeded As Boolean
		  Var pRows As RowSet
		  Var pAudit() As String
		  Try
		    pRows = pDatabase.SelectSQL("SELECT COUNT(*) FROM (SELECT 1 FROM " + pQuotedTable + " WHERE `numero` IS NOT NULL AND `type` IS NOT NULL GROUP BY `numero`, `type` HAVING COUNT(*)>1) AS duplicate_numbers")
		    Var pInitialConflicts As Integer = pRows.ColumnAt(0).IntegerValue
		    pRows.Close
		    pRows = Nil
		    If pInitialConflicts = 0 Then Return True
		    Var pPreserveUpdateColumns As String
		    If pIsMySQL Then
		      // Metadata must be inspected before LOCK TABLES; then re-read the actual rows under lock.
		      pDatabase.ExecuteSQL("UNLOCK TABLES")
		      pRows = pDatabase.SelectSQL("SELECT @@SESSION.AUTOCOMMIT AS auto_commit, @@SESSION.FOREIGN_KEY_CHECKS AS foreign_keys")
		      pOriginalAutocommit = pRows.Column("auto_commit").IntegerValue
		      pOriginalForeignKeyChecks = pRows.Column("foreign_keys").IntegerValue
		      pRows.Close
		      pRows = pDatabase.SelectSQL("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?", Me.TableName)
		      Var pEngine As String = pRows.ColumnAt(0).StringValue
		      pRows.Close
		      If pEngine <> "InnoDB" Then Raise New ORMException("Document renumbering requires InnoDB on " + Me.TableName)
		      pRows = pDatabase.SelectSQL("SELECT (SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=DATABASE() AND EVENT_OBJECT_TABLE=? AND EVENT_MANIPULATION='UPDATE') + (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA=DATABASE() AND REFERENCED_TABLE_NAME=? AND REFERENCED_COLUMN_NAME='numero')", Me.TableName, Me.TableName)
		      Var pDependencies As Integer = pRows.ColumnAt(0).IntegerValue
		      pRows.Close
		      If pDependencies > 0 Then Raise New ORMException("Document renumbering requires review of number references or update triggers on " + Me.TableName)
		      // Preserve automatic ON UPDATE timestamps: the only changed value is numero.
		      pRows = pDatabase.SelectSQL("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND LOWER(EXTRA) LIKE '%on update%'", Me.TableName)
		      For Each pRow As DatabaseRow In pRows
		        Var pName As String = pRow.Column("COLUMN_NAME").StringValue
		        Var pQuoted As String = "`" + pName.ReplaceAll("`", "``") + "`"
		        pPreserveUpdateColumns = pPreserveUpdateColumns + ", " + pQuoted + "=" + pQuoted
		      Next
		      pRows.Close
		      pDatabase.ExecuteSQL("SET autocommit=0")
		      pAutocommitChanged = True
		      pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS=1")
		      pDatabase.ExecuteSQL("LOCK TABLES " + pQuotedTable + " WRITE")
		    Else
		      pRows = pDatabase.SelectSQL("SELECT (SELECT COUNT(*) FROM sqlite_master WHERE type='trigger' AND tbl_name=?) + (SELECT COUNT(*) FROM sqlite_temp_master WHERE type='trigger' AND tbl_name=?) + (SELECT COUNT(*) FROM sqlite_master AS m JOIN pragma_foreign_key_list(m.name) AS fk WHERE m.type='table' AND fk.`table`=? AND fk.`to`='numero')", Me.TableName, Me.TableName, Me.TableName)
		      Var pDependencies As Integer = pRows.ColumnAt(0).IntegerValue
		      pRows.Close
		      If pDependencies > 0 Then Raise New ORMException("Document renumbering requires review of number references or triggers on " + Me.TableName)
		    End If
		    pRows = Nil
		    pDatabase.ExecuteSQL("SAVEPOINT orm_document_number_repair")
		    pSavepointOpen = True
		    // Keep the earliest physical identity in each native-collation group.
		    // NULL unique-key components do not conflict in MySQL or SQLite.
		    // Each SELECT references the locked physical table once (MySQL LOCK TABLES rule).
		    Var pGroupSQL As String = "SELECT `numero`, `type`, MIN(" + pQuotedKey + ") AS first_identity FROM " + pQuotedTable + " WHERE `numero` IS NOT NULL AND `type` IS NOT NULL GROUP BY `numero`, `type` HAVING COUNT(*)>1"
		    pRows = pDatabase.SelectSQL(pGroupSQL)
		    Var pGroups() As Dictionary
		    For Each pRow As DatabaseRow In pRows
		      Var pGroup As New Dictionary
		      pGroup.Value("Number") = pRow.Column("numero").StringValue
		      pGroup.Value("Type") = pRow.Column("type").StringValue
		      pGroup.Value("FirstIdentity") = pRow.Column("first_identity").Int64Value
		      pGroups.Add(pGroup)
		    Next
		    pRows.Close
		    pRows = Nil
		    Var pPlanByIdentity As New Dictionary
		    Var pIdentities() As Int64
		    Var pLoserSQL As String = "SELECT " + pQuotedKey + ", `numero`, `type` FROM " + pQuotedTable + " WHERE `numero`=? AND `type`=? AND " + pQuotedKey + "<>? ORDER BY " + pQuotedKey + " DESC"
		    For Each pGroup As Dictionary In pGroups
		      Var pGroupNumber As String = pGroup.Value("Number")
		      Var pGroupType As String = pGroup.Value("Type")
		      Var pFirstIdentity As Int64 = pGroup.Value("FirstIdentity")
		      pRows = pDatabase.SelectSQL(pLoserSQL, pGroupNumber, pGroupType, pFirstIdentity)
		      For Each pRow As DatabaseRow In pRows
		        Var pNumber As String = pRow.Column("numero").StringValue.DefineEncoding(Encodings.UTF8)
		        Var pIdentity As Int64 = pRow.Column(PrimaryKey).Int64Value
		        Var pNumberContext As String = GenerateJSON(New Dictionary("table":Me.TableName, "key":PrimaryKey, "id":pIdentity, "numero":pNumber, "type":pRow.Column("type").StringValue))
		        If pNumber.Trim = "" Then Raise New ORMException("Empty internal number requires an explicit numbering series: " + pNumberContext)
		        Var pSuffix As String = pNumber.Middle(2).TrimRight
		        If pNumber.Length <= 2 Or pSuffix = "" Then Raise New ORMException("Unsupported internal number format: " + pNumberContext)
		        For pIndex As Integer = 0 To pSuffix.Length - 1
		          If Digits.IndexOf(pSuffix.Middle(pIndex, 1)) < 0 Then Raise New ORMException("Unsupported internal number format: " + pNumberContext)
		        Next
		        Var pPlan As New Dictionary
		        pPlan.Value("PK") = pIdentity
		        pPlan.Value("OldNumber") = pNumber
		        pPlan.Value("Type") = pRow.Column("type").StringValue
		        pPlan.Value("Prefix") = pNumber.Left(2)
		        pPlan.Value("Width") = pSuffix.Length
		        pPlanByIdentity.Value(pIdentity) = pPlan
		        pIdentities.Add(pIdentity)
		      Next
		      pRows.Close
		      pRows = Nil
		    Next
		    Var pPlans() As Dictionary
		    pIdentities.Sort
		    For pIndex As Integer = pIdentities.LastIndex DownTo 0
		      Var pIdentity As Int64 = pIdentities(pIndex)
		      pPlans.Add(pPlanByIdentity.Value(pIdentity))
		    Next
		    Var pNumberField As ORMField = Schema.Value("numero")
		    Var pCurrentNumberField As ORMField = SchemaCurrent.Value("numero")
		    Var pCapacity As Integer = pNumberField.MigrationLength(pDatabase, pCurrentNumberField).ReplaceAll("(", "").ReplaceAll(")", "").ToInteger
		    // Validate every old format before the first UPDATE. Allocate inside this transaction
		    // so later free-number checks also see candidates assigned to earlier repair rows.
		    For Each pPlan As Dictionary In pPlans
		      Var pPrefix As String = pPlan.Value("Prefix")
		      Var pType As String = pPlan.Value("Type")
		      Var pMaximum As String = "0"
		      // Keep the stored column on the left so its native collation also defines the series.
		      Var pSeriesPredicate As String
		      If pIsMySQL Then
		        pSeriesPredicate = "`numero`=CONCAT(?,SUBSTR(`numero`,3))"
		      Else
		        pSeriesPredicate = "`numero`=(? || SUBSTR(`numero`,3))"
		      End If
		      pRows = pDatabase.SelectSQL("SELECT `numero` FROM " + pQuotedTable + " WHERE " + pSeriesPredicate + " AND `type`=?", pPrefix, pType)
		      For Each pRow As DatabaseRow In pRows
		        Var pSuffix As String = pRow.Column("numero").StringValue.Middle(2)
		        Var pNumeric As Boolean = pSuffix <> ""
		        For pIndex As Integer = 0 To pSuffix.Length - 1
		          If Digits.IndexOf(pSuffix.Middle(pIndex, 1)) < 0 Then
		            pNumeric = False
		            Exit For
		          End If
		        Next
		        If Not pNumeric Then Continue
		        While pSuffix.Length > 1 And pSuffix.Left(1) = "0"
		          pSuffix = pSuffix.Middle(1)
		        Wend
		        Var pLarger As Boolean = pSuffix.Length > pMaximum.Length
		        If pSuffix.Length = pMaximum.Length Then
		          For pIndex As Integer = 0 To pSuffix.Length - 1
		            Var pDigit As Integer = Digits.IndexOf(pSuffix.Middle(pIndex, 1))
		            Var pMaxDigit As Integer = Digits.IndexOf(pMaximum.Middle(pIndex, 1))
		            If pDigit <> pMaxDigit Then
		              pLarger = pDigit > pMaxDigit
		              Exit For
		            End If
		          Next
		        End If
		        If pLarger Then pMaximum = pSuffix
		      Next
		      pRows.Close
		      pRows = Nil
		      Var pNewNumber As String
		      Do
		        // Decimal-string increment avoids Int64 overflow on long legacy series.
		        Var pCarry As Boolean = True
		        For pIndex As Integer = pMaximum.Length - 1 DownTo 0
		          Var pDigit As Integer = Digits.IndexOf(pMaximum.Middle(pIndex, 1))
		          If pDigit < 9 Then
		            pDigit = pDigit + 1
		            pMaximum = pMaximum.Left(pIndex) + Digits.Middle(pDigit, 1) + pMaximum.Middle(pIndex + 1)
		            pCarry = False
		            Exit For
		          End If
		          pMaximum = pMaximum.Left(pIndex) + "0" + pMaximum.Middle(pIndex + 1)
		        Next
		        If pCarry Then pMaximum = "1" + pMaximum
		        Var pPadded As String = pMaximum
		        Var pWidth As Integer = pPlan.Value("Width")
		        While pPadded.Length < pWidth
		          pPadded = "0" + pPadded
		        Wend
		        pNewNumber = pPrefix + pPadded
		        If pCapacity <= 0 Or pNewNumber.Length > pCapacity Then Raise New ORMException("No available internal number fits " + Me.TableName + ".numero")
		        // Native equality retains the column's case/accent/padding semantics.
		        pRows = pDatabase.SelectSQL("SELECT COUNT(*) FROM " + pQuotedTable + " WHERE `numero`=? AND `type`=?", pNewNumber, pType)
		        Var pUsed As Boolean = pRows.ColumnAt(0).IntegerValue > 0
		        pRows.Close
		        pRows = Nil
		        If Not pUsed Then Exit
		      Loop
		      Var pIdentity As Int64 = pPlan.Value("PK")
		      Var pOldNumber As String = pPlan.Value("OldNumber")
		      pDatabase.ExecuteSQL("UPDATE " + pQuotedTable + " SET `numero`=?" + pPreserveUpdateColumns + " WHERE " + pQuotedKey + "=? AND `numero`=? AND `type`=?", pNewNumber, pIdentity, pOldNumber, pType)
		      If pIsMySQL Then
		        pRows = pDatabase.SelectSQL("SELECT ROW_COUNT()")
		      Else
		        pRows = pDatabase.SelectSQL("SELECT changes()")
		      End If
		      Var pAffected As Integer = pRows.ColumnAt(0).IntegerValue
		      pRows.Close
		      pRows = Nil
		      If pAffected <> 1 Then Raise New ORMException("Internal number repair lost its target on " + Me.TableName)
		      pAudit.Add(Me.TableName + "." + PrimaryKey + "=" + pIdentity.ToString + ": numero " + pOldNumber + " -> " + pNewNumber)
		    Next
		    pRows = pDatabase.SelectSQL("SELECT COUNT(*) FROM (SELECT 1 FROM " + pQuotedTable + " WHERE `numero` IS NOT NULL AND `type` IS NOT NULL GROUP BY `numero`, `type` HAVING COUNT(*)>1) AS duplicate_numbers")
		    Var pRemaining As Integer = pRows.ColumnAt(0).IntegerValue
		    pRows.Close
		    pRows = Nil
		    If pRemaining > 0 Then Raise New ORMException("Duplicate internal numbers remain on " + Me.TableName)
		    pDatabase.ExecuteSQL("RELEASE SAVEPOINT orm_document_number_repair")
		    pSavepointOpen = False
		    // MySQL DDL commits implicitly. Retain verified number repairs if a later index fails.
		    If pIsMySQL Then pDatabase.ExecuteSQL("COMMIT")
		    pSucceeded = True
		    For Each pMessage As String In pAudit
		      mLogs = mLogs + pMessage + EndOfLine
		    Next
		    Return True
		  Catch pError As RuntimeException
		    If pError IsA EndException Or pError IsA ThreadEndException Then Raise pError
		    mLogs = mLogs + "Internal number repair on " + Me.TableName + ": " + pError.Message + EndOfLine
		    Return False
		  Finally
		    Try
		      If pRows <> Nil Then pRows.Close
		      If pSavepointOpen Then
		        pDatabase.ExecuteSQL("ROLLBACK TO SAVEPOINT orm_document_number_repair")
		        pDatabase.ExecuteSQL("RELEASE SAVEPOINT orm_document_number_repair")
		      End If
		    Finally
		      If pIsMySQL And pAutocommitChanged Then
		        Try
		          If Not pSucceeded Then
		            pDatabase.ExecuteSQL("ROLLBACK")
		            pDatabase.ExecuteSQL("UNLOCK TABLES")
		          End If
		        Finally
		          Try
		            pDatabase.ExecuteSQL("SET autocommit=" + pOriginalAutocommit.ToString)
		          Finally
		            pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS=" + pOriginalForeignKeyChecks.ToString)
		          End Try
		        End Try
		      End If
		    End Try
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Replace() As Dictionary
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
		  'If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
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

	#tag Method, Flags = &h0, CompatibilityFlags = false
		Attributes( Deprecated )  Function Replace(pDatabase As Database) As ORM
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
		    Call Me.mChanged.RemoveAll
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		        #If Not TargetIOS And Not TargetAndroid
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		        #EndIf
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
		    mAdded.RemoveAll
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    mRemoved.RemoveAll
		    
		    pDatabase.Commit
		    
		    RaiseEvent Created
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Replace(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  
		  If Loaded Then
		    Raise new ORMException("Cannot replace " + Me.TableName + " model because it is already loaded.")
		  End
		  
		  If Not RaiseEvent Creating Then
		    
		    If Not ExternalTransaction Then pDatabase.BeginTransaction
		    
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
		    Call Me.mChanged.RemoveAll
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
		      
		      If pDatabase IsA SQLiteDatabase Then
		        // Best guess for SQLite
		        Me.mData.Value(Me.PrimaryKey) = SQLiteDatabase(pDatabase).LastRowID
		        // Best guess for MySQL when available
		        #If Not TargetIOS And Not TargetAndroid
		      ElseIf pDatabase IsA MySQLCommunityServer Then
		        Me.mData.Value(Me.PrimaryKey) = MySQLCommunityServer(pDatabase).GetInsertID
		        #EndIf
		      Else
		        // Biggest primary key
		        Me.mData.Value(Me.PrimaryKey) = DB.Find(Me.PrimaryKey). _
		        From(Me.TableName). _
		        OrderBy(Me.PrimaryKey, "DESC"). _
		        Execute(pDatabase).Column(Me.PrimaryKey).IntegerValue
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
		    mAdded.RemoveAll
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    mRemoved.RemoveAll
		    
		    If Not ExternalTransaction Then pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
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
		    Call Me.mChanged.RemoveAll
		    
		    // todo: check if the primary key is auto increment
		    If Me.PrimaryKeys.LastIndex = 0 Then // Refetching the primary key work only with a single primary key
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
		    mAdded.RemoveAll
		    // FIXME #7870 AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!!
		    mRemoved.RemoveAll
		    
		    pDatabase.CommitTransaction
		    
		    RaiseEvent Created
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ReportUpdateCacheProgress(pPrimaryKey As Variant, pPrimaryKeyName As String = "")
		  If UpdateCacheThread = Nil Then Return
		  If pPrimaryKeyName.Trim = "" Then pPrimaryKeyName = Me.PrimaryKey
		  
		  UpdateCacheThread.AddUserInterfaceUpdate("UpdateCacheCompletedPrimaryKey" : pPrimaryKeyName, "UpdateCacheCompletedRowTag" : pPrimaryKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As ORM
		  mChanged.RemoveAll
		  mAdded.RemoveAll
		  mRemoved.RemoveAll
		  
		  Call Super.Reset()
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
		Sub Run()
		  // Part of the Reports.Dataset interface.
		  
		  mRow = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Save() As Dictionary
		  dim bSaved as new Dictionary
		  If Not RaiseEvent Saving Then
		    
		    If Loaded() Then
		      bSaved = Update()
		    Elseif mReplaced then
		      bSaved = Replace()
		    else
		      bSaved = Create()
		    End
		    
		  End If
		  Return bSaved
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
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

	#tag Method, Flags = &h0
		Function SetData(pColumn As String, pValue As Variant) As ORM
		  If Not RaiseEvent Changing(pColumn) Then
		    
		    // If it is different than the original data, it has changed
		    If Not DataValuesAreEqual(Initial(pColumn), pValue) Then
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

	#tag Method, Flags = &h21
		Private Function ShouldUseRecordLock() As Boolean
		  If Not ORM.RecordLocksEnabled Then Return False
		  If Not Me.Loaded Then Return False
		  If ORM.CurrentEditSessionKey.Trim = "" Then Return False
		  If Me.TableName.Trim = "" Then Return False
		  If Me.TableName.Trim.Lowercase = "ormrecordlock" Then Return False
		  
		  Return ModelORMRecordLock.RecordKeyFor(Me).Trim <> ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SQLColumnList(pColumns() As String) As String
		  Var result As String
		  For Each columnName As String In pColumns
		    If columnName.Trim = "" Then Raise New ORMException("A schema column cannot be empty.")
		    If result <> "" Then result = result + ", "
		    result = result + "`" + columnName.Trim + "`"
		  Next
		  
		  If result = "" Then Raise New ORMException("A schema constraint must contain at least one column.")
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SQLForeignKeyDefinition(pName As String, pForeignKey As ORMForeignKey) As String
		  If pForeignKey Is Nil Then Raise New ORMException("Foreign key " + pName + " has no definition.")
		  Return "CONSTRAINT `" + pName + "` FOREIGN KEY (" + SQLColumnList(pForeignKey.Columns) + ") REFERENCES `" + pForeignKey.ReferencedTable + "` (" + SQLColumnList(pForeignKey.ReferencedColumns) + ") ON UPDATE " + pForeignKey.OnUpdate + " ON DELETE " + pForeignKey.OnDelete
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SQLIndexDefinition(pName As String, pIndex As ORMIndex, pInsideCreateTable As Boolean) As String
		  If pIndex Is Nil Then Raise New ORMException("Index " + pName + " has no definition.")
		  Var prefix As String
		  If pInsideCreateTable Then
		    prefix = If(pIndex.Unique, "UNIQUE KEY ", "KEY ")
		  Else
		    prefix = If(pIndex.Unique, "UNIQUE INDEX ", "INDEX ")
		  End If
		  
		  Return prefix + "`" + pName + "` (" + SQLColumnList(pIndex.Columns) + ")"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function SQLiteCreateSchemaIndexes(pDatabase As Database, pSuffix As String = "") As Boolean
		  // SQLite index names are shared by all tables, unlike MySQL index names.
		  Var pTable As String = Me.TableName + pSuffix
		  Var pExpected As New Dictionary
		  If SchemaIndex <> Nil Then
		    For Each pEntry As DictionaryEntry In SchemaIndex
		      Var pColumns() As String = pEntry.Value
		      pExpected.Value(pEntry.Key) = New ORMIndex(pColumns)
		    Next
		  End If
		  If SchemaIndexes <> Nil Then
		    For Each pEntry As DictionaryEntry In SchemaIndexes
		      pExpected.Value(pEntry.Key) = pEntry.Value
		    Next
		  End If
		  Try
		    Var pActual As New Dictionary
		    Var pRows As RowSet = pDatabase.SelectSQL("SELECT name, [unique] AS is_unique FROM pragma_index_list(?) WHERE partial = 0", pTable)
		    For Each pRow As DatabaseRow In pRows
		      Var pFields As RowSet = pDatabase.SelectSQL("SELECT name FROM pragma_index_info(?) ORDER BY seqno", pRow.Column("name").StringValue)
		      Var pNames() As String
		      For Each pField As DatabaseRow In pFields
		        pNames.Add(pField.Column("name").StringValue)
		      Next
		      pFields.Close
		      Var pKey As String = MySQLNormalizeIndexColumns(String.FromArray(pNames, ","))
		      pActual.Value(If(pRow.Column("is_unique").BooleanValue, "u:", "i:") + pKey) = True
		    Next
		    pRows.Close
		    For Each pEntry As DictionaryEntry In pExpected
		      Var pIndex As ORMIndex = pEntry.Value
		      Var pKey As String = MySQLNormalizeIndexColumns(String.FromArray(pIndex.Columns, ","))
		      If pKey = "" Then Continue
		      If pActual.HasKey("u:" + pKey) Then Continue
		      If Not pIndex.Unique And pActual.HasKey("i:" + pKey) Then Continue
		      Var pName As String = pTable + "_" + pEntry.Key.StringValue
		      Var pSQL As String = "CREATE " + If(pIndex.Unique, "UNIQUE ", "") + "INDEX `" + pName.ReplaceAll("`", "``") + "` ON `" + pTable.ReplaceAll("`", "``") + "` (" + SQLColumnList(pIndex.Columns) + ")"
		      pDatabase.ExecuteSQL(pSQL)
		      pActual.Value(If(pIndex.Unique, "u:", "i:") + pKey) = True
		    Next
		    Return True
		  Catch pError As DatabaseException
		    mLogs = mLogs + "SQLite index on " + pTable + ": " + pError.Message + EndOfLine
		    DebugLog "SQLite index on " + pTable + ": " + pError.Message
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function SQLiteHasUniqueIndexColumns(pDatabase as Database, pColumns as String) As Boolean
		  dim expectedColumns as String = MySQLNormalizeIndexColumns(pColumns)
		  if expectedColumns = "" then
		    Return false
		  end if
		  
		  Try
		    dim tableNameSQL as String = me.TableName.ReplaceAll("'", "''")
		    dim indexes as RowSet = pDatabase.SelectSQL("PRAGMA index_list('" + tableNameSQL + "');")
		    
		    if indexes <> nil then
		      For Each indexRow As DatabaseRow In indexes
		        if indexRow.Column("unique").BooleanValue then
		          dim indexName as String = indexRow.Column("name").StringValue
		          dim indexNameSQL as String = indexName.ReplaceAll("'", "''")
		          dim indexColumns as RowSet = pDatabase.SelectSQL("PRAGMA index_info('" + indexNameSQL + "');")
		          dim currentColumns() as String
		          
		          if indexColumns <> nil then
		            For Each columnRow As DatabaseRow In indexColumns
		              currentColumns.Add(columnRow.Column("name").StringValue)
		            Next
		            indexColumns.Close
		          end if
		          
		          if MySQLNormalizeIndexColumns(String.FromArray(currentColumns, ",")) = expectedColumns then
		            indexes.Close
		            Return true
		          end if
		        end if
		      Next
		      indexes.Close
		    end if
		  Catch error As DatabaseException
		    DebugLog "Error loading SQLite indexes on " + me.TableName + " : " + error.Message
		    mLogs = mLogs + "Error loading SQLite indexes on " + me.TableName + " : " + error.Message + EndOfLine
		  End Try
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function SyncBaseDataAfterTableUpdate(pDatabase as Database) As Boolean
		  // Après migration de schéma: réapplique seulement les données obligatoires.
		  // SchemaMadantoryData: si BaseDataMandatorySyncEnabled, upsert (insert ou mise à jour des colonnes non-PK).
		  // Sinon, insertion seulement si la ligne (clé primaire logique) n'existe pas.
		  // SchemaDefaultDatas est réservé à la création initiale de la table/base.
		  #Pragma BreakOnExceptions False
		  
		  if SchemaMadantoryData.LastIndex < 0 then
		    return true
		  end if
		  
		  dim colNames() as String = BaseDataSchemaColumnNames()
		  if colNames.LastIndex < 0 then
		    return true
		  end if
		  
		  for each rowV as Variant in SchemaMadantoryData
		    if not SyncOneBaseDataRow(pDatabase, colNames, rowV, BaseDataMandatorySyncEnabled) then
		      return false
		    end if
		  next
		  
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SyncOneBaseDataRow(pDatabase as Database, pColNames() as String, pRowData as Variant, pAllowMandatoryUpdate as Boolean) As Boolean
		  dim pRow() as String = pRowData
		  if pRow.LastIndex <> pColNames.LastIndex then
		    mLogs = mLogs + "Base data row column count mismatch on " + me.TableName + EndOfLine
		    return false
		  end if
		  
		  if BaseDataPrimaryKeyLookupUsable(pColNames, pRow) then
		    dim w as String = BaseDataWherePrimaryKey(pColNames, pRow)
		    if w = "" then
		      return BaseDataInsertFullRow(pDatabase, pColNames, pRow)
		    end if
		    
		    // COUNT(*) retourne toujours une ligne; évite RowCount / curseur peu fiables selon les moteurs (ex. SQLite).
		    dim sqlSel as String = "SELECT COUNT(*) AS __bdc FROM `" + me.TableName + "` WHERE " + w + ";"
		    dim rs as RowSet
		    try
		      rs = pDatabase.SelectSQL(sqlSel)
		    catch err as DatabaseException
		      DebugLog me.TableName + " - " + sqlSel + " : " + err.Message
		      mLogs = mLogs + "Base data SELECT error on " + me.TableName + ": " + err.Message + EndOfLine
		      return false
		    end try
		    
		    dim exists as Boolean = false
		    if rs <> nil then
		      try
		        // COUNT(*) produit exactement une ligne; première colonne = le nombre.
		        while not rs.AfterLastRow
		          exists = (rs.ColumnAt(0).IntegerValue > 0)
		          exit while
		        wend
		      catch ex as RuntimeException
		        DebugLog me.TableName + " base data COUNT read: " + ex.Message
		      end try
		      rs.Close
		    end if
		    
		    if not exists then
		      return BaseDataInsertFullRow(pDatabase, pColNames, pRow)
		    end if
		    
		    if pAllowMandatoryUpdate then
		      return BaseDataUpdateNonPrimaryColumns(pDatabase, pColNames, pRow)
		    end if
		    
		    return true
		  else
		    // Clé primaire non utilisable (ex.: id auto NULL): insertion seule, ignore si doublon.
		    return BaseDataInsertIgnoreFullRow(pDatabase, pColNames, pRow)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function TableCheck(pDatabase as Database) As Boolean
		  #Pragma BreakOnExceptions False
		  
		  dim rows as RowSet 
		  SchemaCurrent = new Dictionary
		  SchemaToCreateTable = false
		  
		  if (pDatabase isa MySQLCommunityServer) then
		    If DB.MySQLSchemaSnapshotMatches(pDatabase) Then
		      Dim tableSnapshot As Dictionary = DB.MySQLTableSchemaSnapshot(pDatabase, TableName)
		      If tableSnapshot Is Nil Then
		        SchemaToCreateTable = true
		      Else
		        For Each columnEntry As DictionaryEntry In tableSnapshot
		          Dim metadata As Dictionary = Dictionary(columnEntry.Value)
		          Dim columnType As String = metadata.Lookup("Type", "").StringValue
		          Dim col As New ORMField
		          col.Type = FieldType(columnType)
		          col.PrimaryKey = metadata.Lookup("Key", "").StringValue = "PRI"
		          col.NotNull = metadata.Lookup("Null", "YES").StringValue = "NO"
		          col.Length = FieldLength(columnType)
		          col.DefaultValue = metadata.Lookup("Default", "").StringValue.DefineEncoding(Encodings.UTF8)
		          col.Extra = FieldExtra(metadata.Lookup("Extra", "").StringValue)
		          col.Unique = metadata.Lookup("Unique", False).BooleanValue
		          SchemaCurrent.Value(columnEntry.Key.StringValue) = col
		        Next
		      End If
		    Else
		      try
		        rows = pDatabase.SelectSQL("DESCRIBE "+ TableName+";")
		      Catch e as DatabaseException
		        DebugLog "Db " + TableName + " not exist"
		        SchemaToCreateTable = true
		      end try
		      Var rowsU As RowSet
		      Var dU As New Dictionary
		      Var primaryColumns As New Dictionary
		      // DESCRIBE can label a UNIQUE NOT NULL index PRI without a real PRIMARY KEY.
		      Try
		        rowsU = pDatabase.SelectSQL("SELECT COLUMN_NAME, INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND NON_UNIQUE = 0", TableName)
		        If rowsU <> Nil Then
		          For Each rowU As DatabaseRow In rowsU
		            Var columnName As String = rowU.Column("COLUMN_NAME").StringValue.DefineEncoding(Encodings.UTF8)
		            If rowU.Column("INDEX_NAME").StringValue = "PRIMARY" Then
		              primaryColumns.Value(columnName) = True
		            Else
		              dU.Value(columnName) = True
		            End If
		          Next
		        End If
		      Catch indexError As DatabaseException
		        Raise New ORMException("Cannot read MySQL indexes for " + TableName + ": " + indexError.Message)
		      Finally
		        If rowsU <> Nil Then rowsU.Close
		      End Try
		      
		      If rows <> Nil Then
		        if rows.RowCount>0 then
		          For Each row As DatabaseRow In rows
		            dim col as new ORMField
		            col.Type = FieldType(row.Column("Type").StringValue)
		            col.PrimaryKey = primaryColumns.HasKey(row.Column("Field").StringValue.DefineEncoding(Encodings.UTF8))
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
		    End If
		  else
		    // Get table columns
		    rows = pDatabase.TableColumns(TableName)
		    // SQLite primary-key metadata is an ordinal: every positive position is a key part.
		    // Read it directly instead of converting TableColumns.IsPrimary to Boolean.
		    Var primaryKeys As New Dictionary
		    Var primaryKeyRows As RowSet
		    Try
		      primaryKeyRows = pDatabase.SelectSQL("SELECT name FROM pragma_table_info(?) WHERE pk > 0", TableName)
		      For Each primaryKeyRow As DatabaseRow In primaryKeyRows
		        primaryKeys.Value(primaryKeyRow.Column("name").StringValue.DefineEncoding(Encodings.UTF8)) = True
		      Next
		    Catch primaryKeyError As DatabaseException
		      Raise New ORMException("Cannot read SQLite primary keys for " + TableName + ": " + primaryKeyError.Message)
		    Finally
		      If primaryKeyRows <> Nil Then primaryKeyRows.Close
		    End Try
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
		          Var columnName As String = row.Column("ColumnName").StringValue.DefineEncoding(Encodings.UTF8)
		          col.Type = FieldType(row.Column("FieldType").IntegerValue)
		          col.PrimaryKey = primaryKeys.HasKey(columnName)
		          col.NotNull = row.Column("NotNull").BooleanValue
		          col.DefaultValue = row.Column("Length").StringValue.DefineEncoding(Encodings.UTF8)
		          col.Unique = dU.Lookup(columnName, false)
		          SchemaCurrent.Value(columnName) = col
		          
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
		      
		      // Named unique indexes are validated separately in TableUpdate.
		      // Do not reinterpret their columns as the legacy single UNIQUE group.
		      if cCurrent.Unique and Not cReal.Unique and SchemaUniqueIndex <> nil then
		        for each dUnique as DictionaryEntry in SchemaUniqueIndex
		          dim uniqueFields() as String = dUnique.Value
		          For Each fieldName As String In uniqueFields
		            if fieldName = dField.Key.StringValue then
		              cCurrent.Unique = false
		              Exit For
		            end if
		          Next
		          if Not cCurrent.Unique then
		            Exit For
		          end if
		        next
		      end if
		      
		      if FieldNeedAlter(cCurrent, cReal, pDatabase) then
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function TableColumns() As Dictionary
		  Dim pColumns() As String
		  
		  'BuildSchema()
		  
		  for each entr as DictionaryEntry in me.Schema
		    pColumns.Add(entr.Key.StringValue)
		  next
		  
		  Return me.Schema
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableColumns(pDatabase As Database) As Dictionary
		  If DB.DatabaseSchemaCache Is Nil Then DB.DatabaseSchemaCache = New Dictionary
		  If DB.DatabaseSchemaCache.HasKey(Me.TableName) Then Return DB.DatabaseSchemaCache.Value(Me.TableName)
		  
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
		    Raise New ORMException(Me.TableName + " is not an existing table. Please update your database.")
		    
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
		  if SchemaUniqueIndex <> nil then
		    for each dUnique as DictionaryEntry in SchemaUniqueIndex
		      dim uniqueFields() as String = dUnique.Value
		      if uniqueFields.LastIndex >= 0 then
		        dim namedUnique as String = "UNIQUE ("
		        For Each fieldName As String In uniqueFields
		          namedUnique = namedUnique + "`" + fieldName + "`,"
		        Next
		        sql = sql + ", " + Text.EndOfLine + namedUnique.Left(namedUnique.Length - 1) + ")"
		      end if
		    next
		  end if
		  
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
		  mInvalidIndexReport = ""
		  NormalizeLegacySchemaIndexes
		  Var schemaUpdateError As Boolean
		  Var pPrimaryColumns() As String
		  For Each pEntry As DictionaryEntry In Schema
		    Var pField As ORMField = pEntry.Value
		    If pField.PrimaryKey Then
		      If pDatabase IsA MySQLCommunityServer And pField.Extra = ORMField.ExtraList.AutoIncremente Then
		        pPrimaryColumns.AddAt(0, pEntry.Key.StringValue)
		      Else
		        pPrimaryColumns.Add(pEntry.Key.StringValue)
		      End If
		    End If
		  Next
		  
		  if pDatabase isa MySQLCommunityServer then
		    if SchemaToCreateTable then
		      if not CreateTable(pDatabase) then
		        return false
		      end if
		      if not InsertBaseData(pDatabase) then
		        return false
		      end if
		      return true
		    else
		      Var pForeignKeySettingRows As RowSet = pDatabase.SelectSQL("SELECT @@SESSION.FOREIGN_KEY_CHECKS")
		      Var pOriginalForeignKeyChecks As Integer = pForeignKeySettingRows.ColumnAt(0).IntegerValue
		      pForeignKeySettingRows.Close
		      pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 0;")
		      Try
		        
		        dim HasUniqueKeys as Boolean = false
		        dim mUniqueIndexName as String = "unique" + System.Random.InRange(0, 1000).ToString
		        Dim mUniqueKeys as String = "ALTER TABLE `"+me.TableName+"` ADD UNIQUE INDEX `" + mUniqueIndexName + "`("
		        dim mUniqueColumns as String
		        dim currentIndexes as Dictionary
		        dim uniqueIndexError as Boolean = false
		        dim currentForeignKeys as Dictionary
		        
		        for each schemaEntry as DictionaryEntry in Schema
		          dim schemaField as ORMField = schemaEntry.Value
		          
		          if schemaField.Unique then
		            HasUniqueKeys = true
		            mUniqueKeys = mUniqueKeys + "`"+schemaEntry.key+"`,"
		            mUniqueColumns = mUniqueColumns + "`"+schemaEntry.key+"`,"
		          end if
		        next
		        
		        // remove unused columns
		        for each dField as DictionaryEntry in SchemaToRemoveColumn
		          If schemaUpdateError Then Exit For
		          Try
		            pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		          Catch lockError As DatabaseException
		            DebugLog "LOCK TABLES on " + me.TableName + " : " + lockError.Message
		            mLogs =  mlogs + "LOCK TABLES on " + me.TableName + " : " + lockError.Message + EndOfLine
		          End Try
		          Dim sql As String
		          sql = "ALTER TABLE `"+me.TableName+"` DROP COLUMN "
		          'dim field as ORMField = dField.Value
		          sql = sql + "`"+ dField.Key + "` " 
		          
		          DebugLog sql
		          
		          try
		            pDatabase.ExecuteSQL(sql)
		          Catch Error as DatabaseException
		            DebugLog "drop "+me.TableName+" DB error : " + Error.Message
		            mLogs =  mlogs + "drop "+me.TableName+" DB error : " + Error.Message + EndOfLine
		            schemaUpdateError = True
		          end try
		          
		          Try
		            pDatabase.ExecuteSQL("UNLOCK TABLES;")
		          Catch unlockError As DatabaseException
		            DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		            mLogs =  mlogs + "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message + EndOfLine
		          End Try
		        next dField
		        
		        // add new columns
		        for each dField as DictionaryEntry in SchemaToAdd
		          If schemaUpdateError Then Exit For
		          Try
		            pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		          Catch lockError As DatabaseException
		            DebugLog "LOCK TABLES on " + me.TableName + " : " + lockError.Message
		            mLogs =  mlogs + "LOCK TABLES on " + me.TableName + " : " + lockError.Message + EndOfLine
		          End Try
		          Dim sql As String
		          
		          sql = "ALTER TABLE `"+me.TableName+"` ADD "
		          
		          dim field as ORMField = dField.Value
		          sql = sql + "`"+ dField.Key + "` " 
		          sql = sql + field.Type(pDatabase) +field.Length
		          sql = sql + " " + field.NotNull(pDatabase) + " " + field.DefaultValue(pDatabase)
		          if field.Extra = ORMField.ExtraList.AutoIncremente then
		            sql = sql + " " + field.Extra(pdatabase)  +  " , ADD PRIMARY KEY (`" + dField.Key + "`)"
		          end if
		          
		          sql = sql + ";"
		          DebugLog sql
		          try
		            pDatabase.ExecuteSQL(sql)
		          Catch Error as DatabaseException
		            DebugLog "DB ADD "+me.TableName+"  error : " + Error.Message
		            mLogs =  mlogs + "DB ADD "+me.TableName+"  error : " + Error.Message + EndOfLine
		            schemaUpdateError = True
		          end try
		          
		          Try
		            pDatabase.ExecuteSQL("UNLOCK TABLES;")
		          Catch unlockError As DatabaseException
		            DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		            mLogs =  mlogs + "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message + EndOfLine
		          End Try
		        next
		        
		        // alter table's columns
		        for each dField as DictionaryEntry in SchemaToAlter
		          If schemaUpdateError Then Exit For
		          
		          Try
		            pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		          Catch lockError As DatabaseException
		            DebugLog "LOCK TABLES on " + me.TableName + " : " + lockError.Message
		            mLogs =  mlogs + "LOCK TABLES on " + me.TableName + " : " + lockError.Message + EndOfLine
		            schemaUpdateError = True
		            Exit For
		          End Try
		          
		          Dim sql As String
		          
		          sql = "ALTER TABLE `"+me.TableName+"` CHANGE "
		          
		          Var field As ORMField = dField.Value
		          Var pCurrentField As ORMField = SchemaCurrent.Value(dField.Key)
		          Var pMigrationLength As String = field.MigrationLength(pDatabase, pCurrentField)
		          If field.Type = ORMField.TypeList.VARCHAR And pCurrentField.Type <> ORMField.TypeList.VARCHAR Then
		            // Check characters, not bytes, before a TEXT/other-type conversion can shorten data.
		            Var pCapacity As Integer = pMigrationLength.ReplaceAll("(", "").ReplaceAll(")", "").ToInteger
		            If pCapacity > 0 Then
		              Var pQuotedField As String = "`" + dField.Key.StringValue.ReplaceAll("`", "``") + "`"
		              Var pLengthRows As RowSet
		              Try
		                pLengthRows = pDatabase.SelectSQL("SELECT COUNT(*) AS invalid_rows, MAX(CHAR_LENGTH(" + pQuotedField + ")) AS maximum_length FROM `" + Me.TableName.ReplaceAll("`", "``") + "` WHERE CHAR_LENGTH(" + pQuotedField + ") > ?", pCapacity)
		                Var pTooLongCount As Integer = pLengthRows.Column("invalid_rows").IntegerValue
		                If pTooLongCount > 0 Then
		                  Var pMaximumLength As Integer = pLengthRows.Column("maximum_length").IntegerValue
		                  mLogs = mLogs + "Cannot convert " + Me.TableName + "." + dField.Key.StringValue + " to VARCHAR(" + pCapacity.ToString + "): " + pTooLongCount.ToString + " rows exceed the limit (maximum " + pMaximumLength.ToString + " characters). Original values preserved." + EndOfLine
		                  schemaUpdateError = True
		                End If
		              Finally
		                If pLengthRows <> Nil Then pLengthRows.Close
		              End Try
		              If schemaUpdateError Then Exit For
		            End If
		          End If
		          sql = sql + "`"+ dField.Key + "` "
		          sql = sql + "`"+ dField.Key + "` "
		          sql = sql + field.Type(pDatabase) + pMigrationLength
		          sql = sql + " " + field.NotNull(pDatabase) + " " + field.DefaultValue(pDatabase)
		          sql = sql + " " + field.Extra(pdatabase)  +";"
		          DebugLog sql
		          
		          try
		            pDatabase.ExecuteSQL(sql)
		            
		          catch error as DatabaseException
		            pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		            Try
		              pDatabase.ExecuteSQL("UNLOCK TABLES;")
		            Catch unlockError As DatabaseException
		              DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		              mLogs =  mlogs + "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message + EndOfLine
		            End Try
		            DebugLog "db alter "+me.TableName+ " : "+ error.Message
		            mLogs =  mlogs + "db alter "+me.TableName+ " : "+ error.Message + EndOfLine
		            schemaUpdateError = True
		          end try
		          
		          Try
		            pDatabase.ExecuteSQL("UNLOCK TABLES;")
		          Catch unlockError As DatabaseException
		            DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		            mLogs =  mlogs + "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message + EndOfLine
		          End Try
		          
		        next
		        If schemaUpdateError Then
		          pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		          Return False
		        End If
		        // information_schema cannot be inspected reliably once LOCK TABLES is active.
		        // Load the current keys first, then keep this snapshot current after each ADD.
		        #Pragma BreakOnExceptions False
		        currentIndexes = MySQLCurrentIndexes(pDatabase)
		        currentForeignKeys = MySQLCurrentForeignKeys(pDatabase)
		        Var pExpectedPrimary As String = MySQLNormalizeIndexColumns(String.FromArray(pPrimaryColumns, ","))
		        Var pCurrentPrimary As String
		        If currentIndexes.HasKey("PRIMARY") Then
		          Var pPrimaryMeta As Dictionary = currentIndexes.Value("PRIMARY")
		          pCurrentPrimary = pPrimaryMeta.Lookup("Columns", "").StringValue
		        End If
		        If pCurrentPrimary <> pExpectedPrimary Then
		          Var pBackupTable As String
		          Var pBackupCreated As Boolean
		          Var pAutocommitChanged As Boolean
		          Var pOriginalAutocommit As Integer
		          Var pPrimaryApplied As Boolean
		          Var pRestoreFailed As Boolean
		          Var pDeletedPlans() As Dictionary
		          Var pQuotedTable As String = "`" + Me.TableName.ReplaceAll("`", "``") + "`"
		          Var pQuotedColumns() As String
		          For Each pEntry As DictionaryEntry In Schema
		            pQuotedColumns.Add("`" + pEntry.Key.StringValue.ReplaceAll("`", "``") + "`")
		          Next
		          Var pColumnList As String = String.FromArray(pQuotedColumns, ",")
		          Var pDuplicatePlans() As Dictionary
		          Try
		            pDuplicatePlans = PrimaryKeyDuplicatePlan(pDatabase, pPrimaryColumns)
		            If pDuplicatePlans.LastIndex >= 0 Then
		              // Cleanup must not orphan children or invoke delete/insert trigger side effects.
		              Var pDependencies As RowSet = pDatabase.SelectSQL("SELECT (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME = ?) + (SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = DATABASE() AND EVENT_OBJECT_TABLE = ?) AS dependencies", Me.TableName, Me.TableName)
		              Var pDependencyCount As Integer = pDependencies.ColumnAt(0).IntegerValue
		              pDependencies.Close
		              If pDependencyCount > 0 Then Raise New ORMException("Duplicate cleanup requires manual review of foreign keys or triggers on " + Me.TableName)
		              Var pEngineRows As RowSet = pDatabase.SelectSQL("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?", Me.TableName)
		              Var pEngine As String = pEngineRows.ColumnAt(0).StringValue
		              pEngineRows.Close
		              If pEngine <> "InnoDB" Then Raise New ORMException("Duplicate cleanup requires InnoDB on " + Me.TableName)
		              Var pBackupNumber As Integer = System.Random.InRange(1, 2147483647)
		              pBackupTable = "_orm_pk_backup_" + DateTime.Now.SQLDateTime.ReplaceAll("-", "").ReplaceAll(":", "").ReplaceAll(" ", "") + "_" + pBackupNumber.ToString
		              // A real backup survives connection loss and MySQL's implicit DDL commits.
		              pDatabase.ExecuteSQL("CREATE TABLE `" + pBackupTable + "` ENGINE=InnoDB AS SELECT " + pColumnList + " FROM " + pQuotedTable + " WHERE 1 = 0")
		              pBackupCreated = True
		            End If
		            Var pLockSQL As String = "LOCK TABLES " + pQuotedTable + " WRITE"
		            If pBackupCreated Then
		              pLockSQL = pLockSQL + ", `" + pBackupTable + "` WRITE"
		              Var pAutocommitRows As RowSet = pDatabase.SelectSQL("SELECT @@SESSION.AUTOCOMMIT")
		              pOriginalAutocommit = pAutocommitRows.ColumnAt(0).IntegerValue
		              pAutocommitRows.Close
		              pDatabase.ExecuteSQL("SET autocommit = 0")
		              pAutocommitChanged = True
		            End If
		            pDatabase.ExecuteSQL(pLockSQL)
		            // Re-plan under the write lock; a concurrent edit cannot change the winner.
		            pDuplicatePlans = PrimaryKeyDuplicatePlan(pDatabase, pPrimaryColumns)
		            If pDuplicatePlans.LastIndex >= 0 And Not pBackupCreated Then Raise New ORMException("Concurrent duplicates appeared on " + Me.TableName + "; retry the migration.")
		            For Each pPlan As Dictionary In pDuplicatePlans
		              Var pParameters() As Variant = pPlan.Value("Parameters")
		              Var pLimit As Integer = pPlan.Value("RemoveCount")
		              Var pSelection As String = " WHERE " + pPlan.Value("WhereSQL").StringValue + pPlan.Value("OrderSQL").StringValue + " LIMIT " + pLimit.ToString
		              pDatabase.ExecuteSQL("INSERT INTO `" + pBackupTable + "` (" + pColumnList + ") SELECT " + pColumnList + " FROM " + pQuotedTable + pSelection, pParameters)
		            Next
		            // Persist every recovery row before any DELETE, including before an implicit DDL commit.
		            If pBackupCreated Then pDatabase.ExecuteSQL("COMMIT")
		            For Each pPlan As Dictionary In pDuplicatePlans
		              Var pParameters() As Variant = pPlan.Value("Parameters")
		              Var pLimit As Integer = pPlan.Value("RemoveCount")
		              Var pSelection As String = " WHERE " + pPlan.Value("WhereSQL").StringValue + pPlan.Value("OrderSQL").StringValue + " LIMIT " + pLimit.ToString
		              pDeletedPlans.Add(pPlan)
		              pDatabase.ExecuteSQL("DELETE FROM " + pQuotedTable + pSelection, pParameters)
		            Next
		            Var pKeyColumns() As String
		            For Each pName As String In pPrimaryColumns
		              pKeyColumns.Add("`" + pName.ReplaceAll("`", "``") + "`")
		            Next
		            Var pPrimarySQL As String = "ALTER TABLE " + pQuotedTable + " "
		            If pCurrentPrimary <> "" Then pPrimarySQL = pPrimarySQL + "DROP PRIMARY KEY"
		            If pExpectedPrimary <> "" Then
		              If pCurrentPrimary <> "" Then pPrimarySQL = pPrimarySQL + ", "
		              pPrimarySQL = pPrimarySQL + "ADD PRIMARY KEY (" + String.FromArray(pKeyColumns, ",") + ")"
		            End If
		            // An AUTO_INCREMENT column still needs a leading index if it leaves PRIMARY.
		            For Each pEntry As DictionaryEntry In Schema
		              Var pField As ORMField = pEntry.Value
		              If pField.Extra <> ORMField.ExtraList.AutoIncremente Then Continue
		              Var pAutoColumn As String = pEntry.Key.StringValue.Lowercase
		              Var pHasAutoIndex As Boolean = pExpectedPrimary = pAutoColumn Or pExpectedPrimary.Left(pAutoColumn.Length + 1) = pAutoColumn + ","
		              For Each pIndexEntry As DictionaryEntry In currentIndexes
		                If pIndexEntry.Key.StringValue = "PRIMARY" Then Continue
		                Var pIndexMeta As Dictionary = pIndexEntry.Value
		                Var pIndexColumns As String = pIndexMeta.Lookup("Columns", "").StringValue
		                If pIndexColumns = pAutoColumn Or pIndexColumns.Left(pAutoColumn.Length + 1) = pAutoColumn + "," Then pHasAutoIndex = True
		              Next
		              If Not pHasAutoIndex Then
		                Var pAutoIndexNumber As Integer = System.Random.InRange(1, 2147483647)
		                pPrimarySQL = pPrimarySQL + ", ADD INDEX `_orm_pk_auto_" + pAutoIndexNumber.ToString + "` (`" + pEntry.Key.StringValue.ReplaceAll("`", "``") + "`)"
		              End If
		            Next
		            // Do not keep the old uniqueness: expanding PRIMARY must allow its old prefix to repeat.
		            If pCurrentPrimary <> "" And MySQLIndexNeededByForeignKey("PRIMARY", pCurrentPrimary, currentForeignKeys) Then
		              Var pOldKeyColumns() As String
		              For Each pName As String In pCurrentPrimary.Split(",")
		                pOldKeyColumns.Add("`" + pName.ReplaceAll("`", "``") + "`")
		              Next
		              Var pSupportNumber As Integer = System.Random.InRange(1, 2147483647)
		              pPrimarySQL = pPrimarySQL + ", ADD INDEX `_orm_pk_support_" + pSupportNumber.ToString + "` (" + String.FromArray(pOldKeyColumns, ",") + ")"
		            End If
		            // Let the server reject an incompatible referenced key; never force orphaning.
		            pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		            pDatabase.ExecuteSQL(pPrimarySQL)
		            pPrimaryApplied = True
		            Var pRemoved As Integer
		            For Each pPlan As Dictionary In pDeletedPlans
		              pRemoved = pRemoved + pPlan.Value("RemoveCount").IntegerValue
		            Next
		            mLogs = mLogs + "Primary key migrated on " + Me.TableName + "; older or identical duplicate rows removed: " + pRemoved.ToString + EndOfLine
		          Catch Error As RuntimeException
		            If Not pPrimaryApplied Then
		              If pDeletedPlans.LastIndex >= 0 Then
		                Try
		                  // A pre-DDL failure can still roll back; failed DDL may already have committed.
		                  pDatabase.ExecuteSQL("ROLLBACK")
		                  pDatabase.ExecuteSQL("LOCK TABLES " + pQuotedTable + " WRITE, `" + pBackupTable + "` WRITE")
		                Catch pRecoveryLockError As RuntimeException
		                  pRestoreFailed = True
		                  mLogs = mLogs + "Recovery requires retained backup: " + pBackupTable + " - " + pRecoveryLockError.Message + EndOfLine
		                End Try
		              End If
		              For Each pPlan As Dictionary In pDeletedPlans
		                If pRestoreFailed Then Exit For
		                Try
		                  Var pParameters() As Variant = pPlan.Value("Parameters")
		                  Var pOriginalCount As Integer = pPlan.Value("RemoveCount").IntegerValue + 1
		                  Var pRecoveryRows As RowSet = pDatabase.SelectSQL("SELECT COUNT(*) FROM " + pQuotedTable + " WHERE " + pPlan.Value("WhereSQL").StringValue, pParameters)
		                  Var pRecoveryCount As Integer = pRecoveryRows.ColumnAt(0).IntegerValue
		                  pRecoveryRows.Close
		                  // A rejected DELETE changed nothing; a committed DELETE leaves one winner.
		                  If pRecoveryCount = 1 Then
		                    pDatabase.ExecuteSQL("INSERT INTO " + pQuotedTable + " (" + pColumnList + ") SELECT " + pColumnList + " FROM `" + pBackupTable + "` WHERE " + pPlan.Value("WhereSQL").StringValue, pParameters)
		                    pRecoveryRows = pDatabase.SelectSQL("SELECT COUNT(*) FROM " + pQuotedTable + " WHERE " + pPlan.Value("WhereSQL").StringValue, pParameters)
		                    pRecoveryCount = pRecoveryRows.ColumnAt(0).IntegerValue
		                    pRecoveryRows.Close
		                  End If
		                  If pRecoveryCount <> pOriginalCount Then Raise New ORMException("Unexpected row count while recovering duplicate rows.")
		                  
		                Catch pRestoreError As RuntimeException
		                  pRestoreFailed = True
		                  mLogs = mLogs + "Duplicate recovery failed; retained backup: " + pBackupTable + " - " + pRestoreError.Message + EndOfLine
		                End Try
		              Next
		            End If
		            DebugLog "PrimaryKey on  " + Me.TableName + " error : " + Error.Message
		            mLogs = mLogs + "PrimaryKey on  " + Me.TableName + " error : " + Error.Message + EndOfLine
		            schemaUpdateError = True
		          Finally
		            Try
		              If pAutocommitChanged Then pDatabase.ExecuteSQL("COMMIT")
		              pDatabase.ExecuteSQL("UNLOCK TABLES;")
		              If pBackupCreated And Not pRestoreFailed Then pDatabase.ExecuteSQL("DROP TABLE `" + pBackupTable + "`")
		            Catch pCleanupError As RuntimeException
		              mLogs = mLogs + "Primary key cleanup on " + Me.TableName + ": " + pCleanupError.Message + EndOfLine
		              schemaUpdateError = True
		            End Try
		            If pAutocommitChanged Then pDatabase.ExecuteSQL("SET autocommit = " + pOriginalAutocommit.ToString)
		            pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		          End Try
		          If schemaUpdateError Then Return False
		          // Read the actual constraint after unlocking, not a synthesized cache entry.
		          currentIndexes = MySQLCurrentIndexes(pDatabase)
		          Var pVerifiedColumns As String
		          If currentIndexes.HasKey("PRIMARY") Then
		            Var pVerifiedPrimary As Dictionary = currentIndexes.Value("PRIMARY")
		            pVerifiedColumns = pVerifiedPrimary.Lookup("Columns", "").StringValue
		          End If
		          If pVerifiedColumns <> pExpectedPrimary Then
		            mLogs = mLogs + "Primary key verification failed on " + Me.TableName + EndOfLine
		            Return False
		          End If
		        End If
		        Try
		          pDatabase.ExecuteSQL("LOCK TABLES " + me.TableName + " WRITE;")
		        Catch lockError As DatabaseException
		          mLogs = mLogs + "LOCK TABLES on " + Me.TableName + " : " + lockError.Message + EndOfLine
		          pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		          Return False
		        End Try
		        try
		          if HasUniqueKeys then
		            // Opted-in internal documents require a real UNIQUE constraint after number repair.
		            // Other legacy models retain their existing index compatibility policy.
		            if Not MySQLHasIndexColumns(currentIndexes, mUniqueColumns, SchemaRenumberDuplicateNumbers) then
		              Var pUniqueColumns() As String = MySQLNormalizeIndexColumns(mUniqueColumns).Split(",")
		              Var pUniqueQuoted() As String
		              Var pNotNull() As String
		              For Each pName As String In pUniqueColumns
		                Var pQuoted As String = "`" + pName.ReplaceAll("`", "``") + "`"
		                pUniqueQuoted.Add(pQuoted)
		                pNotNull.Add(pQuoted + " IS NOT NULL")
		              Next
		              Var pConflicts As RowSet = pDatabase.SelectSQL("SELECT COUNT(*) FROM (SELECT 1 FROM `" + Me.TableName.ReplaceAll("`", "``") + "` WHERE " + String.FromArray(pNotNull, " AND ") + " GROUP BY " + String.FromArray(pUniqueQuoted, ",") + " HAVING COUNT(*)>1) AS unique_conflicts")
		              Var pConflictCount As Integer = pConflicts.ColumnAt(0).IntegerValue
		              pConflicts.Close
		              If pConflictCount > 0 Then
		                If Not RepairDuplicateDocumentNumbers(pDatabase, pUniqueColumns) Then Raise New ORMException("Cannot apply legacy uniqueness on " + Me.TableName + "; duplicate values require review.")
		              End If
		              DebugLog mUniqueKeys.Left(mUniqueKeys.Length - 1) + ");"
		              pDatabase.ExecuteSQL(mUniqueKeys.Left(mUniqueKeys.Length - 1) + ");")
		              dim uniqueMeta as new Dictionary
		              uniqueMeta.Value("Columns") = MySQLNormalizeIndexColumns(mUniqueColumns)
		              uniqueMeta.Value("NonUnique") = false
		              currentIndexes.Value(mUniqueIndexName) = uniqueMeta
		            end if
		          end if
		        Catch Error As RuntimeException
		          If Error IsA EndException Or Error IsA ThreadEndException Then Raise Error
		          DebugLog "UniqueKey on  "+me.TableName+" error : " + Error.Message
		          mLogs =  mlogs + "UniqueKey on  "+me.TableName+" error : " + Error.Message + EndOfLine
		          schemaUpdateError = True
		        end try
		        If schemaUpdateError Then Return False
		        
		        if SchemaUniqueIndex <> nil then
		          for each dUnique as DictionaryEntry in SchemaUniqueIndex
		            dim uniqueFields() as String = dUnique.Value
		            if uniqueFields.LastIndex >= 0 then
		              dim desiredColumns as String = MySQLNormalizeIndexColumns(String.FromArray(uniqueFields, ","))
		              dim uniqueIndexName as String = dUnique.Key.StringValue
		              
		              if Not MySQLHasIndexColumns(currentIndexes, desiredColumns, true) then
		                if MySQLIndexExists(currentIndexes, uniqueIndexName) then
		                  DebugLog "Unique index " + uniqueIndexName + " on " + me.TableName + " has incompatible columns or is not unique."
		                  mLogs = mLogs + "Unique index " + uniqueIndexName + " on " + me.TableName + " has incompatible columns or is not unique." + EndOfLine
		                  uniqueIndexError = true
		                else
		                  dim uniqueSQL as String = "ALTER TABLE `" + me.TableName + "` ADD UNIQUE INDEX `" + uniqueIndexName + "` ("
		                  For Each fieldName As String In uniqueFields
		                    uniqueSQL = uniqueSQL + "`" + fieldName + "`,"
		                  Next
		                  uniqueSQL = uniqueSQL.Left(uniqueSQL.Length - 1) + ");"
		                  
		                  Try
		                    DebugLog uniqueSQL
		                    pDatabase.ExecuteSQL(uniqueSQL)
		                    dim uniqueMeta as new Dictionary
		                    uniqueMeta.Value("Columns") = desiredColumns
		                    uniqueMeta.Value("NonUnique") = false
		                    currentIndexes.Value(uniqueIndexName) = uniqueMeta
		                  Catch error As DatabaseException
		                    DebugLog "Unique index " + uniqueIndexName + " on " + me.TableName + " error : " + error.Message
		                    mLogs = mLogs + "Unique index " + uniqueIndexName + " on " + me.TableName + " error : " + error.Message + EndOfLine
		                    uniqueIndexError = true
		                  End Try
		                end if
		              end if
		            end if
		          next
		        end if
		        
		        
		        // INDEXING DB
		        for each dField as DictionaryEntry in SchemaIndex
		          dim fields() as string = dField.Value
		          dim desiredColumns as String = MySQLNormalizeIndexColumns(Join(fields, ","))
		          
		          if Not MySQLIndexExists(currentIndexes, dField.Key.StringValue) and Not MySQLHasIndexColumns(currentIndexes, desiredColumns) then
		            Dim sql As String
		            
		            sql = "ALTER TABLE `"+me.TableName+"` ADD INDEX `"+ dField.Key + "`  ( "
		            
		            For Each name As String In fields
		              sql = sql + "`"+ name + "`, " 
		            Next
		            
		            sql = sql.Left(sql.Length - 2) + ");"
		            
		            try
		              DebugLog sql
		              pDatabase.ExecuteSQL(sql)
		              dim indexMeta as new Dictionary
		              indexMeta.Value("Columns") = desiredColumns
		              indexMeta.Value("NonUnique") = true
		              currentIndexes.Value(dField.Key.StringValue) = indexMeta
		            Catch Error as DatabaseException
		              DebugLog "Indexing on  "+me.TableName+" error : " + Error.Message
		              mLogs =  mlogs + "Indexing on  "+me.TableName+" error : " + Error.Message + EndOfLine
		              schemaUpdateError = True
		            end try
		          end if
		          
		        next
		        
		        For Each indexEntry As DictionaryEntry In SchemaIndexes
		          // Legacy unique indexes were validated above, including equivalent names.
		          If SchemaUniqueIndex <> Nil Then
		            If SchemaUniqueIndex.HasKey(indexEntry.Key) Then Continue
		          End If
		          Var configuredIndex As ORMIndex = ORMIndex(indexEntry.Value)
		          Var indexName As String = indexEntry.Key.StringValue
		          Var configuredColumns As String = MySQLNormalizeIndexColumns(String.FromArray(configuredIndex.Columns, ","))
		          
		          If MySQLIndexExists(currentIndexes, indexName) Then
		            Var currentIndex As Dictionary = Dictionary(currentIndexes.Value(indexName))
		            Var currentColumns As String = currentIndex.Lookup("Columns", "").StringValue
		            Var currentUnique As Boolean = Not currentIndex.Lookup("NonUnique", True).BooleanValue
		            If currentColumns <> configuredColumns Or currentUnique <> configuredIndex.Unique Then
		              mInvalidIndexReport = "Index " + indexName + " on " + Me.TableName + " does not match its model definition."
		              mLogs = mLogs + mInvalidIndexReport + EndOfLine
		              Try
		                pDatabase.ExecuteSQL("UNLOCK TABLES;")
		              Catch unlockError As DatabaseException
		                DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		              End Try
		              pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		              Return False
		            End If
		          Else
		            Var addIndexSQL As String = "ALTER TABLE `" + Me.TableName + "` ADD " + SQLIndexDefinition(indexName, configuredIndex, False) + ";"
		            Try
		              DebugLog addIndexSQL
		              pDatabase.ExecuteSQL(addIndexSQL)
		              Var indexMeta As New Dictionary
		              indexMeta.Value("Columns") = configuredColumns
		              indexMeta.Value("NonUnique") = Not configuredIndex.Unique
		              currentIndexes.Value(indexName) = indexMeta
		            Catch error As DatabaseException
		              mLogs = mLogs + "Indexing on " + Me.TableName + " error : " + error.Message + EndOfLine
		              Try
		                pDatabase.ExecuteSQL("UNLOCK TABLES;")
		              Catch unlockError As DatabaseException
		                DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		              End Try
		              pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		              Return False
		            End Try
		          End If
		        Next
		        #Pragma BreakOnExceptions True
		        
		        Try
		          pDatabase.ExecuteSQL("UNLOCK TABLES;")
		        Catch unlockError As DatabaseException
		          DebugLog "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message
		          mLogs =  mlogs + "UNLOCK TABLES on " + me.TableName + " : " + unlockError.Message + EndOfLine
		        End Try
		        
		        For Each foreignKeyEntry As DictionaryEntry In SchemaForeignKeys
		          Var foreignKeyName As String = foreignKeyEntry.Key.StringValue
		          Var configuredForeignKey As ORMForeignKey = ORMForeignKey(foreignKeyEntry.Value)
		          If currentForeignKeys.HasKey(foreignKeyName) Then
		            If Not MySQLForeignKeyMatches(currentForeignKeys, foreignKeyName, configuredForeignKey) Then
		              mLogs = mLogs + "Foreign key " + foreignKeyName + " on " + Me.TableName + " does not match its model definition." + EndOfLine
		              pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		              Return False
		            End If
		          Else
		            Var addForeignKeySQL As String = "ALTER TABLE `" + Me.TableName + "` ADD " + SQLForeignKeyDefinition(foreignKeyName, configuredForeignKey) + ";"
		            Try
		              DebugLog addForeignKeySQL
		              pDatabase.ExecuteSQL(addForeignKeySQL)
		              Var foreignKeyMeta As New Dictionary
		              foreignKeyMeta.Value("Columns") = MySQLNormalizeIndexColumns(String.FromArray(configuredForeignKey.Columns, ","))
		              foreignKeyMeta.Value("ReferencedTable") = configuredForeignKey.ReferencedTable.Lowercase
		              foreignKeyMeta.Value("ReferencedColumns") = MySQLNormalizeIndexColumns(String.FromArray(configuredForeignKey.ReferencedColumns, ","))
		              foreignKeyMeta.Value("UpdateRule") = configuredForeignKey.OnUpdate.Uppercase
		              foreignKeyMeta.Value("DeleteRule") = configuredForeignKey.OnDelete.Uppercase
		              currentForeignKeys.Value(foreignKeyName) = foreignKeyMeta
		            Catch error As DatabaseException
		              mLogs = mLogs + "Foreign key on " + Me.TableName + " error : " + error.Message + EndOfLine
		              pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		              Return False
		            End Try
		          End If
		        Next
		        
		        pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1;")
		        if uniqueIndexError Or schemaUpdateError then
		          Return false
		        end if
		      Catch pSchemaError As RuntimeException
		        If pSchemaError IsA EndException Or pSchemaError IsA ThreadEndException Then Raise pSchemaError
		        mLogs = mLogs + "Schema update on " + Me.TableName + ": " + pSchemaError.Message + EndOfLine
		        Return False
		      Finally
		        Try
		          pDatabase.ExecuteSQL("UNLOCK TABLES;")
		        Catch pUnlockError As DatabaseException
		          mLogs = mLogs + "UNLOCK TABLES on " + Me.TableName + ": " + pUnlockError.Message + EndOfLine
		        End Try
		        pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = " + pOriginalForeignKeyChecks.ToString)
		      End Try
		    end if
		    
		  else
		    // Une reconstruction SQLite interrompue peut laisser la table temporaire en place.
		    // Toujours repartir de la table source avant la mise à jour du modèle.
		    Try
		      pDatabase.ExecuteSQL("DROP TABLE IF EXISTS `" + me.TableName + "_TMP`;")
		    Catch error As DatabaseException
		      DebugLog "Temporary table cleanup on " + me.TableName + " error: " + error.Message
		      mLogs = mLogs + "Temporary table cleanup on " + me.TableName + " error: " + error.Message + EndOfLine
		      Return False
		    End Try
		    
		    if SchemaToCreateTable then
		      if not CreateTable(pDatabase) then
		        return false
		      end if
		      if not InsertBaseData(pDatabase) then
		        return false
		      end if
		      return true
		    else
		      pDatabase.ExecuteSQL("PRAGMA legacy_alter_table=OFF;")
		      pDatabase.ExecuteSQL("PRAGMA foreign_keys = OFF;")
		      Var pNeedsDocumentNumberRepair As Boolean
		      If SchemaRenumberDuplicateNumbers Then
		        Var pNumberConflicts As RowSet = pDatabase.SelectSQL("SELECT 1 FROM `" + Me.TableName.ReplaceAll("`", "``") + "` WHERE `numero` IS NOT NULL AND `type` IS NOT NULL GROUP BY `numero`, `type` HAVING COUNT(*)>1 LIMIT 1")
		        pNeedsDocumentNumberRepair = Not pNumberConflicts.AfterLastRow
		        pNumberConflicts.Close
		      End If
		      
		      for each dField as DictionaryEntry in SchemaToAdd
		        Dim sql As String
		        
		        sql = "ALTER TABLE `"+me.TableName+"` ADD "
		        
		        dim field as ORMField = dField.Value
		        sql = sql + "`"+ dField.Key + "` " 
		        sql = sql + field.Type(pDatabase)
		        if field.Type = ORMField.TypeList.DECIMAL then  sql = sql + field.Length
		        sql = sql + " " + field.NotNull + " " + field.DefaultValue(pDatabase)
		        sql = sql + " " + field.Extra(pdatabase)
		        sql = sql +";"
		        
		        
		        try
		          pDatabase.ExecuteSQL(sql)
		        Catch Error as DatabaseException
		          DebugLog "DB error : " + Error.Message
		          mLogs = mLogs + "DB ADD " + Me.TableName + " error : " + Error.Message + EndOfLine
		          schemaUpdateError = True
		        end try
		      next
		      
		      If Not schemaUpdateError And (SchemaToAlter.KeyCount > 0 Or SchemaToRemoveColumn.KeyCount > 0 Or pNeedsDocumentNumberRepair) Then
		        pDatabase.ExecuteSQL("SAVEPOINT orm_schema_rebuild;")
		        Try
		          If SchemaRenumberDuplicateNumbers Then
		            Var pNumberColumns() As String = Array("numero", "type")
		            If Not RepairDuplicateDocumentNumbers(pDatabase, pNumberColumns) Then Raise New ORMException("Cannot repair internal document numbers on " + Me.TableName)
		          End If
		          Var pDuplicatePlans() As Dictionary = PrimaryKeyDuplicatePlan(pDatabase, pPrimaryColumns)
		          If pDuplicatePlans.LastIndex >= 0 Then
		            // DELETE triggers can remove unrelated history without leaving a foreign-key error.
		            Var pDependencyRows As RowSet = pDatabase.SelectSQL("SELECT (SELECT COUNT(*) FROM sqlite_master WHERE type = 'trigger' AND tbl_name = ?) + (SELECT COUNT(*) FROM sqlite_temp_master WHERE type = 'trigger' AND tbl_name = ?) + (SELECT COUNT(*) FROM sqlite_master AS m JOIN pragma_foreign_key_list(m.name) AS fk WHERE m.type = 'table' AND fk.`table` = ?) AS dependencies", Me.TableName, Me.TableName, Me.TableName)
		            Var pDependencies As Integer = pDependencyRows.ColumnAt(0).IntegerValue
		            pDependencyRows.Close
		            If pDependencies > 0 Then Raise New ORMException("Duplicate cleanup requires manual review of foreign keys or triggers on " + Me.TableName)
		          End If
		          Var pRemoved As Integer
		          For Each pPlan As Dictionary In pDuplicatePlans
		            Var pParameters() As Variant = pPlan.Value("Parameters")
		            Var pLimit As Integer = pPlan.Value("RemoveCount")
		            Var pDeleteSQL As String = "DELETE FROM `" + Me.TableName.ReplaceAll("`", "``") + "` WHERE _rowid_ IN (SELECT _rowid_ FROM `" + Me.TableName.ReplaceAll("`", "``") + "` WHERE " + pPlan.Value("WhereSQL").StringValue + pPlan.Value("OrderSQL").StringValue + " LIMIT " + pLimit.ToString + ")"
		            pDatabase.ExecuteSQL(pDeleteSQL, pParameters)
		            pRemoved = pRemoved + pLimit
		          Next
		          Var selectSQL As String = "SELECT "
		          Var collSelect As String
		          For Each dSelect as DictionaryEntry in  Schema
		            collSelect = collSelect +"`"+ dSelect.key + "`, "
		          Next
		          selectSQL = selectSQL + collSelect.Left(collSelect.Length -2)
		          
		          selectSQL = selectSQL + " FROM `" + me.TableName+"`;"
		          Var rr As RowSet = pDatabase.SelectSQL(selectSQL)
		          Var countrecord As Integer = rr.RowCount
		          Var insertSQL As String = "INSERT INTO `" + Me.TableName + "_TMP` (" + collSelect.Left(collSelect.Length - 2) + ") VALUES "
		          While Not rr.AfterLastRow
		            insertSQL = insertSQL + "("
		            For i As Integer = 0 To rr.LastColumnIndex
		              Var colVal As String
		              If rr.ColumnAt(i).Value <> Nil Then
		                If rr.ColumnAt(i).StringValue = "true" Or rr.ColumnAt(i).StringValue = "false" Then
		                  Var z As Integer = If(rr.ColumnAt(i).BooleanValue, 1, 0)
		                  colVal = z.ToString + ","
		                Else
		                  colVal = "'" + rr.ColumnAt(i).StringValue.ReplaceAll("'", "''") + "',"
		                End If
		              Else
		                colVal = "NULL,"
		              End If
		              insertSQL = insertSQL + colVal
		            Next
		            insertSQL = insertSQL.Left(insertSQL.Length - 1) + "),"
		            rr.MoveToNextRow
		          Wend
		          rr.Close
		          If countrecord > 0 Then insertSQL = insertSQL.Left(insertSQL.Length - 1) + ";"
		          // Include empty tables, and retain the original if any row is rejected.
		          // Old tables can still own index names ending in _TMP after a previous rebuild.
		          // Keep inline constraints, then create named indexes after replacing the source.
		          If Not CreateTable(pDatabase, "_TMP", False) Then Raise New ORMException("Cannot create replacement table for " + Me.TableName)
		          If countrecord > 0 Then pDatabase.ExecuteSQL(insertSQL)
		          Var rebuiltRows As RowSet = pDatabase.SelectSQL("SELECT COUNT(*) AS row_count FROM `" + Me.TableName + "_TMP`;")
		          Var rebuiltCount As Integer = rebuiltRows.Column("row_count").IntegerValue
		          rebuiltRows.Close
		          If rebuiltCount <> countrecord Then Raise New ORMException("Schema rebuild would lose rows in " + Me.TableName)
		          pDatabase.ExecuteSQL("DROP TABLE `" + Me.TableName + "`;")
		          pDatabase.ExecuteSQL("ALTER TABLE `" + Me.TableName + "_TMP` RENAME TO `" + Me.TableName + "`;")
		          If Not SQLiteCreateSchemaIndexes(pDatabase) Then Raise New ORMException("Cannot create replacement indexes for " + Me.TableName)
		          Var pForeignKeyRows As RowSet = pDatabase.SelectSQL("SELECT * FROM pragma_foreign_key_check WHERE `table` = ? OR parent = ?", Me.TableName, Me.TableName)
		          Var pForeignKeyError As Boolean = Not pForeignKeyRows.AfterLastRow
		          pForeignKeyRows.Close
		          If pForeignKeyError Then Raise New ORMException("Primary key migration would invalidate foreign keys on " + Me.TableName)
		          If pRemoved > 0 Then mLogs = mLogs + "Older or identical duplicate rows removed on " + Me.TableName + ": " + pRemoved.ToString + EndOfLine
		        Catch error As RuntimeException
		          pDatabase.ExecuteSQL("ROLLBACK TO SAVEPOINT orm_schema_rebuild;")
		          If error IsA EndException Or error IsA ThreadEndException Then Raise error
		          mLogs = mLogs + "Schema rebuild on " + Me.TableName + " error : " + error.Message + EndOfLine
		          schemaUpdateError = True
		        Finally
		          pDatabase.ExecuteSQL("RELEASE SAVEPOINT orm_schema_rebuild;")
		        End Try
		        
		      end if
		      pDatabase.ExecuteSQL("PRAGMA foreign_keys = ON;")
		      If schemaUpdateError Then Return False
		      
		      If SchemaRenumberDuplicateNumbers And Not SQLiteHasUniqueIndexColumns(pDatabase, "numero,type") Then
		        // A matching column schema can still be missing the internal-number constraint.
		        Var pNumberIndex As String = "_orm_document_numbers_" + Me.TableName
		        Try
		          pDatabase.ExecuteSQL("CREATE UNIQUE INDEX `" + pNumberIndex.ReplaceAll("`", "``") + "` ON `" + Me.TableName.ReplaceAll("`", "``") + "` (`numero`,`type`)")
		        Catch pNumberIndexError As RuntimeException
		          If pNumberIndexError IsA EndException Or pNumberIndexError IsA ThreadEndException Then Raise pNumberIndexError
		          mLogs = mLogs + "Internal number uniqueness on " + Me.TableName + ": " + pNumberIndexError.Message + EndOfLine
		          Return False
		        End Try
		        If Not SQLiteHasUniqueIndexColumns(pDatabase, "numero,type") Then Return False
		      End If
		      If Not SQLiteCreateSchemaIndexes(pDatabase) Then Return False
		      
		      dim uniqueIndexError as Boolean = false
		      if SchemaUniqueIndex <> nil then
		        for each dUnique as DictionaryEntry in SchemaUniqueIndex
		          dim uniqueFields() as String = dUnique.Value
		          if uniqueFields.LastIndex >= 0 then
		            dim desiredColumns as String = String.FromArray(uniqueFields, ",")
		            if Not SQLiteHasUniqueIndexColumns(pDatabase, desiredColumns) then
		              dim uniqueSQL as String = "CREATE UNIQUE INDEX IF NOT EXISTS `" + dUnique.Key.StringValue + "` ON `" + me.TableName + "` ("
		              For Each fieldName As String In uniqueFields
		                uniqueSQL = uniqueSQL + "`" + fieldName + "`,"
		              Next
		              uniqueSQL = uniqueSQL.Left(uniqueSQL.Length - 1) + ");"
		              
		              Try
		                DebugLog uniqueSQL
		                pDatabase.ExecuteSQL(uniqueSQL)
		                if Not SQLiteHasUniqueIndexColumns(pDatabase, desiredColumns) then
		                  DebugLog "Unique index " + dUnique.Key.StringValue + " on " + me.TableName + " was not created."
		                  mLogs = mLogs + "Unique index " + dUnique.Key.StringValue + " on " + me.TableName + " was not created." + EndOfLine
		                  uniqueIndexError = true
		                end if
		              Catch error As DatabaseException
		                DebugLog "Unique index " + dUnique.Key.StringValue + " on " + me.TableName + " error : " + error.Message
		                mLogs = mLogs + "Unique index " + dUnique.Key.StringValue + " on " + me.TableName + " error : " + error.Message + EndOfLine
		                uniqueIndexError = true
		              End Try
		            end if
		          end if
		        next
		      end if
		      if uniqueIndexError then
		        Return false
		      end if
		      
		    end if
		    
		  end if
		  if not SyncBaseDataAfterTableUpdate(pDatabase) then
		    return false
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function TouchEditLock(pDatabase As Database, durationMinutes As Integer = 30) As Boolean
		  If Not ShouldUseRecordLock Then Return False
		  
		  Return ModelORMRecordLock.TouchForORM(pDatabase, Me, ORM.CurrentEditSessionKey, durationMinutes)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617274206F66205265706F7274732E44617461536574
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
		    
		    'For Each pPrimaryKey As String In PrimaryKeys
		    'If mData.HasKey(pPrimaryKey) Then
		    'mData.Remove(pPrimaryKey)
		    'End If
		    'If mChanged.HasKey(pPrimaryKey) then
		    'mChanged.Remove(pPrimaryKey)
		    'End If
		    'If mRemoved.HasKey(pPrimaryKey) then
		    'mRemoved.Remove(pPrimaryKey)
		    'End If
		    'If mAdded.HasKey(pPrimaryKey) then
		    'mAdded.Remove(pPrimaryKey)
		    'End If
		    'Next
		    
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
		    
		    mRelations = nil
		    mRelations = new Dictionary
		    
		    RaiseEvent UnloadedAll
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Update() As Dictionary
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not me.Loaded then
		    Raise new ORMException("Cannot update " + me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    
		    
		    Dim pChanged As Dictionary = me.Pks
		    
		    'Take only columns defined in the model
		    For Each pColumn As DictionaryEntry In me.TableColumns()
		      If me.mChanged.HasKey(pColumn.Key) Then
		        pChanged.Value(pColumn.Key) = me.mChanged.Value(pColumn.Key)
		      End If
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    me.mChanged.RemoveAll
		    
		    dim nRelations as Dictionary
		    
		    For each dRelations as DictionaryEntry in me.mRelations
		      dim nORMs() as ORM = dRelations.Value
		      dim dORMdata() as Dictionary
		      for each nORM as ORM in nORMs
		        dORMdata.Add(nORM.Save)
		      Next
		      nRelations.Value(dRelations.Key) = dORMdata
		    Next
		    
		    pChanged.Value("relations") = nRelations
		    
		    
		    // Clear pending relationships
		    //mAdded.Clear()
		    me.mAdded = nil
		    me.mAdded = new Dictionary
		    
		    // AAAAAARRRRRRGGGGGGHHHHHHHH !!!!!!   // not the first time ?
		    //mRemoved.Clear()
		    me.mRemoved = nil
		    me.mRemoved = new Dictionary
		    
		    
		    RaiseEvent Updated()
		    return pChanged
		  End If
		  
		  Return nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Update(pDatabase As Database) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    Call ValidateEditLock(pDatabase, "update")
		    
		    If Not ExternalTransaction Then pDatabase.BeginTransaction
		    
		    Dim pChanged As New Dictionary
		    
		    // Take only columns defined in the model
		    For Each pColumn As Variant In Me.TableColumns(pDatabase).Keys
		      If mChanged.HasKey(pColumn.StringValue) Then
		        pChanged.Value(pColumn.StringValue) = mChanged.Value(pColumn.StringValue)
		      End If
		    Next
		    
		    If pChanged.KeyCount > 0 Then
		      #If DebugBuild Then
		        DebugLog DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Compile
		      #EndIf
		      DB.Update(Me.TableName).Set(pChanged).Where(Me.Pks).Execute(pDatabase, False)
		    End If
		    
		    // Merge mData with mChanged
		    For Each pKey As Variant In mChanged.Keys
		      mData.Value(pKey) = mChanged.Value(pKey)
		    Next
		    
		    // Clear mChanged, they are merged in mData
		    mChanged.RemoveAll
		    
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
		    
		    If Not ExternalTransaction Then pDatabase.CommitTransaction
		    
		    RaiseEvent Updated()
		    
		  End If
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit)) or  (TargetAndroid and (Target64Bit))
		Function Update(pDatabase As SQLiteDatabase) As ORM
		  // Use Save, which decides what should be called bewteen Update and Create instead of this method directly.
		  
		  If Not Me.Loaded then
		    Raise new ORMException("Cannot update " + Me.TableName + " model because it is not loaded.")
		  End If
		  
		  If Not RaiseEvent Updating() Then
		    Call ValidateEditLock(pDatabase, "update")
		    
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
		    mChanged.RemoveAll
		    
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

	#tag Method, Flags = &h21
		Private Sub ValidateEditLock(pDatabase As Database, actionName As String)
		  #Pragma Unused actionName
		  
		  If Not ShouldUseRecordLock Then Return
		  
		  Dim activeLock As ModelORMRecordLock = ModelORMRecordLock.LockedByOtherSession(pDatabase, Me, ORM.CurrentEditSessionKey)
		  If activeLock <> Nil Then
		    Raise New ORMException("La fiche " + Me.TableName + " est verrouillee par " + LockOwnerName(activeLock) + ".")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(ParamArray pValues() As Variant) As ORM
		  Call Super.Values(pValues, True)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant, pUseArray As Boolean = True) As ORM
		  Call Super.Values(pValues, pUseArray)
		  
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
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
		BaseDataMandatorySyncEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Shared CurrentEditSessionKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Shared CurrentEditUsername As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Shared CurrentEditUtilisateurNo As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ExternalTransaction As Boolean = False
	#tag EndProperty

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

	#tag Property, Flags = &h0
		mInvalidIndexReport As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mRelations As Dictionary
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
		Shared RecordLocksEnabled As Boolean = True
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
		SchemaForeignKeys As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaIndex As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaIndexes As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaMadantoryData() As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		SchemaRenumberDuplicateNumbers As Boolean = False
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

	#tag Property, Flags = &h0
		SchemaUniqueIndex As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		UpdateCacheThread As Thread
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="hasHandler"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
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
		#tag ViewProperty
			Name="BaseDataMandatorySyncEnabled"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mInvalidIndexReport"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ExternalTransaction"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SchemaRenumberDuplicateNumbers"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
