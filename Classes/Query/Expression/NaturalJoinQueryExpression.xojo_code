#tag Class
Protected Class NaturalJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "NATURAL " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
