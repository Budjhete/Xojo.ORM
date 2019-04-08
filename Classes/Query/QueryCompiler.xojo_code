#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Alias(pAlias As Text) As Text
		  Return "`" + pAlias + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Column(pColumn As Auto) As Text
		  if pColumn = Nil then Return "NULL"
		  
		  if pColumn.Type = 9 or pColumn.Type = 10 then  // 9 = Object // 10 = Class
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
		  Dim pParts() As Text = pColumn.AutoTextValue.Split(".")
		  
		  For i As Integer = 0 To pParts.Ubound
		    
		    Select Case pParts(i)
		    Case "*"
		      // Do not escape the column
		    Else
		      if pParts(i).IsNumeric then
		        pParts(i) = pParts(i)
		      else
		        pParts(i) = "`" + pParts(i)+ "`"
		      End
		    End Select
		    
		  Next
		  
		  Return Text.Join(pParts, ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pColumns() As Auto) As Text
		  // Compile values
		  Dim pCompiledColumns() As Text
		  
		  For i As Integer = 0 To pColumns.Ubound
		    pCompiledColumns.Append(QueryCompiler.Column(pColumns(i)))
		  Next
		  
		  Return Text.Join(pCompiledColumns, ", ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator(pLeft As Auto, pOperator As Text, pRight As Auto) As Text
		  #Pragma Unused pLeft
		  #Pragma Unused pRight
		  
		  Return pOperator.Uppercase
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pColumn As Auto, pValue As Auto) As Text
		  Return QueryCompiler.Column(pColumn) + " = " + QueryCompiler.Value(pValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(pValues As Xojo.Core.Dictionary) As Text
		  // Compile values
		  Using Xojo.Core
		  
		  Dim pCompiledValues() As Text
		  
		  For Each pColumn As DictionaryEntry In pValues
		    
		    pCompiledValues.Append(QueryCompiler.Set(pColumn.Key, pColumn.Value))
		    
		  Next
		  
		  Return Text.Join(pCompiledValues, ", ")
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName(pTableName As Text) As Text
		  Return "`" + pTableName + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName(pTableName As Text, pAlias As Text) As Text
		  Return "`" + pTableName + "` AS `" + pAlias + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(pValue As Auto) As Text
		  If pValue.IsArray Then
		    
		    select case pValue.ArrayElementType
		    case 2, 6
		      dim i() as integer = pValue
		      Return "( " + QueryCompiler.Values(i) + " )"
		      
		    else  // maybe a Text
		      dim s() as Text = pValue
		      Return "( " + QueryCompiler.Values(s) + " )"
		    end select
		  End If
		  
		  // Test specific types
		  if pValue.Type = 9 or pValue.Type = 10 OR pValue.type = 0 then
		    Select Case pValue
		      
		    Case IsA QueryBuilder // Subquery
		      Return "(" + QueryExpression(pValue).Compile + ")"
		      
		    Case IsA QueryExpression // Unquoted expression
		      Return QueryExpression(pValue).Compile
		      
		    Case IsA Date // Date
		      Return QueryCompiler.Value(pValue.AutoDateValue.SQLDateTime)
		      
		    Case IsA Xojo.Core.Date // Date
		      Return QueryCompiler.Value(pValue.AutoDateValue.SQLDateTime)
		      
		    Case Nil // NULL
		      Return "NULL"
		      
		    End Select
		  end if
		  
		  // Tests for primitives
		  Select Case Xojo.Introspection.GetType(pValue)
		    
		  Case GetTypeInfo(Integer), GetTypeInfo(Double), GetTypeInfo(Currency)
		    'if pValue.Type = Auto.TypeDouble then
		    'Dim locale As New Xojo.Core.Locale("en-US")
		    'Return pValue.DoubleValue.ToText(locale, "0.000000000000") // return e-12
		    'end if
		    Return pValue.AutoTextValue
		    
		  Case GetTypeInfo(Boolean)
		    
		    If pValue.AutoBooleanValue Then
		      Return "1"
		    Else
		      Return "0"
		    End If
		    
		  End Select
		  
		  // Remove bad characters
		  pValue = pValue.AutoTextValue.ReplaceAll( Chr(0).ToText, "")
		  
		  // Quote quotes
		  pValue = pValue.AutoTextValue.ReplaceAll("'", "''")
		  
		  Return "'" + pValue + "'"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Auto) As Text
		  // Compile values
		  Dim pCompiledValues() As Text
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Auto = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return Text.Join(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Integer) As Text
		  // Compile values
		  Dim pCompiledValues() As Text
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Auto = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return Text.Join(pCompiledValues, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Text) As Text
		  // Compile values
		  Dim pCompiledValues() As Text
		  
		  For i As Integer = 0 To pValues.Ubound
		    dim v as Auto = pValues(i)
		    pCompiledValues.Append(QueryCompiler.Value(v))
		  Next
		  
		  Return Text.Join(pCompiledValues, ", ")
		  
		  
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
