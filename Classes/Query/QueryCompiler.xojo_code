#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Column(pColumn As Variant) As String
		  Select Case pColumn
		    
		  Case IsA QueryBuilder
		    Return "(" + QueryBuilder(pColumn).Compile + ")"
		    
		  Case IsA QueryExpression
		    Return QueryExpression(pColumn).Compile
		    
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
		  // Compile values
		  Dim pCompiledValues() As String
		  
		  For Each pColumn As Variant In pValues.Keys()
		    
		    pCompiledValues.Append(QueryCompiler.Set(pColumn, pValues.Value(pColumn)))
		    
		  Next
		  
		  Return Join(pCompiledValues, ", ")
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pColumn As Variant, pValue As Variant) As String
		  Return QueryCompiler.Column(pColumn) + " = " + QueryCompiler.Value(pValue)
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
		    
		  Case IsA QueryBuilder
		    Return "(" + QueryExpression(pValue).Compile + ")"
		    
		  Case IsA QueryExpression
		    Return QueryExpression(pValue).Compile
		    
		  Case Nil
		    Return "NULL"
		    
		  End Select
		  
		  Select Case pValue.Type
		    
		  Case Variant.TypeInteger, Variant.TypeLong, Variant.TypeDouble
		    Return pValue.StringValue
		    
		  Case Variant.TypeBoolean
		    
		    If pValue.BooleanValue Then
		      Return "1"
		    Else
		      Return "0"
		    End If
		    
		  End Select
		  
		  pValue = ReplaceAll(pValue, Chr(0), "")
		  
		  pValue = ReplaceAll(pValue.StringValue, "'", "''")
		  
		  // Quote quotes ;)
		  Return "'" + pValue + "'"
		  
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
