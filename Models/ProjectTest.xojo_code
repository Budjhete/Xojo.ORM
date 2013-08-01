#tag Class
Protected Class ProjectTest
Inherits ORM
	#tag Method, Flags = &h0
		Function Database() As Database
		  return ORMTestDatabase
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  return "Project"
		End Function
	#tag EndMethod


End Class
#tag EndClass
