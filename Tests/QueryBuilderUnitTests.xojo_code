#tag Class
Protected Class QueryBuilderUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub JoinTest()
		  Dim pRecordSet As RecordSet = DB.Find("Users", Array("id")).Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  
		  
		End Sub
	#tag EndMethod


End Class
#tag EndClass
