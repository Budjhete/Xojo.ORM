#tag Class
Protected Class CrossJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "CROSS " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
