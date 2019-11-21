#tag Class
Protected Class HavingQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  If pLastQueryExpression IsA HavingQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA HavingCloseQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA HavingOpenQueryExpression Then
		    Return Predicate()
		  End If
		  
		  Return "HAVING " + Predicate()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLeft As Auto, pOperator As Text, pRight As Auto)
		  mLeft = pLeft
		  mOperator = pOperator
		  mRight = pRight
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 6
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Predicate() As Text
		  Return QueryCompiler.Column(mLeft) + " " + QueryCompiler.Operator(mLeft, mOperator, mRight) + " " + QueryCompiler.Value(mRight)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mLeft As Auto
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOperator As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRight As Auto
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
