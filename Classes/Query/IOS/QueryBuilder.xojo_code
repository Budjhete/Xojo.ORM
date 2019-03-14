#tag Class
Protected Class QueryBuilder
Inherits iOSControl
Implements QueryExpression
	#tag Method, Flags = &h0
		Function AndHaving(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
		  Return Append(new AndHavingQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
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
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  Dim pStatements() As Text
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
		    
		  WEnd
		  
		  Return Text.Join(pStatements, " ")
		  
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Execute(pDatabase As Database, pCommit As Boolean = True)
		  // Execute the QueryBuilder using SQLExecute,
		  // which will not get any result from the database
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As Text = Compile
		    
		    System.DebugLog pStatement
		    
		    pDatabase.SQLExecute(pStatement)
		    
		    If pDatabase.Error Then
		      Raise New ORMException(pDatabase.ErrorMessage, pStatement, pDatabase.ErrorCode)
		    End If
		    
		    If pCommit Then
		      pDatabase.Commit
		    End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(Nil)
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Execute(pDatabase As Database, pExpiration As Date = Nil) As RecordSet
		  // Execute the QueryBuilder and return a RecordSet
		  // You may specify an expiration for caching the response
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As Text = Compile
		    
		    System.DebugLog pStatement
		    
		    Dim pRecordSet As RecordSet
		    
		    // Initialize the cache
		    If mCache Is Nil Then
		      mCache = New Dictionary
		    End If
		    
		    Dim pCache As Dictionary = mCache.Lookup(pStatement, Nil)
		    Dim pNow As New Date
		    
		    If pExpiration <> Nil And pCache <> Nil And pNow < pCache.Value("expiration") Then
		      
		      // Get the result from the cache
		      pRecordSet = pCache.Value("recordset")
		      
		    Else
		      
		      pRecordSet = pDatabase.SQLSelect(pStatement)
		      
		      // Check for error
		      If pDatabase.Error Then
		        Raise New ORMException(pDatabase.ErrorMessage, pStatement)
		      End If
		      
		    End If
		    
		    // Cache the result
		    If pExpiration <> Nil Then
		      mCache.Value(pStatement) = New Dictionary("expiration": pExpiration, "recordset": pRecordSet)
		    End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(pRecordSet)
		    
		    Return pRecordSet
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetDesktop and (Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Sub Execute(pDatabase As iOSSQLiteDatabase, pCommit As Boolean = True)
		  // Execute the QueryBuilder using SQLExecute,
		  // which will not get any result from the database
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As Text = Compile
		    
		    System.DebugLog pStatement
		    
		    Try
		      pDatabase.SQLExecute("BEGIN TRANSACTION")
		      pDatabase.SQLExecute(pStatement)
		    Catch e As iOSSQLiteException
		      System.DebugLog "Error: " + e.Reason
		      pDatabase.SQLExecute("ROLLBACK")
		      Return
		    End Try
		    
		    
		    If pCommit Then
		      pDatabase.SQLExecute("COMMIT")
		    End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(Nil)
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Function Execute(pDatabase As iOSSQLiteDatabase, pExpiration As Xojo.Core.Date = Nil) As iOSSQLiteRecordSet
		  // Execute the QueryBuilder and return a RecordSet
		  // You may specify an expiration for caching the response
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As Text = Compile
		    
		    System.DebugLog pStatement
		    
		    Dim pRecordSet As iOSSQLiteRecordSet
		    
		    // Initialize the cache
		    If mCache Is Nil Then
		      mCache = New Dictionary
		    End If
		    
		    Dim pCache As Dictionary = mCache.Lookup(pStatement, Nil)
		    Dim pNow As Xojo.Core.Date = Xojo.Core.Date.Now
		    
		    If pExpiration <> Nil And pCache <> Nil And pNow < pCache.Value("expiration") Then
		      
		      // Get the result from the cache
		      pRecordSet = pCache.Value("recordset")
		      
		    Else
		      Try
		        pRecordSet = pDatabase.SQLSelect(pStatement)
		      Catch e As iOSSQLiteException
		        Dim err As Text = e.Reason
		        Raise New ORMException(Err, pStatement)
		      End Try
		      
		      
		    End If
		    
		    // Cache the result
		    If pExpiration <> Nil Then
		      dim d as new Dictionary
		      d.Value("expiration") = pExpiration
		      d.Value("recordset") = pRecordSet
		      mCache.Value(pStatement) = d
		    End If
		    
		    Call Reset
		    
		    RaiseEvent Executed(pRecordSet)
		    
		    Return pRecordSet
		    
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pQueryBuilder As QueryBuilder, pTableAlias As Text) As QueryBuilder
		  Return Append(new FromQueryExpression(pQueryBuilder, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pTableName As Text) As QueryBuilder
		  Return From(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function From(pTableName As Text, pTableAlias As Text) As QueryBuilder
		  Return Append(new FromQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As Auto) As QueryBuilder
		  mQuery.Append(new GroupByQueryExpression(pColumns))
		  return me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumn As Auto) As QueryBuilder
		  mQuery.Append( new GroupByQueryExpression(Array(pColumn)) )
		  
		  return me
		  //Return GroupBy(Array(pColumn))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pLeft As Auto) As QueryBuilder
		  Return Me.Having(pLeft, "=", "TRUE")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
		  Return Append(new HavingQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pCriterias As Xojo.Core.Dictionary) As QueryBuilder
		  // Applies a dictionary of criterias
		  
		  For Each pCriteriasEntry As DictionaryEntry In pCriterias
		    Call Having(pCriteriasEntry.Key, "=", pCriteriasEntry.Value)
		  Next
		  
		  Return Me
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
		Function Intersect(pQueryBuilder As QueryBuilder) As QueryBuilder
		  Return Append(New IntersectQueryExpression(pQueryBuilder))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As QueryExpression, pTableAlias As Text) As QueryBuilder
		  Return Append(new JoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As Text) As QueryBuilder
		  Return Join(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pTableName As Text, pTableAlias As Text) As QueryBuilder
		  Return Append(new JoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As Text) As QueryBuilder
		  Return LeftJoin(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftJoin(pTableName As Text, pTableAlias As Text) As QueryBuilder
		  Return Append(new LeftJoinQueryExpression(pTableName, pTableAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As Text) As QueryBuilder
		  Return LeftOuterJoin(pTableName, pTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LeftOuterJoin(pTableName As Text, pTableAlias As Text) As QueryBuilder
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
		Function On(pColumn As Auto, pOperator As Text, pValue As Auto) As QueryBuilder
		  Return Append(new OnQueryExpression(pColumn, pOperator, pValue))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn as Auto, pOperator as Text, pValue as Auto, pType as DataType) As QueryBuilder
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
		Function OrderBy(pColumns() as Auto, pDirections() as Text, pComparators() as Text) As QueryBuilder
		  mQuery.Append(new OrderByQueryExpression(pColumns, pDirections, pComparators))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn as Auto, pDirection as Text = "ASC", pComparator as Text = "") As QueryBuilder
		  mQuery.Append( new OrderByQueryExpression(Array(pColumn), Array(pDirection), Array(pComparator)) )
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
		  mQuery.Append(new OrHavingQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
		  mQuery.Append(new OrOnQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrOn(pLeft as Auto, pOperator as Text, pRight as Auto, pType as DataType) As QueryBuilder
		  mQuery.Append(new OrOnQueryExpression(pLeft, pOperator, pRight, pType))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
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

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Set(ParamArray pValues As Pair) As QueryBuilder
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Return Set(pDictionary)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Function Set(pKey As Text, pValue As Auto) As QueryBuilder
		  Dim pDictionary As New Xojo.Core.Dictionary
		  
		  pDictionary.Value(pKey) = pValue
		  
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
		Function Values(pValues() As Auto) As QueryBuilder
		  mQuery.Append(new ValuesQueryExpression(pValues))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(ParamArray pValues As Auto) As QueryBuilder
		  Return Values(pValues)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues As Xojo.Core.Dictionary) As QueryBuilder
		  dim cValues() as auto
		  
		  for Each pVd as Xojo.Core.DictionaryEntry in pValues
		    cValues.Append(pVd.Value)
		  next
		  
		  mQuery.Append(new ValuesQueryExpression(cValues))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pLeft As Auto) As QueryBuilder
		  Return Me.Where(pLeft, "=", "TRUE")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pLeft As Auto, pOperator As Text, pRight As Auto) As QueryBuilder
		  Return Append(new WhereQueryExpression(pLeft, pOperator, pRight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pCriterias As Xojo.Core.Dictionary) As QueryBuilder
		  // Applies a dictionary of criterias
		  
		  For Each CriteriaEntry As DictionaryEntry In pCriterias
		    Call Where(CriteriaEntry.Key, "=", CriteriaEntry.Value)
		  Next
		  
		  Return Me
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
		Event Executed(pRecordSet As iOSSQLiteRecordSet)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Executing() As Boolean
	#tag EndHook


	#tag Property, Flags = &h1
		Protected Shared mCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mQuery() As QueryExpression
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AccessibilityHint"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AccessibilityLabel"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			Type="Double"
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
