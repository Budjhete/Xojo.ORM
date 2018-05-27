#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Alias(pAlias As String) As String
		  Return "`" + pAlias + "`"
		End Function
	#tag EndMethod

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
		      if IsNumeric(pParts(i)) then
		        pParts(i) = pParts(i)
		      else
		        pParts(i) = "`" + pParts(i)+ "`"
		      End
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
		Function Operator(pLeft As Variant, pOperator As String, pRight As Variant) As String
		  #Pragma Unused pLeft
		  #Pragma Unused pRight
		  
		  Return pOperator.Uppercase
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
		  If pValue.IsArray Then
		    
		    select case pValue.ArrayElementType
		    case 2
		      dim i() as integer = pValue
		      Return "( " + QueryCompiler.Values(i) + " )"
		      
		    else  // maybe a string
		      dim s() as string = pValue
		      Return "( " + QueryCompiler.Values(s) + " )"
		    end select
		  End If
		  
		  // Test specific types
		  Select Case pValue
		    
		  Case IsA QueryBuilder // Subquery
		    Return "(" + QueryExpression(pValue).Compile + ")"
		    
		  Case IsA QueryExpression // Unquoted expression
		    Return QueryExpression(pValue).Compile
		    
		  Case IsA Date // Date
		    Return QueryCompiler.Value(pValue.DateValue.SQLDateTime)
		    
		  Case Nil // NULL
		    Return "NULL"
		    
		  End Select
		  
		  // Tests for primitives
		  Select Case pValue.Type
		    
		  Case Variant.TypeInteger, Variant.TypeInt64, Variant.TypeDouble, Variant.TypeCurrency
		    if pValue.Type = Variant.TypeDouble then
		      Dim locale As New Xojo.Core.Locale("en-US")
		      Return pValue.DoubleValue.ToText(locale, "0.000000000000") // return e-12
		    end if
		    Return pValue.StringValue
		    
		  Case Variant.TypeBoolean
		    
		    If pValue.BooleanValue Then
		      Return "1"
		    Else
		      Return "0"
		    End If
		    
		  End Select
		  
		  // Remove bad characters
		  pValue = ReplaceAll(pValue, Chr(0), "")
		  
		  // Quote quotes
		  pValue = ReplaceAll(pValue.StringValue, "'", "''")
		  
		  Return "'" + pValue + "'"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Integer) As String
		  // Compile values
		  Dim pCompiledValues() As String
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Variant = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return Join(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As String) As String
		  // Compile values
		  Dim pCompiledValues() As String
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Variant = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return Join(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As String
		  // Compile values
		  Dim pCompiledValues() As String
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Variant = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
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
