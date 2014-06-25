#tag Class
Protected Class IntersectQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  Return "INTERSECT " + mQueryBuilder.Compile
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pQueryBuilder As QueryBuilder)
		  mQueryBuilder = pQueryBuilder
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 7
		  
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mQueryBuilder As QueryBuilder
	#tag EndProperty


End Class
#tag EndClass
