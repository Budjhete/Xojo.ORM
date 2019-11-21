#tag Class
Protected Class LimitQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  #Pragma Unused pLastQueryExpression
		  dim Offset as Text
		  if mOffset > 0 then Offset = mOffset.ToText + ", "
		  Return "LIMIT " + Offset + mLimit.ToText
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLimit As Integer)
		  mLimit = pLimit
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pOffset as integer, pLimit As Integer)
		  mLimit = pLimit
		  mOffset = pOffset
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 9
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mLimit As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOffset As Integer
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
