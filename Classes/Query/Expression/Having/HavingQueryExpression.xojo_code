#tag Class
Protected Class HavingQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
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
		Sub Constructor(pLeft As Variant, pOperator As String, pRight As Variant)
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
		Protected Function Predicate() As String
		  Return QueryCompiler.Column(mLeft) + " " + QueryCompiler.Operator(mLeft, mOperator, mRight) + " " + QueryCompiler.Value(mRight)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mLeft As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOperator As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRight As Variant
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
