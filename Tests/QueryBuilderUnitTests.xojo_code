#tag Class
Protected Class QueryBuilderUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub JoinTest()
		  DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  
		  Dim recordSet As RecordSet = DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  
		  DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Where("Users.username", "LIKE", "%John%").Execute(ORMTestDatabase)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WhereTest()
		  DB.Find("Users").Where("username", "LIKE", "%John%").Execute(ORMTestDatabase)
		  
		  MsgBox DB.Find("Users").Where("username", "LIKE", "%John%").AndWhere("password", "=", Nil).OrWhere("password", "=", "1234").Compile()
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="TestGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
