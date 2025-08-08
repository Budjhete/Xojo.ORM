#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Alias(pAlias As String) As String
		  Return "`" + pAlias + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Column(pColumn As Variant) As String
		  if pColumn = Nil then Return "NULL"
		  
		  if pColumn.Type = 9 or pColumn.Type = 10  or pColumn.type = 4096 then  // 9 = Object // 10 = Class
		    Select Case pColumn
		      
		    Case IsA QueryBuilder
		      Return "(" + QueryBuilder(pColumn).Compile + ")"
		      
		    Case IsA QueryExpression
		      Return QueryExpression(pColumn).Compile
		      
		    Case Nil
		      Return "NULL"
		      
		    End Select
		  end if
		  
		  // Compile column
		  Dim pParts() As String = pColumn.StringValue.Split(".")
		  
		  For i As Integer = 0 To pParts.Ubound
		    
		    Select Case pParts(i)
		    Case "*"
		      // Do not escape the column
		    Else
		      if pParts(i).IsNumeric then
		        pParts(i) = pParts(i)
		      else
		        #if TargetIOS then
		          pParts(i) = """" + pParts(i)+ """"
		        #else
		          pParts(i) = "`" + pParts(i)+ "`"
		        #endif
		      End
		    End Select
		    
		  Next
		  
		  Return String.FromArray(pParts, ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pColumns() As Variant) As String
		  // Compile values
		  Dim pCompiledColumns() As String
		  
		  For i As Integer = 0 To pColumns.LastIndex
		    pCompiledColumns.Append(QueryCompiler.Column(pColumns(i)))
		  Next
		  
		  Return String.FromArray(pCompiledColumns, ", ")
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
		  
		  For Each pColumn As DictionaryEntry In pValues
		    
		    pCompiledValues.Append(QueryCompiler.Set(pColumn.Key, pColumn.Value))
		    
		  Next
		  
		  Return String.FromArray(pCompiledValues, ", ")
		  
		  
		  
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
		    case 2, 3, 6
		      dim i() as integer = pValue
		      Return "( " + QueryCompiler.Values(i) + " )"
		      
		    else  // maybe a String
		      dim s() as String = pValue
		      Return "( " + QueryCompiler.Values(s) + " )"
		    end select
		  End If
		  
		  Dim pType as Integer = pValue.Type
		  // Test specific types
		  if pType = 9 or pType = 10 OR pType = 0 OR pType = 17 then
		    Select Case pValue
		      
		    Case IsA QueryBuilder // Subquery
		      Return "(" + QueryExpression(pValue).Compile + ")"
		      
		    Case IsA QueryExpression // Unquoted expression
		      Return QueryExpression(pValue).Compile
		      
		      'Case IsA Date // Date
		      'Return QueryCompiler.Value(pValue.DateTimeValue .SQLDateTime)
		      
		    Case IsA DateTime // Date
		      Return QueryCompiler.Value(pValue.DateTimeValue .SQLDateTime)
		      
		    Case Nil // NULL
		      Return "NULL"
		      
		    End Select
		  end if
		  
		  // Tests for primitives
		  Select Case Xojo.Introspection.GetType(pValue)
		    
		  Case GetTypeInfo(Integer), GetTypeInfo(Double), GetTypeInfo(Currency)
		    'if pValue.Type = Variant.TypeDouble then
		    'Dim locale As New Xojo.Core.Locale("en-US")
		    'Return pValue.DoubleValue.ToString(locale, "0.000000000000") // return e-12
		    'end if
		    Return pValue.StringValue
		    
		  Case GetTypeInfo(Boolean)
		    
		    If pValue.BooleanValue Then
		      Return "1"
		    Else
		      Return "0"
		    End If
		    
		  End Select
		  
		  // Remove bad characters
		  #if TargetMacOS then
		    pValue = pValue.StringValue.ReplaceAll(String.Chr(0), "")
		  #endif
		  
		  // Quote quotes
		  pValue = pValue.StringValue.ReplaceAll("'", "''")
		  
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
		  
		  Return String.FromArray(pCompiledValues, ", ")
		  
		  
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
		  
		  Return String.FromArray(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As String
		  // Compile values
		  Dim pCompiledValues() As string
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Variant = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return String.FromArray(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod


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
	#tag EndViewBehavior
End Module
#tag EndModule
