#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Column(pColumn As Variant) As String
		  Select Case pColumn
		    
		  Case IsA ExpressionQueryExpression
		    Return ExpressionQueryExpression(pColumn).Compile
		    
		  Case IsA QueryExpression
		    Return "(" + QueryExpression(pColumn).Compile + ")"
		    
		  Case Nil
		    Return "NULL"
		    
		  End Select
		  
		  // Compile column
		  Dim pParts() As String = Split(pColumn, ".")
		  
		  For i As Integer = 0 To pParts.Ubound
		    
		    Select Case pParts(i)
		    Case "*"
		      // Do not escape the column
		    Else
		      pParts(i) = "`" + pParts(i)+ "`"
		    End Select
		    
		  Next
		  
		  Return Join(pParts, ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pColumns() As Variant) As String
		  // Compile values
		  Dim pCompiledColumns() As String
		  
		  For i As Integer = 0 To pColumns.Ubound
		    pCompiledColumns.Append(QueryCompiler.Column(pColumns(i)))
		  Next
		  
		  Return Join(pCompiledColumns, ", ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator(pOperator As String) As String
		  Return pOperator.Uppercase()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Dictionary) As String
		  Dim pQuery As String
		  Dim i As Integer = 0
		  
		  For Each pKey As Variant In pValues.Keys()
		    
		    pQuery = pQuery + QueryCompiler.Column(pKey) + "=" + QueryCompiler.Value(pValues.Value(pKey))
		    
		    If i <> pValues.Keys().UBound Then
		      pQuery = pQuery + ","
		    End If
		    
		    i = i + 1
		    
		  Next
		  
		  Return pQuery
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName(pTableName As String) As String
		  Return "`" + pTableName + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName(pTableName As String, pAlias As String) As String
		  Return "`" + pTableName + "` AS `" + pAlias + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(pValue As Variant) As String
		  Select Case pValue
		    
		  Case IsA ExpressionQueryExpression
		    Return ExpressionQueryExpression(pValue).Compile
		    
		  Case IsA QueryExpression
		    Return "(" + QueryExpression(pValue).Compile + ")"
		    
		  Case Nil
		    Return "NULL"
		    
		  End Select
		  
		  Return "'" + pValue.StringValue + "'"
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As String
		  // Compile values
		  Dim pCompiledValues() As String
		  
		  For i As Integer = 0 To pValues.Ubound
		    pCompiledValues.Append(QueryCompiler.Value(pValues(i)))
		  Next
		  
		  Return Join(pCompiledValues, ", ")
		  
		  
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
