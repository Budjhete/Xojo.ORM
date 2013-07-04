#tag Module
Protected Module QueryCompiler
	#tag Method, Flags = &h0
		Function Column(pColumn As String) As String
		  // Ensure that column respects constraints
		  Return "`" + pColumn + "`"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns(pColumns() As String) As String
		  Dim pQuery As String
		  Dim i As Integer = 0
		  
		  For Each pColumn As String In pColumns
		    
		    pQuery = pQuery + QueryCompiler.Column(pColumn)
		    
		    If i < pColumns.Ubound Then
		      pQuery = pQuery + ", "
		    End If
		    
		    i = i + 1
		    
		  Next
		  
		  Return pQuery
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
		  // @TODO Escape value
		  return "'" + pValue.StringValue + "'"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values(pValues() As Variant) As String
		  Dim pQuery As String
		  Dim i As Integer = 0
		  
		  For Each pValue As Variant In pValues
		    
		    pQuery = pQuery + QueryCompiler.Value(pValue)
		    
		    If i < pValues.Ubound Then
		      pQuery = pQuery + ", "
		    End If
		    
		    i = i + 1
		    
		  Next
		  
		  Return "(" + pQuery + ")"
		  
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
