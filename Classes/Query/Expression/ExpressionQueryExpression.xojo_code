#tag Class
Protected Class ExpressionQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  #Pragma Unused pLastQueryExpression
		  
		  Return mExpression
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pExpression As String)
		  mExpression = pExpression
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  // Part of the QueryExpression interface.
		  Return 0
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mExpression As String
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
