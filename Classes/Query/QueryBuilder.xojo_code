#tag Class
Protected Class QueryBuilder
Implements QueryExpression
	#tag Method, Flags = &h0
		Sub AndHaving(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new AndHavingQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndHaving(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  AndHaving(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AndWhere(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new AndWhereQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AndWhere(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  AndWhere(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Append(pQueryExpression As QueryExpression)
		  mQuery.Append(pQueryExpression)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Append(pQueryExpression As QueryExpression) As QueryBuilder
		  Append(pQueryExpression)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Compile() As String
		  Dim pStatements() As String
		  Dim pNice As Integer
		  
		  // Sort statements
		  While pStatements.Ubound < mQuery.Ubound 
		    
		    For i As Integer = 0 To mQuery.Ubound
		      
		      Dim pQueryExpression As QueryExpression = mQuery(i)
		      
		      If pQueryExpression.Nice() = pNice Then
		        pStatements.Append(pQueryExpression.Compile())
		      End If
		      
		    Next
		    
		    pNice = pNice + 1
		    
		  WEnd
		  
		  Return Join(pStatements, " ")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Execute(pDatabase As Database)
		  RaiseEvent Executing()
		  
		  Dim pStatement As String = Compile()
		  
		  pDatabase.SQLExecute(pStatement)
		  
		  If pDatabase.Error Then
		    Raise New ORMException(pDatabase.ErrorMessage + " " + pStatement)
		  End If
		  
		  pDatabase.Commit()
		  
		  Reset()
		  
		  RaiseEvent Executed()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Execute(pDatabase As Database) As RecordSet
		  RaiseEvent Executing()
		  
		  Dim pStatement As String = Compile()
		  
		  Dim pRecordSet As RecordSet = pDatabase.SQLSelect(pStatement)
		  
		  If pDatabase.Error Then
		    Raise New ORMException(pDatabase.ErrorMessage + " " + pStatement)
		  End If
		  
		  pDatabase.Commit()
		  
		  Reset()
		  
		  RaiseEvent Executed()
		  
		  Return pRecordSet
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GroupBy(pColumns() As String)
		  mQuery.Append(new GroupByQueryExpression(pColumns))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GroupBy(pColumns() As String) As QueryBuilder
		  GroupBy(pColumns)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Having(pValues As Dictionary)
		  For Each pKey As Variant In pValues.Keys()
		    Where(pKey.StringValue, "=", pValues.Value(pKey))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pValues As Dictionary) As QueryBuilder
		  Having(pValues)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Having(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new HavingQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Having(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  Having(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Join(pDirection As String, pTableName As String)
		  mQuery.Append(new JoinQueryExpression(pDirection, pTableName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(pDirection As String, pTableName As String) As QueryBuilder
		  Join(pDirection, pTableName)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Limit(pLimit As Integer)
		  mQuery.Append(new LimitQueryExpression(pLimit))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Limit(pLimit As Integer) As QueryBuilder
		  Limit(pLimit)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Offset(pOffset As Integer)
		  mQuery.Append(new OffsetQueryExpression(pOffset))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Offset(pOffset As Integer) As QueryBuilder
		  Offset(pOffset)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub On(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new OnQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function On(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  On(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OrderBy(pColumns() As String, pDirection As String = "ASC")
		  mQuery.Append(new OrderByQueryExpression(pColumns, pDirection))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumns() As String, pDirection As String = "ASC") As QueryBuilder
		  OrderBy(pColumns, pDirection)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OrderBy(pColumn As String, pDirection As String = "ASC")
		  mQuery.Append(new OrderByQueryExpression(pColumn, pDirection))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrderBy(pColumn As String, pDirection As String = "ASC") As QueryBuilder
		  OrderBy(pColumn, pDirection)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OrHaving(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new OrHavingQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrHaving(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  OrHaving(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OrWhere(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new OrWhereQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OrWhere(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  OrWhere(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  // Réinitalise le Query Builder
		  Redim mQuery(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As QueryBuilder
		  Reset()
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(pValues As Dictionary)
		  mQuery.Append(new SetQueryExpression(pValues))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Dictionary) As QueryBuilder
		  Set(pValues)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Using(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new UsingQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Using(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  Using(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Values(pValues() As Variant)
		  mQuery.Append(new ValuesQueryExpression(pValues))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As QueryBuilder
		  Values(pValues)
		  Return Me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Where(pColumn As String, pOperator As String, pValue As Variant)
		  mQuery.Append(new WhereQueryExpression(pColumn, pOperator, pValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Where(pColumn As String, pOperator As String, pValue As Variant) As QueryBuilder
		  Where(pColumn, pOperator, pValue)
		  Return Me
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Executed()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Executing()
	#tag EndHook


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
