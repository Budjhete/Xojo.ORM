#tag Class
Protected Class ORMException
Inherits RuntimeException
	#tag Method, Flags = &h1000
		Sub Constructor(pMessage As String)
		  Constructor(pMessage, "")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pMessage As String, pStatement As String, pCode As Integer = 0)
		  // Constructor for SQL error
		  
		  
		  Message = pMessage
		  Statement = pStatement
		  Code = pCode
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Code As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Statement As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Code"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ErrorNumber"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
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
			Name="Message"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
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
			Name="Statement"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
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
