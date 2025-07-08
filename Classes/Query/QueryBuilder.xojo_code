#tag Class
Protected Class QueryBuilder
Implements QueryExpression
	#tag Method, Flags = &h0
		Function AndHaving(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  Return Append(new AndHavingQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  Return Append(new AndWhereQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Append(pQueryBuilder As QueryBuilder) As QueryBuilder
		  // Append another QueryBuilder
		  Return Me.Append(pQueryBuilder.mQuery)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Append(pQueryExpressions() As QueryExpression) As QueryBuilder
		  For Each pQueryExpression As QueryExpression In pQueryExpressions
		    Call Append(pQueryExpression)
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Append(pQueryExpression As QueryExpression) As QueryBuilder
		  mQuery.Append(pQueryExpression)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  Dim pStatements() As String
		  Dim pNice As Integer
		  
		  // Sort statements
		  While pStatements.Ubound < mQuery.Ubound
		    
		    For i As Integer = 0 To mQuery.Ubound
		      
		      Dim pQueryExpression As QueryExpression = mQuery(i)
		      
		      If pQueryExpression.Nice() = pNice Then
		        pStatements.Append(pQueryExpression.Compile(pLastQueryExpression))
		        pLastQueryExpression = pQueryExpression
		      End If
		      
		    Next
		    
		    pNice = pNice + 1
		    
		  Wend
		  
		  
		  Return String.FromArray(pStatements, " ")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pQuery() As QueryExpression)
		  Me.mQuery = pQuery
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(ParamArray pQuery As QueryExpression)
		  Me.Constructor(pQuery)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy() As QueryBuilder
		  // Returns a copy of this QueryBuilder
		  
		  Dim pQueryBuilder As New QueryBuilder
		  
		  For Each pQueryExpression As QueryExpression In Me.mQuery
		    pQueryBuilder.mQuery.Append(pQueryExpression)
		  Next
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Execute(pDatabase As Database, pCommit As Boolean = True)
		  // Execute the QueryBuilder using ExecuteSQL,
		  // which will not get any result from the database
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As String = Compile
		    
		    Try
		      pDatabase.ExecuteSQL(pStatement)
		      
		    Catch dberror As DatabaseException
		      // DB Connection error
		      Raise New ORMException(dberror.message, pStatement, dberror.ErrorNumber)
		    End Try
		    
		    'If pCommit Then
		    'try
		    'pDatabase.CommitTransaction
		    'Catch dberror As DatabaseException
		    'System.DebugLog dberror.message
		    'end try
		    'End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(Nil)
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Execute(pDatabase As Database, pExpiration As DateTime = Nil) As RecordSet
		  // Execute the QueryBuilder and return a RecordSet
		  // You may specify an expiration for caching the response
		  
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As String = Compile
		    
		    System.DebugLog System.Ticks.ToString + " " + pStatement
		    
		    dim count as integer = 0
		    Dim pRecordSet As RecordSet
		    
		    // Initialize the cache
		    If mCache Is Nil Then
		      mCache = New Dictionary
		    End If
		    
		    Dim pCache As Dictionary = mCache.Lookup(pStatement, Nil)
		    Dim pNow As Date = DateTime.Now
		    
		    If pExpiration <> Nil And pCache <> Nil And pNow < pCache.Value("expiration") Then
		      
		      // Get the result from the cache
		      pRecordSet = pCache.Value("recordset")
		      count = count + 1
		    Else
		      StartAgain:
		      
		      count = count + 1
		      
		      pRecordSet = pDatabase.SQLSelect(pStatement)
		      
		      // Check for error
		      If pDatabase.Error Then
		        if pDatabase.ErrorCode = 1055 then
		          pDatabase.ExecuteSQL("SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));")
		          pRecordSet = pDatabase.SQLSelect(pStatement)
		        elseif pDatabase.ErrorCode = 48879 then
		          Dim tDatabase as Database
		          if pDatabase isa MySQLCommunityServer then
		            tDatabase = new MySQLCommunityServer
		            tDatabase.UserName = pDatabase.UserName
		            tDatabase.Password = pDatabase.Password
		            tDatabase.Host = pDatabase.Host
		            MySQLCommunityServer(tDatabase).Port = MySQLCommunityServer(pDatabase).port
		          else
		            tDatabase = new SQLiteDatabase
		            SQLiteDatabase(tDatabase).DatabaseFile = SQLiteDatabase(pDatabase).DatabaseFile
		          End If
		          tDatabase.DatabaseName = pDatabase.DatabaseName
		          
		          if tDatabase.Connect then
		            if pDatabase isa MySQLCommunityServer then tDatabase.ExecuteSQL("SET NAMES 'utf8'")
		            pRecordSet = tDatabase.SQLSelect(pStatement)
		            tDatabase.Close
		          else
		            Raise New ORMException(tDatabase.ErrorMessage, pStatement)
		          End If
		          
		          
		        elseif pDatabase.ErrorCode = 2006 then
		          if pDatabase.Connect then
		            if pDatabase isa MySQLCommunityServer then pDatabase.ExecuteSQL("SET NAMES 'utf8'")
		            pRecordSet = pDatabase.SQLSelect(pStatement)
		          else
		            Raise New ORMException(pDatabase.ErrorMessage, pStatement)
		          End If
		        elseif count < 3 AND pDatabase.ErrorCode = 2003 then
		          GoTo StartAgain
		        else
		          Raise New ORMException(pDatabase.ErrorMessage, pStatement)
		        End If
		        
		      End If
		      
		    End If
		    
		    // Cache the result
		    If pExpiration <> Nil Then
		      dim dExp as New Dictionary()
		      dExp.Value("expiration") = pExpiration
		      dExp.Value("recordset") = pRecordSet
		      mCache.Value(pStatement) = dExp
		    End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(pRecordSet)
		    
		    Return pRecordSet
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetWeb and (Target64Bit)) or  (TargetIOS and (Target64Bit))
		Function Execute(pDatabase As Database, pExpiration As DateTime = Nil) As RowSet
		  // Execute the QueryBuilder and return a RecordSet
		  // You may specify an expiration for caching the response
		  
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As String = Compile
		    
		    
		    Dim pRecordSet As RowSet
		    
		    // Initialize the cache
		    If mCache Is Nil Then
		      mCache = New Dictionary
		    End If
		    
		    Dim pCache As Dictionary = mCache.Lookup(pStatement, Nil)
		    Dim pNow As DateTime = DateTime.Now
		    
		    If pExpiration <> Nil And pCache <> Nil And pNow < pCache.Value("expiration") Then
		      
		      // Get the result from the cache
		      pRecordSet = pCache.Value("recordset")
		      
		    Else
		      
		      Try
		        System.DebugLog pStatement
		        pRecordSet = pDatabase.SelectSQL(pStatement)
		        
		        // Check for error
		      Catch errordb As DatabaseException
		        if errordb.ErrorNumber = 1055 then
		          pDatabase.ExecuteSQL("SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));")
		          pRecordSet = pDatabase.SelectSQL(pStatement)
		        elseif errordb.ErrorNumber = 48879 then
		          Dim tDatabase as Database
		          
		          tDatabase = new SQLiteDatabase
		          SQLiteDatabase(tDatabase).DatabaseFile = SQLiteDatabase(pDatabase).DatabaseFile
		          tDatabase.DatabaseName = pDatabase.DatabaseName
		          
		          if tDatabase.Connect then
		            'if pDatabase isa MySQLCommunityServer then tDatabase.ExecuteSQL("SET NAMES 'utf8'")
		            pRecordSet = tDatabase.SelectSQL(pStatement)
		            tDatabase.Close
		          else
		            Raise New ORMException(Errordb.message, pStatement)
		          End If
		          
		          
		        elseif errordb.ErrorNumber = 2006 then
		          if pDatabase.Connect then
		            'if pDatabase isa MySQLCommunityServer then tDatabase.ExecuteSQL("SET NAMES 'utf8'")
		            pRecordSet = pDatabase.SelectSQL(pStatement)
		          else
		            Raise New ORMException(Errordb.message, pStatement)
		          End If
		        else
		          Raise New ORMException(Errordb.message, pStatement)
		        End If
		        
		        
		      End Try
		      
		    End If
		    
		    // Cache the result
		    If pExpiration <> Nil Then
		      dim dExp as New Dictionary()
		      dExp.Value("expiration") = pExpiration
		      dExp.Value("recordset") = pRecordSet
		      mCache.Value(pStatement) = dExp
		    End If
		    
		    Call Reset
		    
		    RaiseEvent ExecutedRS(pRecordSet)
		    
		    Return pRecordSet
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pColonms() As Variant) As QueryBuilder
		  Return Append(new SelectQueryExpression(pColonms))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pQueryBuilder As QueryBuilder, pTableAlias As String) As QueryBuilder
		  Return Append(new FromQueryExpression(pQueryBuilder, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pTableName As String) As QueryBuilder
		  Return From(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pTableName As String, pTableAlias As String) As QueryBuilder
		  Return Append(new FromQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As Variant) As QueryBuilder
		  mQuery.Append(new GroupByQueryExpression(pColumns))
		  return me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumn As Variant) As QueryBuilder
		  mQuery.Append( new GroupByQueryExpression(Array(pColumn)) )
		  
		  return me
		  //Return GroupBy(Array(pColumn))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pCriterias As Dictionary) As QueryBuilder
		  // Applies a dictionary of criterias
		  
		  For Each pKey As Variant In pCriterias.Keys()
		    Call Having(pKey, "=", pCriterias.Value(pKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pLeft As Variant) As QueryBuilder
		  Return Me.Having(pLeft, "=", "TRUE")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  Return Append(new HavingQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HavingClose() As QueryBuilder
		  Return Append(new HavingCloseQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HavingOpen() As QueryBuilder
		  Return Append(new HavingOpenQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Inflate(pQueryBuilder As QueryBuilder) As QueryBuilder
		  // Inflate this QueryBuilder on another QueryBuilder
		  Call pQueryBuilder.Reset.Append(mQuery)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InnerJoin(pTableName As String) As QueryBuilder
		  Return InnerJoin(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InnerJoin(pTableName As Variant, pTableAlias As String) As QueryBuilder
		  Return Append(new InnerJoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Intersect(pQueryBuilder As QueryBuilder) As QueryBuilder
		  Return Append(New IntersectQueryExpression(pQueryBuilder))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As QueryExpression, pTableAlias As String) As QueryBuilder
		  Return Append(new JoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As String) As QueryBuilder
		  Return Join(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As String, pTableAlias As String) As QueryBuilder
		  Return Append(new JoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As String) As QueryBuilder
		  Return LeftJoin(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As Variant, pTableAlias As String) As QueryBuilder
		  Return Append(new LeftJoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As String) As QueryBuilder
		  Return LeftOuterJoin(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As String, pTableAlias As String) As QueryBuilder
		  mQuery.Append(new LeftOuterJoinQueryExpression(pTableName, pTableAlias))
		  
		  return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Limit(pLimit As Integer) As QueryBuilder
		  mQuery.Append(new LimitQueryExpression(pLimit))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Limit(pOffset as integer, pLimit As Integer) As QueryBuilder
		  mQuery.Append(new LimitQueryExpression(pOffset, pLimit))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Offset(pOffset As Integer) As QueryBuilder
		  Return Append(new OffsetQueryExpression(pOffset))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn As Variant, pOperator As String, pValue As Variant) As QueryBuilder
		  Return Append(new OnQueryExpression(pColumn, pOperator, pValue))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn as Variant, pOperator as String, pValue as Variant, pType as DataType) As QueryBuilder
		  Return Append(new OnQueryExpression(pColumn, pOperator, pValue, pType))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnClose() As QueryBuilder
		  Return Append(new OnCloseQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnOpen() As QueryBuilder
		  Return Append(new OnOpenQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumns() as Variant, pDirections() as String, pComparators() as String) As QueryBuilder
		  mQuery.Append(new OrderByQueryExpression(pColumns, pDirections, pComparators))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn as Variant, pDirection as String = "ASC", pComparator as String = "") As QueryBuilder
		  mQuery.Append( new OrderByQueryExpression(Array(pColumn), Array(pDirection), Array(pComparator)) )
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  mQuery.Append(new OrHavingQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  mQuery.Append(new OrOnQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pLeft as Variant, pOperator as String, pRight as Variant, pType as DataType) As QueryBuilder
		  mQuery.Append(new OrOnQueryExpression(pLeft, pOperator, pRight, pType))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  mQuery.Append(new OrWhereQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhereOpen() As QueryBuilder
		  Return Append(new OrWhereOpenQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Query() As QueryExpression()
		  Return Me.mQuery
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As QueryBuilder
		  // Réinitalise le Query Builder
		  Redim mQuery(-1)
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Dictionary) As QueryBuilder
		  mQuery.Append(new SetQueryExpression(pValues))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(ParamArray pValues As Pair) As QueryBuilder
		  
		  Dim pDictionary As New Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Return Set(pDictionary)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Union(pQueryBuilder As QueryBuilder) As QueryBuilder
		  Return Append(New UnionQueryExpression(pQueryBuilder, False))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnionAll(pQueryBuilder As QueryBuilder) As QueryBuilder
		  Return Append(New UnionQueryExpression(pQueryBuilder, True))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As QueryBuilder
		  mQuery.Append(new ValuesQueryExpression(pValues))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(ParamArray pValues As Variant) As QueryBuilder
		  Return Values(pValues)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pCriterias As Dictionary) As QueryBuilder
		  // Applies a dictionary of criterias
		  
		  For Each pKey As Variant In pCriterias.Keys()
		    Call Where(pKey, "=", pCriterias.Value(pKey))
		  Next
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pLeft As Variant) As QueryBuilder
		  Return Me.Where(pLeft, "=", "TRUE")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  Return Append(new WhereQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WhereClose() As QueryBuilder
		  Return Append(new WhereCloseQueryExpression())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WhereOpen() As QueryBuilder
		  Return Append(new WhereOpenQueryExpression())
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Close()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Executed(pRecordSet As RecordSet)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ExecutedRS(pRecordSet As RowSet)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Executing() As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook


	#tag Property, Flags = &h1
		Protected Shared mCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		mLogs As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mQuery() As QueryExpression
	#tag EndProperty


	#tag ViewBehavior
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
			Name="mLogs"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
