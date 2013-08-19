#tag Class
Protected Class UnionQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  // Part of the QueryExpression interface.
		  If mAll Then
		    Return "UNION ALL " + mExpression
		  Else
		    Return "UNION " + mExpression
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pExpression As String, pAll As Boolean = True)
		  mExpression = pExpression
		  mAll = pAll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  // Part of the QueryExpression interface.
		  // @FIXME The nice value might not be good
		  Return 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		mAll As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		mExpression As String
	#tag EndProperty


End Class
#tag EndClass
