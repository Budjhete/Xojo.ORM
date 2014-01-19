#tag Module
Protected Module DB
	#tag Method, Flags = &h0
		Function Alias(pColumn As Variant, pAlias As String) As QueryExpression
		  Return DB.Expression(QueryCompiler.Column(pColumn) + " AS " + QueryCompiler.Column(pAlias))
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
		  Return DB.Expression("SUM( " + QueryCompiler.Column(pColumn) + " ) AS " + QueryCompiler.Alias(pAlias))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Variant) As QueryExpression
		  Return DB.Expression("TOTAL( " + QueryCompiler.Column(pColumn) + " )")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Total(pColumn As Variant, pAlias As String) As QueryExpression
		  Return DB.Expression("TOTAL( " + QueryCompiler.Column(pColumn) + " ) AS " + QueryCompiler.Alias(pAlias))
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
