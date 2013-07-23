#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Column(pColumn As String) As String
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
		Function Columns(pTablesColumns() As JSONItem) As String
		  Dim pColumns() As String
		  Dim TableColumn As JSONItem
		  
		  For i As Integer = 0 To pTablesColumns.Ubound
		    // FIX ME!
		    // The condition can change latter. This is a draft
		    If Not pTablesColumns(i).HasName("Columns") Then
		      return ""
		    End If
		    
		    // Gives the Alias the table name if it does not exist
		    If Not pTablesColumns(i).HasName("Alias") Then
		      pTablesColumns(i).Value("Alias") = pTablesColumns(i).Value("TableName")
		    End If
		    
		    TableColumn = pTablesColumns(i).Child("Columns")
		    
		    // Sets each column's full name for the query
		    If TableColumn.IsArray Then
		      For j As Integer = 0 To TableColumn.Count - 1
		        // Should make <tableAlias>.<tableColumn>
		        pColumns.Append(pTablesColumns(i).Value("Alias").StringValue + "." + TableColumn.Value(j).StringValue)
		      Next
		    End If
		  Next
		  
		  return QueryCompiler.Columns(pColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pColumns() As String) As String
		  For i As Integer = 0 To pColumns.Ubound
		    pColumns(i) = QueryCompiler.Column(pColumns(i))
		  Next
		  
		  Return Join(pColumns, ", ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pAlias As String, pColumns() As String) As String
		  // Compile columns and prepend an alias
		  
		  For i As Integer = 0 To pColumns.Ubound
		    pColumns(i) = pAlias + "." + pColumns(i)
		  Next
		  
		  Return QueryCompiler.Columns(pColumns)
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
		Function Value(pValue As Variant) As String
		  Select Case pValue
		    
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
