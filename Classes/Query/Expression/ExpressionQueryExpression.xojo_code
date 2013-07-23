#tag Class
Protected Class ExpressionQueryExpression
Inherits QueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return mExpression
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pExpression As String)
		  mExpression = pExpression
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  // Part of the QueryExpression interface.
		  Return 0
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mExpression As String
	#tag EndProperty


End Class
#tag EndClass
