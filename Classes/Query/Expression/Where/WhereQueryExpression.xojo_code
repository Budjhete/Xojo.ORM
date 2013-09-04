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

	#tag Method, Flags = &h1000
		Sub Constructor(pQueryExpression As QueryExpression)
		  mQueryExpression = pQueryExpression
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pLeft As Variant, pOperator As String, pRight As Variant)
		  mLeft = pLeft
		  mOperator = pOperator
		  mRight = pRight
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 4
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Predicate() As String
		  If mQueryExpression <> Nil Then 
		    Return mQueryExpression.Compile
		  End If
		  
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
		Private mQueryExpression As QueryExpression = Nil
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
