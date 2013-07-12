#tag Class
Protected Class UsingQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "USING " + QueryCompiler.Column(mColumn) + QueryCompiler.Operator(mOperator) + QueryCompiler.Value(mValue)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As String, pOperator As String, pValue As Variant)
		  mColumn = pColumn
		  mOperator = pOperator
		  mValue = pValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 4
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOperator As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As Variant
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
