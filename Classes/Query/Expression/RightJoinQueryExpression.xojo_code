#tag Class
Protected Class RightJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "RIGHT " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
