#tag Class
Protected Class GroupTest
Inherits ORM
	#tag Method, Flags = &h0
		Function TableColumns(mDatabase As Database) As String()
		  Return Array("id", "user", "name")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Return "Groups"
		End Function
	#tag EndMethod


End Class
#tag EndClass
