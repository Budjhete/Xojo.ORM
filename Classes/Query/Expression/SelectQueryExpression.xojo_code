#tag Class
Protected Class SelectQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  If pLastQueryExpression IsA SelectQueryExpression Then
		    Return ", " + QueryCompiler.Columns(mColumns)
		  End If
		  
		  Return "SELECT " + QueryCompiler.Columns(mColumns)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Variant)
		  mColumns = pColumns
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  return 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As Variant
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
