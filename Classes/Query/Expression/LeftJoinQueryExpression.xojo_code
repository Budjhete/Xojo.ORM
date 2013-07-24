#tag Class
Protected Class LeftJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "LEFT " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
