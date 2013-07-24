#tag Class
Protected Class LeftOuterJoinQueryExpression
Inherits JoinQueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "LEFT OUTER " + Super.Compile()
		End Function
	#tag EndMethod


End Class
#tag EndClass
