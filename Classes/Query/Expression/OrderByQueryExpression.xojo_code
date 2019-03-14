#tag Class
Protected Class OrderByQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  Dim pCompiledColumns() As Text
		  
		  // Compile each column and add its direction
		  For i As Integer = 0 To mColumns.UBound
		    if mComparator(i) = "" then
		      pCompiledColumns.Append QueryCompiler.Column(mColumns(i)) + " " + mDirections(i)
		    else
		      pCompiledColumns.Append "( " + QueryCompiler.Column(mColumns(i)) + mComparator(i) + " ) " + mDirections(i)
		    end if
		  Next
		  
		  If pLastQueryExpression IsA OrderByQueryExpression Then
		    // @TODO fixer l'espace avant la virgule
		    Return ", " + Text.Join(pCompiledColumns, ", ")
		  End If
		  
		  Return "ORDER BY " + Text.Join(pCompiledColumns, ", ")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() as Auto, pDirections() as Text, pComparators() as Text = nil)
		  mColumns = pColumns
		  mDirections = pDirections
		  mComparator = pComparators
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 8
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As Auto
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mComparator() As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDirections() As Text
	#tag EndProperty


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
End Class
#tag EndClass
