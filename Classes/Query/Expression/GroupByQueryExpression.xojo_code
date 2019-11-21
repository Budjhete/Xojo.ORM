#tag Class
Protected Class GroupByQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  Dim pCompiledColumns() As Text
		  
		  // Compile each column
		  For i As Integer = 0 To mColumns.UBound
		    pCompiledColumns.Append QueryCompiler.Column(mColumns(i))
		  Next
		  
		  If pLastQueryExpression IsA GroupByQueryExpression Then
		    // @TODO fixer l'espace avant la virgule
		    Return ", " + Text.Join(pCompiledColumns, ", ")
		  End If
		  
		  Return "GROUP BY " + Text.Join(pCompiledColumns, ", ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Auto)
		  mColumns = pColumns
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 5
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As Auto
	#tag EndProperty


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
End Class
#tag EndClass
