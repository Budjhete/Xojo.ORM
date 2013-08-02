#tag Class
Protected Class WhereQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  If pLastQueryExpression IsA WhereQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA WhereCloseQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA WhereOpenQueryExpression Then
		    Return Predicate()
		  End If
		  
		  Return "WHERE " + Predicate()
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLeft As Variant, pOperator As String, pRight() As Variant)
		  mLeft = pLeft
		  mOperator = pOperator
		  
		  If pRight.Ubound = 0 Then
		    mRight = pRight(0)
		    Exit Sub
		  End If
		  
		  // Opens the parentheses for any value enumeration in
		  // the right element of the WHERE clause
		  mRight = "("
		  
		  For i As Integer = 0 To pRight.Ubound
		    mRight = mRight + "'" + pRight(i) + "'"
		    
		    // Adds a comma if it is not the last element
		    If i <> pRight.Ubound Then
		      mRight = mRight + ", "
		    End If
		  Next
		  
		  // Closes the parentheses for the enumeration
		  mRight = mRight + ")"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pLeft As Variant, pOperator As String, ParamArray pRight As Variant)
		  Constructor(pLeft, pOperator, pRight)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 4
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Predicate() As String
		  Return QueryCompiler.Column(mLeft) + " " + QueryCompiler.Operator(mOperator) + " " + QueryCompiler.Value(mRight)
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
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
