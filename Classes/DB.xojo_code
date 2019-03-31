#tag Module
Protected Module DB
	#tag Method, Flags = &h0
		Function Alias(pColumn As Auto, pAlias As Text) As QueryExpression
		  Return DB.Expression(QueryCompiler.Column(pColumn) + " AS " + QueryCompiler.Column(pAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Alias(pColumn as Auto, pAlias as Text, pType as DataType) As QueryExpression
		  Return DB.Expression(pColumn + " AS " + QueryCompiler.Column(pAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Begin(Extends pDatabase As Database)
		  // Begin a transaction
		  
		  If pDatabase IsA MySQLCommunityServer Then
		    pDatabase.SQLExecute("START TRANSACTION")
		  Else
		    pDatabase.SQLExecute("BEGIN TRANSACTION")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Begin(Extends pDatabase As iOSSQLiteDatabase)
		  // Begin a transaction
		  
		  pDatabase.SQLExecute("BEGIN TRANSACTION")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Coalesce(pColumn as Auto, pSubtitu as Integer = 0) As QueryExpression
		  Return DB.Expression("COALESCE( " + QueryCompiler.Column(pColumn)  + ", "+pSubtitu.ToText+" )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Connect(pURL As Text) As Database
		  // Perform a connection to a database and initialize the character set
		  //
		  // Providen url is in the format protocol://username:password@host:port/database
		  //
		  // For SQLite, the database field is used as a path to the database.
		  //
		  // Nil is returned if the connection cannot be performed.
		  
		  Dim pDatabase As Database
		  
		  Dim pRegEx As New RegEx
		  
		  // <1>://<2>:<3>@<4>:<5>/<6>
		  //
		  // 1. protocol
		  // 2. username
		  // 3. password
		  // 4. host
		  // 5. port
		  // 6. path
		  //7.  localpath
		  //pRegEx.SearchPattern = "(\w+):\/\/(?:(?:(\w+)(?::([\w+\[[:punct:]]+))@)?([\w\.]+)(?::(\d+))?\/)?([\/\w\W \.:\\-]+)?"
		  
		  pRegEx.SearchPattern = "(\w+)\:\/\/(?:(?:(.+?)(?:\:(.+?))?\@)?((?:[\w-éèàō]+\.)+[A-Za-z0-9]+)(?:\:(\d{2,5}))?(?:\/([\/\w\W \.:\\-]+)+))?([\/\w\W \.:\\-]+)?"
		  
		  Dim pMatch As RegExMatch = pRegEx.Search(pURL)
		  
		  If pMatch <> Nil Then
		    
		    // Configuration de la base de données
		    Select Case pMatch.SubExpressionString(1)
		      
		    Case "sqlite" // <protocol>:///<database>
		      
		      pDatabase = New SQLiteDatabase
		      
		      // Attempt each path type to match the database path
		      For Each pPathType As Integer In Array(FolderItem.PathTypeNative, FolderItem.PathTypeAbsolute, FolderItem.PathTypeShell)
		        
		        SQLiteDatabase(pDatabase).DatabaseFile = GetFolderItem(pMatch.SubExpressionString(7), pPathType)
		        
		        If SQLiteDatabase(pDatabase).DatabaseFile <> Nil and SQLiteDatabase(pDatabase).DatabaseFile.Exists Then
		          Exit
		        End If
		        
		      Next
		      
		      If pDatabase.Connect Then
		        
		        System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		        
		        pDatabase.SQLExecute("PRAGMA encoding = 'utf-8'")
		        pDatabase.SQLExecute("PRAGMA foreign_keys = ON")
		        
		        Return pDatabase
		        
		      End If
		      
		      System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		    Case "mysqlMBS" // <protocol>://((<username>):<password>@)<host>(:<port>)/<database>
		      //SQLDatabaseMBS MySQL : databasename = "<protocol>:<host>:<port>@<database>"
		      
		      // UNCOMMENT THIS SECTION BELOW IF YOU INSTALLED MONKEYBREAD SQL PLUGIN
		      
		      'pDatabase = new SQLDatabaseMBS
		      '
		      'dim port as Text
		      'If pMatch.SubExpressionText(5) <> "" Then
		      'port = pMatch.SubExpressionText(5)
		      'Else
		      'port = "3306"
		      'End If
		      '
		      'pDatabase.DatabaseName = pMatch.SubExpressionText(1) + ":" + pMatch.SubExpressionText(4) + ":" + port + "@" + pMatch.SubExpressionText(6)
		      '
		      'pDatabase.UserName = pMatch.SubExpressionText(2)
		      'pDatabase.Password = pMatch.SubExpressionText(3)
		      '
		      'If pDatabase.Connect Then
		      '
		      'System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		      '
		      'pDatabase.SQLExecute("SET NAMES 'utf8'")
		      '
		      'Return pDatabase
		      '
		      'End If
		      '
		      'System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		    Case "mysql" // <protocol>://((<username>):<password>@)<host>(:<port>)/<database>
		      
		      pDatabase = New MySQLCommunityServer
		      
		      pDatabase.UserName = pMatch.SubExpressionText(2)
		      pDatabase.Password = pMatch.SubExpressionText(3)
		      pDatabase.Host = pMatch.SubExpressionText(4)
		      
		      If pMatch.SubExpressionText(5) <> "" Then
		        MySQLCommunityServer(pDatabase).Port = Val(pMatch.SubExpressionText(5))
		      Else
		        MySQLCommunityServer(pDatabase).Port = 3306
		      End If
		      
		      pDatabase.DatabaseName = pMatch.SubExpressionText(6)
		      
		      If pDatabase.Connect Then
		        
		        System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		        
		        pDatabase.SQLExecute("SET NAMES 'utf8'")
		        pDatabase.SQLExecute("SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))")
		        
		        Return pDatabase
		        
		      End If
		      
		      System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		    Case "postgresql"
		      
		      'pDatabase = New PostgreSQLDatabase
		      '
		      'pDatabase.UserName = pMatch.SubExpressionText(2)
		      'pDatabase.Password = pMatch.SubExpressionText(3)
		      'pDatabase.Host = pMatch.SubExpressionText(4)
		      '
		      'If pMatch.SubExpressionText(5) <> "" Then
		      'PostgreSQLDatabase(pDatabase).Port = Val(pMatch.SubExpressionText(5))
		      'Else
		      'PostgreSQLDatabase(pDatabase).Port = 5432
		      'End If
		      '
		      'pDatabase.DatabaseName = pMatch.SubExpressionText(6)
		      '
		      'If pDatabase.Connect Then
		      '
		      'System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		      '
		      'pDatabase.SQLExecute("SET NAMES 'utf8'")
		      '
		      'Return pDatabase
		      '
		      'End If
		      '
		      'System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		    End Select
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Connect(pURL As Text) As iOSSQLiteDatabase
		  // Perform a connection to a database and initialize the character set
		  //
		  // Providen url is in the format protocol://username:password@host:port/database
		  //
		  // For SQLite, the database field is used as a path to the database.
		  //
		  // Nil is returned if the connection cannot be performed.
		  
		  Dim pDatabase As iOSSQLiteDatabase
		  
		  Dim pRegEx As New JKRegEx.RegEx
		  
		  // <1>://<2>:<3>@<4>:<5>/<6>
		  //
		  // 1. protocol
		  // 2. username
		  // 3. password
		  // 4. host
		  // 5. port
		  // 6. path
		  //7.  localpath
		  //pRegEx.SearchPattern = "(\w+):\/\/(?:(?:(\w+)(?::([\w+\[[:punct:]]+))@)?([\w\.]+)(?::(\d+))?\/)?([\/\w\W \.:\\-]+)?"
		  
		  pRegEx.SearchPattern = "(\w+)\:\/\/(?:(?:(.+?)(?:\:(.+?))?\@)?((?:[\w-éèàō]+\.)+[A-Za-z0-9]+)(?:\:(\d{2,5}))?(?:\/([\/\w\W \.:\\-]+)+))?([\/\w\W \.:\\-]+)?"
		  
		  Dim pMatch As JKRegEx.RegExMatch = pRegEx.Search(pURL)
		  
		  If pMatch <> Nil Then
		    
		    // Configuration de la base de données
		    Select Case pMatch.SubExpressionString(1)
		      
		    Case "sqlite" // <protocol>:///<database>
		      
		      pDatabase = New iOSSQLiteDatabase
		      
		      // Attempt each path type to match the database path
		      
		      
		      iOSSQLiteDatabase(pDatabase).DatabaseFile = new FolderItem(pMatch.SubExpressionString(7))
		      
		      If iOSSQLiteDatabase(pDatabase).DatabaseFile <> Nil and iOSSQLiteDatabase(pDatabase).DatabaseFile.Exists Then
		      else
		        Return Nil
		      End If
		      
		      
		      If pDatabase.Connect Then
		        
		        'System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		        
		        pDatabase.SQLExecute("PRAGMA encoding = 'utf-8'")
		        pDatabase.SQLExecute("PRAGMA foreign_keys = ON")
		        
		        Return pDatabase
		        
		      End If
		      
		      'System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		      
		    End Select
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As QueryExpression
		  Return DB.Count("*")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(pColumn As Auto) As QueryExpression
		  Return DB.Expression("COUNT( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(pColumn As Auto, pAlias As Text) As QueryExpression
		  Return DB.Alias(DB.Count(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(pTableName As Text) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new DeleteQueryExpression(pTableName))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Distinct(pColumn As Auto) As QueryExpression
		  Return DB.Expression("DISTINCT ( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Expression(pExpression As Text) As QueryExpression
		  Return new ExpressionQueryExpression(pExpression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Extract(pRecordSet as iOSSQLiteRecordSet, pIndex as Integer, pDB as iOSSQLiteDatabase) As Auto
		  // Properly extract a DatabaseField from a RecordSet
		  
		  // Internaly, the ORM uses Auto to store its data in a Dictionary,
		  // so it has to extract data properly at some time. It is the purpose
		  // of this function.
		  
		  
		  
		  Dim pDatabaseFieldName as Text = pRecordSet.IdxField(pIndex).Name  // base 1
		  Dim pDatabaseFieldValue as Auto = pRecordSet.IdxField(pIndex).Value  // base 1
		  Dim pColumnType As Integer = pRecordSet.ColumnType(pIndex - 1)  // ZERO base
		  
		  // juste pour tester
		  'if pDatabaseFieldName = "montant" then
		  'System.DebugLog pDatabaseFieldValue
		  'End If
		  '
		  'if  then
		  'MsgBox pDatabaseField.NativeValue
		  'MsgBox pColumnType.TextValue
		  'end if
		  
		  
		  // Set encoding to UTF8 for Text
		  'If pDatabaseFieldValue.Type = Auto.TypeText Then
		  'Return pDatabaseFieldValue.TextValue.DefineEncoding(Encodings.UTF8)
		  'End If
		  
		  return pDatabaseFieldValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Extract(pRecordSet As RecordSet, pIndex As Integer) As Auto
		  // Properly extract a DatabaseField from a RecordSet
		  
		  // Internaly, the ORM uses Auto to store its data in a Dictionary,
		  // so it has to extract data properly at some time. It is the purpose
		  // of this function.
		  
		  
		  
		  Dim pDatabaseFieldName as String = pRecordSet.IdxField(pIndex).Name  // base 1
		  Dim pDatabaseFieldValue as Variant = pRecordSet.IdxField(pIndex).Value  // base 1
		  Dim pColumnType As Integer = pRecordSet.ColumnType(pIndex - 1)  // ZERO base
		  
		  // juste pour tester
		  'if pDatabaseFieldName = "montant" then
		  'System.DebugLog pDatabaseFieldValue
		  'End If
		  '
		  'if  then
		  'MsgBox pDatabaseField.NativeValue
		  'MsgBox pColumnType.TextValue
		  'end if
		  // *******************************
		  // NOTE :  // IF YOU HAVE PROBLEM WITH DATATYPE, USE RecordSet WITH pDB Parameter constructor of your MODEL, this part is a patch because the current MysQL plugin made a mess with some kind of data
		  // *******************************
		  // Perform type detection for unknown data type
		  If pColumnType = -1  Then // patch de marde car Xojo est trop nono pour voir les chiffres
		    If IsNumeric(pDatabaseFieldValue) Then
		      'System.DebugLog pDatabaseField.CurrencyValue.ToText
		      Return pDatabaseFieldValue.CurrencyValue
		    End If
		  End If
		  
		  // Correction caca pour SQLite
		  'If pColumnType = 19 and  Company.Current.Database isa SQLiteDatabase and pDatabaseFieldName = "montant" Then
		  'if NOT (pDatabaseFieldValue.DoubleValue > 0.0001 OR pDatabaseFieldValue.DoubleValue <-0.0001 OR pDatabaseFieldValue.DoubleValue = 0.0000) then
		  'dim cc as currency = 0.0000
		  'Return cc
		  'End If
		  'End If
		  
		  If pColumnType = 11 Then
		    Return pDatabaseFieldValue.CurrencyValue
		  End If
		  
		  If pColumnType = 13 Then
		    Return pDatabaseFieldValue.CurrencyValue
		  End If
		  
		  // Set encoding to UTF8 for Text
		  If pDatabaseFieldValue.Type = Variant.TypeText Then
		    Return pDatabaseFieldValue.StringValue.DefineEncoding(Encodings.UTF8)
		  End If
		  
		  return pDatabaseFieldValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Extract(pRecordSet as RecordSet, pIndex as Integer, pDB as Database) As Auto
		  // Properly extract a DatabaseField from a RecordSet
		  
		  // Internaly, the ORM uses Auto to store its data in a Dictionary,
		  // so it has to extract data properly at some time. It is the purpose
		  // of this function.
		  
		  
		  
		  Dim pDatabaseFieldName as string = pRecordSet.IdxField(pIndex).Name  // base 1
		  Dim pDatabaseFieldValue as Variant = pRecordSet.IdxField(pIndex).Value  // base 1
		  Dim pColumnType As Integer = pRecordSet.ColumnType(pIndex - 1)  // ZERO base
		  
		  // juste pour tester
		  'if pDatabaseFieldName = "montant" then
		  'System.DebugLog pDatabaseFieldValue
		  'End If
		  '
		  'if  then
		  'MsgBox pDatabaseField.NativeValue
		  'MsgBox pColumnType.TextValue
		  'end if
		  // *******************************
		  // NOTE : Change "Company.Current.Database" to your DATABASE, this part is a patch because the current MysQL plugin made a mess with some kind of data
		  // *******************************
		  // Perform type detection for unknown data type
		  If pColumnType = -1 and pDB isa MySQLCommunityServer  Then // patch de marde car Xojo est trop nono pour voir les chiffres
		    If IsNumeric(pDatabaseFieldValue) Then
		      'System.DebugLog pDatabaseField.CurrencyValue.ToText
		      Return pDatabaseFieldValue.CurrencyValue
		    End If
		  End If
		  
		  // Correction caca pour SQLite
		  'If pColumnType = 19 and  pDB isa SQLiteDatabase and pDatabaseFieldName = "montant" Then
		  'if NOT (pDatabaseFieldValue.DoubleValue > 0.0001 OR pDatabaseFieldValue.DoubleValue <-0.0001 OR pDatabaseFieldValue.DoubleValue = 0.0000) then
		  'dim cc as currency = 0.0000
		  'Return cc
		  'End If
		  'End If
		  
		  If pColumnType = 11 and pDB isa MySQLCommunityServer Then
		    Return pDatabaseFieldValue.CurrencyValue
		  End If
		  
		  If pColumnType = 13 and pDB isa MySQLCommunityServer Then
		    Return pDatabaseFieldValue.CurrencyValue
		  End If
		  
		  // Set encoding to UTF8 for Text
		  If pDatabaseFieldValue.Type = Variant.TypeText Then
		    Return pDatabaseFieldValue.StringValue.DefineEncoding(Encodings.UTF8)
		  End If
		  
		  return pDatabaseFieldValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Extract(pRecordSet as RecordSet, pIndex as Integer, pColumnType as Integer) As Auto
		  // Properly extract a DatabaseField from a RecordSet
		  
		  // Internaly, the ORM uses Auto to store its data in a Dictionary,
		  // so it has to extract data properly at some time. It is the purpose
		  // of this function.
		  
		  // use colomns exception for extracting data for MySQLplugin that can not manage column type !
		  
		  'Dim pDatabaseField As DatabaseField = pRecordSet.IdxField(pIndex).Name
		  'Dim pDatabaseFieldName as Text = pRecordSet.IdxField(pIndex).Name  // base 1
		  Dim pDatabaseFieldValue as Variant = pRecordSet.IdxField(pIndex).Value  // base 1
		  'Dim pCurrentColumnType As Integer = pRecordSet.ColumnType(pIndex - 1)  // ZERO base
		  
		  // juste pour tester
		  'if pDatabaseFieldName = "compte" then
		  'MsgBox pCurrentColumnType.TextValue + "  " + pDatabaseFieldValue.TextValue
		  'End If
		  
		  'if  then
		  'MsgBox pDatabaseField.NativeValue
		  'MsgBox pColumnType.TextValue
		  'end if
		  if pDatabaseFieldValue <> nil then
		    
		    Select Case pColumnType
		    Case 4, 5, 15, 16, 18
		      Return pDatabaseFieldValue.StringValue.DefineEncoding(Encodings.UTF8)
		    Case 12
		      Return pDatabaseFieldValue.BooleanValue
		    Case 11, 13
		      Return pDatabaseFieldValue.CurrencyValue
		    Case 8, 10
		      Return pDatabaseFieldValue.DateValue
		    Case 7
		      Return pDatabaseFieldValue.DoubleValue
		    Case 2, 3, 19
		      Return pDatabaseFieldValue.IntegerValue
		    Case 14
		      Return pDatabaseFieldValue.TextValue
		    Else
		      If pDatabaseFieldValue.Type = Variant.TypeText Then
		        Return pDatabaseFieldValue.StringValue.DefineEncoding(Encodings.UTF8)
		      else
		        return pDatabaseFieldValue
		      End If
		    End Select
		    
		  else
		    return pDatabaseFieldValue
		    
		  end if
		  
		  return pDatabaseFieldValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pColumns() As Auto) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(New SelectQueryExpression(pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(ParamArray pColumns As Auto) As QueryBuilder
		  If pColumns.UBound = -1 Then
		    // Find * when no columns are specified
		    Return DB.Find(DB.Expression("*"))
		  End If
		  
		  Return DB.Find(pColumns)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As Text, pColumns() As Auto) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new InsertQueryExpression(pTableName, pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As Text, ParamArray pColumns As Auto) As QueryBuilder
		  Return Insert(pTableName, pColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Max(pColumn As Auto) As QueryExpression
		  Return DB.Expression("COALESCE( " + DB.Expression("MAX( " + QueryCompiler.Column(pColumn) + " )").Compile + ", 0 )")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Max(pColumn As Auto, pAlias As Text) As QueryExpression
		  Return DB.Alias(DB.Max(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Max(pColumn as Auto, pAlias as Text, pRound as integer) As QueryExpression
		  Return DB.Alias(DB.Round(DB.Max(pColumn), pRound), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Min(pColumn As Auto) As QueryExpression
		  Return DB.Expression("COALESCE( " + DB.Expression("MIN( " + QueryCompiler.Column(pColumn) + " )").Compile + ", 0 )")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Min(pColumn As Auto, pAlias As Text) As QueryExpression
		  Return DB.Alias(DB.Min(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Min(pColumn as Auto, pAlias as Text, pRound as integer) As QueryExpression
		  Return DB.Alias(DB.Round(DB.Min(pColumn), pRound), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Replace(pTableName As Text, pColumns() As Auto) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new ReplaceQueryExpression(pTableName, pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Replace(pTableName As Text, ParamArray pColumns As Auto) As QueryBuilder
		  Return Replace(pTableName, pColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Round(pColumn as Auto, pSubtitu as Integer = 4) As QueryExpression
		  Return DB.Expression("ROUND( " + QueryCompiler.Column(pColumn)  + ", "+pSubtitu.ToText+" )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues() As Auto) As QueryExpression
		  Return new ExpressionQueryExpression("(" + QueryCompiler.Values(pValues) + ")")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(ParamArray pValues As Auto) As QueryExpression
		  Return Set(pValues)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sum(pColumn As Auto) As QueryExpression
		  Return DB.Expression("SUM( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sum(pColumn As Auto, pAlias As Text) As QueryExpression
		  // Create a SUM expression with an alias
		  Return DB.Alias(DB.Sum(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Auto) As QueryExpression
		  Return DB.Expression("COALESCE( " + DB.Sum(pColumn).Compile + ", 0 )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Auto, pAlias As Text) As QueryExpression
		  Return DB.Alias(DB.Total(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn as Auto, pAlias as Text, pRound as integer) As QueryExpression
		  Return DB.Alias(DB.Round(DB.Total(pColumn), pRound), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pTableName As Text) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new UpdateQueryExpression(pTableName))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(pValue As Auto) As QueryExpression
		  Return DB.Expression(QueryCompiler.Value(pValue))
		End Function
	#tag EndMethod


	#tag Note, Name = Current.Company
		
		// NOTE : Change "Company.Current.Database" to your DATABASE, this part is a patch because the current MysQL plugin made a mess with some kind of data
		
	#tag EndNote


	#tag Enum, Name = DataType, Type = Integer, Flags = &h0
		Expression
		  TextType
		  IntegerType
		  VarCharType
		  CharType
		  DoubleType
		  DateType
		  TimeType
		  TimeStampType
		  CurrencyType
		  BooleanType
		  DecimalType
		BlobType
	#tag EndEnum


	#tag ViewBehavior
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
End Module
#tag EndModule
