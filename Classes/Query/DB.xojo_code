#tag Module
Protected Module DB
	#tag Method, Flags = &h0
		Function Delete(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new DeleteQueryExpression(pTableName))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Expression(pExpression As String) As ExpressionQueryExpression
		  Return new ExpressionQueryExpression(pExpression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pColumns() As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Dim pVariantColumns() As Variant
		  
		  For Each pColumn As String In pColumns
		    pVariantColumns.Append(pColumn)
		  Next
		  
		  Return pQueryBuilder.Append(new SelectQueryExpression(pVariantColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pColumns() As Variant) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new SelectQueryExpression(pColumns))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(ParamArray pColumns As Variant) As QueryBuilder
		  If pColumns.UBound = -1 Then
		    // Find * when no columns are specified
		    Return Find(DB.Expression("*"))
		  End If
		  
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Return pQueryBuilder.Append(new SelectQueryExpression(pColumns))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As String, pColumns() As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new InsertQueryExpression(pTableName, pColumns))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new UpdateQueryExpression(pTableName))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod


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
End Module
#tag EndModule
