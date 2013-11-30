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
		Function Groups() As GroupTest
		  Return GroupTest(HasMany(New GroupTest, "user"))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pProject As ProjectTest, pDatabase As Database) As Boolean
		  Return Has("UsersProjects", "user", "project", pProject.Pk, pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Projects() As ProjectTest
		  Return ProjectTest(HasManyThrough(New ProjectTest, "Projects_Users", "user", "project"))
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
			  Return New GroupTest(Me.Data("group"))
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Me.Data("group") = value.Pk
			End Set
		#tag EndSetter
		group As GroupTest
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Data("password")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // You can encrypt your password here
			  Me.Data("password") = value
			End Set
		#tag EndSetter
		password As String
	#tag EndComputedProperty

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
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
