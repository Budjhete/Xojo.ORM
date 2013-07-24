#tag Class
Protected Class FullJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "FULL " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
