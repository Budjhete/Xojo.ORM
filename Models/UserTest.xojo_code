#tag Class
Protected Class UserTest
Inherits ORM
	#tag Method, Flags = &h0
		Function Add(pProjectTest As ProjectTest) As ORM
		  Return Add("UsersProjects", "user", "project", pProjectTest.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Database() As Database
		  Return ORMTestDatabase
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Groups() As QueryBuilder
		  Return HasMany("Groups", "user")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pProject As ProjectTest, pDatabase As Database) As Boolean
		  Return Has("UsersProjects", "user", "project", pProject.Pk, pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Projects() As QueryBuilder
		  Return HasManyThrough("Projects_Users", "user", "project", "Projects")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Return "Users"
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Data("username")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Call Data("username", value)
			End Set
		#tag EndSetter
		username As String
	#tag EndComputedProperty


	#tag ViewBehavior
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
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="username"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
