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

	#tag Method, Flags = &h0
		Sub Execute(pDatabase As Database)
		  If Not RaiseEvent Executing() Then
		    
		    Dim pStatement As String = Compile()
		    
		    pStatement = pStatement.Replace(Chr(0), "")
		    
		    pDatabase.SQLExecute(pStatement)
		    
		    If pDatabase.Error Then
		      Raise New ORMException(pDatabase.ErrorMessage + " " + pStatement)
		    End If
		    
		    pDatabase.Commit()
		    
		    Call Reset()
		    
		    RaiseEvent Executed()
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Execute(pDatabase As Database) As RecordSet
		  If Not RaiseEvent Executing() Then
		    
		    Dim pStatement As String = Compile()
		    
		    pStatement = pStatement.Replace(Chr(0), "")
		    
		    Dim pRecordSet As RecordSet = pDatabase.SQLSelect(pStatement)
		    
		    If pDatabase.Error Then
		      Raise New ORMException(pDatabase.ErrorMessage + " " + pStatement)
		    End If
		    
		    pDatabase.Commit()
		    
		    Call Reset()
		    
		    RaiseEvent Executed()
		    
		    Return pRecordSet
		    
		  End If
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
		  Return Append(new GroupByQueryExpression(pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumn As Variant) As QueryBuilder
		  Return GroupBy(Array(pColumn))
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
		Function OrderBy(pColumns() As Variant, pDirections() As String) As QueryBuilder
		  mQuery.Append(new OrderByQueryExpression(pColumns, pDirections))
		  
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As Variant, pDirection As String = "ASC") As QueryBuilder
		  mQuery.Append(new OrderByQueryExpression(Array(pColumn), Array(pDirection)))
		  
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
		Function OrWhere(pLeft As Variant, pOperator As String, pRight As Variant) As QueryBuilder
		  mQuery.Append(new OrWhereQueryExpression(pLeft, pOperator, pRight))
		  
		  Return Me
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
		  Dim pDictionary As Dictionary
		  
		  For Each pValue As Pair In pValues
		    pDictionary.Value(pValue.Left) = pValue.Right
		  Next
		  
		  Return Set(pDictionary)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Using(pColumns() As Variant) As QueryBuilder
		  Return Append(new UsingQueryExpression(pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Using(ParamArray pColumns As Variant) As QueryBuilder
		  Return Using(pColumns)
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
		Event Executed()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Executing() As Boolean
	#tag EndHook


	#tag Property, Flags = &h21
		Private mQuery() As QueryExpression
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
