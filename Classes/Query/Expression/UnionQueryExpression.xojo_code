#tag Class
Protected Class UnionQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  #Pragma Unused pLastQueryExpression
		  
		  // Part of the QueryExpression interface.
		  If mAll Then
		    Return "UNION ALL " + mQueryBuilder.Compile()
		  Else
		    Return "UNION " + mQueryBuilder.Compile()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pQueryBuilder As QueryBuilder, pAll As Boolean = True)
		  mQueryBuilder = pQueryBuilder
		  mAll = pAll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 7
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAll As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mQueryBuilder As QueryBuilder
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
