#tag Class
Protected Class FromQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return "FROM " + QueryCompiler.TableName(mTableName, mTableAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String, pTableAlias As String)
		  mTableName = pTableName
		  mTableAlias = pTableAlias
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 2
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mTableAlias As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableName As String
	#tag EndProperty


End Class
#tag EndClass
