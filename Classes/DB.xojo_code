#tag Module
Protected Module DB
	#tag Method, Flags = &h0
		Function Alias(pColumn As Variant, pAlias As String) As QueryExpression
		  Return DB.Expression(QueryCompiler.Column(pColumn) + " AS " + QueryCompiler.Column(pAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Begin(Extends pDatabase As Database)
		  // Begin a transaction
		  
		  If pDatabase IsA MySQLCommunityServer Then
		    pDatabase.SQLExecute("START TRANSACTION")
		  Else 
		    pDatabase.SQLExecute("BEGIN TRANSACTION")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Connect(pURL As String) As Database
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
		  pRegEx.SearchPattern = "(\w+):\/\/(?:(?:(\w+)(?::([\w+\[[:punct:]]+))@)?([\w\.]+)(?::(\d+))?\/)?([\/\w\W \.:\\-]+)?"
		  
		  Dim pMatch As RegExMatch = pRegEx.Search(pURL)
		  
		  If pMatch <> Nil Then
		    
		    // Configuration de la base de données
		    Select Case pMatch.SubExpressionString(1)
		      
		    Case "sqlite" // <protocol>:///<database>
		      
		      pDatabase = New SQLiteDatabase
		      
		      // Attempt each path type to match the database path
		      For Each pPathType As Integer In Array(FolderItem.PathTypeNative, FolderItem.PathTypeAbsolute, FolderItem.PathTypeShell)
		        
		        SQLiteDatabase(pDatabase).DatabaseFile = GetFolderItem(pMatch.SubExpressionString(6))
		        
		        If SQLiteDatabase(pDatabase).DatabaseFile <> Nil Then
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
		      
		    Case "mysql" // <protocol>://((<username>):<password>@)<host>(:<port>)/<database>
		      
		      pDatabase = New MySQLCommunityServer
		      
		      pDatabase.UserName = pMatch.SubExpressionString(2)
		      pDatabase.Password = pMatch.SubExpressionString(3)
		      pDatabase.Host = pMatch.SubExpressionString(4)
		      
		      If pMatch.SubExpressionString(5) <> "" Then
		        MySQLCommunityServer(pDatabase).Port = Val(pMatch.SubExpressionString(5))
		      Else
		        MySQLCommunityServer(pDatabase).Port = 3306
		      End If
		      
		      pDatabase.DatabaseName = pMatch.SubExpressionString(6)
		      
		      If pDatabase.Connect Then
		        
		        System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		        
		        pDatabase.SQLExecute("SET NAMES 'utf8'")
		        
		        Return pDatabase
		        
		      End If
		      
		      System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
		    Case "postgresql"
		      
		      pDatabase = New PostgreSQLDatabase
		      
		      pDatabase.UserName = pMatch.SubExpressionString(2)
		      pDatabase.Password = pMatch.SubExpressionString(3)
		      pDatabase.Host = pMatch.SubExpressionString(4)
		      
		      If pMatch.SubExpressionString(5) <> "" Then
		        PostgreSQLDatabase(pDatabase).Port = Val(pMatch.SubExpressionString(5))
		      Else
		        PostgreSQLDatabase(pDatabase).Port = 5432
		      End If
		      
		      pDatabase.DatabaseName = pMatch.SubExpressionString(6)
		      
		      If pDatabase.Connect Then
		        
		        System.Log(System.LogLevelSuccess, "Connection to " + pURL + " has succeed.")
		        
		        pDatabase.SQLExecute("SET NAMES 'utf8'")
		        
		        Return pDatabase
		        
		      End If
		      
		      System.Log(System.LogLevelError, "Connexion to " + pURL + " has failed." + pDatabase.ErrorMessage)
		      
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
		Function Count(pColumn As Variant) As QueryExpression
		  Return DB.Expression("COUNT( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(pColumn As Variant, pAlias As String) As QueryExpression
		  Return DB.Alias(DB.Count(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new DeleteQueryExpression(pTableName))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Distinct(pColumn As Variant) As QueryExpression
		  Return DB.Expression("DISTINCT ( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Expression(pExpression As String) As QueryExpression
		  Return new ExpressionQueryExpression(pExpression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Extract(pRecordSet As RecordSet, pIndex As Integer) As Variant
		  // Properly extract a DatabaseField from a RecordSet
		  
		  // Internaly, the ORM uses Variant to store its data in a Dictionary,
		  // so it has to extract data properly at some time. It is the purpose
		  // of this function.
		  
		  Dim pDatabaseField As DatabaseField = pRecordSet.IdxField(pIndex)
		  Dim pColumnType As Integer = pRecordSet.ColumnType(pIndex)
		  
		  // Perform type detection for unknown data type
		  If pRecordSet.ColumnType(pIndex) = -1 Then
		    If IsNumeric(pDatabaseField.NativeValue) Then
		      Return pDatabaseField.CurrencyValue
		    End If
		  End If
		  
		  If pRecordSet.ColumnType(pIndex) = 11 Then
		    Return pDatabaseField.CurrencyValue
		  End If
		  
		  If pRecordSet.ColumnType(pIndex) = 13 Then
		    Return pDatabaseField.CurrencyValue
		  End If 
		  
		  // Set encoding to UTF8 for string
		  If pDatabaseField.Value.Type = Variant.TypeString Then
		    Return pDatabaseField.StringValue.DefineEncoding(Encodings.UTF8)
		  End If
		  
		  return pDatabaseField.Value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pColumns() As Variant) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(New SelectQueryExpression(pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(ParamArray pColumns As Variant) As QueryBuilder
		  If pColumns.UBound = -1 Then
		    // Find * when no columns are specified
		    Return DB.Find(DB.Expression("*"))
		  End If
		  
		  Return DB.Find(pColumns)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As String, pColumns() As Variant) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new InsertQueryExpression(pTableName, pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As String, ParamArray pColumns As Variant) As QueryBuilder
		  Return Insert(pTableName, pColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues() As Variant) As QueryExpression
		  Return new ExpressionQueryExpression("(" + QueryCompiler.Values(pValues) + ")")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(ParamArray pValues As Variant) As QueryExpression
		  Return Set(pValues)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sum(pColumn As Variant) As QueryExpression
		  Return DB.Expression("SUM( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sum(pColumn As Variant, pAlias As String) As QueryExpression
		  // Create a SUM expression with an alias
		  Return DB.Alias(DB.Sum(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Variant) As QueryExpression
		  Return DB.Expression("COALESCE( " + DB.Sum(pColumn).Compile + ", 0 )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Variant, pAlias As String) As QueryExpression
		  Return DB.Alias(DB.Total(pColumn), pAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new UpdateQueryExpression(pTableName))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(pValue As Variant) As QueryExpression
		  Return DB.Expression(QueryCompiler.Value(pValue))
		End Function
	#tag EndMethod


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
