#tag Class
Protected Class WhereOpenQueryExpression
Inherits OpenQueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  Select Case pLastQueryExpression
		    
		  Case IsA WhereQueryExpression, IsA WhereCloseQueryExpression
		    Return "AND " + Super.Compile()
		    
		  End Select
		  
		  Return "WHERE " + Super.Compile()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 4
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
End Class
#tag EndClass
