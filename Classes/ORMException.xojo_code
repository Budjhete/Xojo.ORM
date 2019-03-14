#tag Class
Protected Class ORMException
Inherits RuntimeException
	#tag Method, Flags = &h1000
		Sub Constructor(pMessage As Text)
		  Constructor(pMessage, "")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pMessage As Text, pStatement As Text, pCode As Integer = 0)
		  // Constructor for SQL error
		  
		  #if TargetIOS then
		    Reason = pMessage
		  #else
		    Message = pMessage
		  #endif
		  Statement = pStatement
		  Code = pCode
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Code As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Statement As Text
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Reason"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Code"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ErrorNumber"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
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
			Name="Message"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Statement"
			Group="Behavior"
			Type="Text"
			EditorType="MultiLineEditor"
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
