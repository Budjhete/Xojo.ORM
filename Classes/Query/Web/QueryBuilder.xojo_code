#tag Class
Protected Class QueryBuilder
Inherits WebControl
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
		    
		  WEnd
		  
		  Return Join(pStatements, " ")
		  
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
		  // Execute the QueryBuilder using SQLExecute,
		  // which will not get any result from the database
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As String = Compile
		    
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

	#tag Method, Flags = &h0
		Function Execute(pDatabase As Database, pExpiration As Date = Nil) As RecordSet
		  // Execute the QueryBuilder and return a RecordSet
		  // You may specify an expiration for caching the response
		  
		  If Not RaiseEvent Executing Then
		    
		    Dim pStatement As String = Compile
		    
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
		Function LeftJoin(pTableName As String, pTableAlias As String) As QueryBuilder
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
		Function On(pColumn As Variant, pOperator As String, pValue As Variant, pType as DataType) As QueryBuilder
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
		Function OrderBy(pColumns() As Variant, pDirections() As String, pComparators() as String) As QueryBuilder
		  mQuery.Append(new OrderByQueryExpression(pColumns, pDirections, pComparators))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As Variant, pDirection As String = "ASC", pComparator as String = "") As QueryBuilder
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
		Function OrOn(pLeft As Variant, pOperator As String, pRight As Variant, pType as DataType) As QueryBuilder
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
		Event Executed(pRecordSet As RecordSet)
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
			Name="Cursor"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Automatic"
				"1 - Standard Pointer"
				"2 - Finger Pointer"
				"3 - IBeam"
				"4 - Wait"
				"5 - Help"
				"6 - Arrow All Directions"
				"7 - Arrow North"
				"8 - Arrow South"
				"9 - Arrow East"
				"10 - Arrow West"
				"11 - Arrow Northeast"
				"12 - Arrow Northwest"
				"13 - Arrow Southeast"
				"14 - Arrow Southwest"
				"15 - Splitter East West"
				"16 - Splitter North South"
				"17 - Progress"
				"18 - No Drop"
				"19 - Not Allowed"
				"20 - Vertical IBeam"
				"21 - Crosshair"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HorizontalCenter"
			Group="Behavior"
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
			Name="LockBottom"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
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
			Name="TabOrder"
			Visible=true
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
			Name="VerticalCenter"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ZIndex"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_DeclareLineRendered"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_HorizontalPercent"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_IsEmbedded"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_Locked"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_NeedsRendering"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_OfficialControl"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_OpenEventFired"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_VerticalPercent"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
