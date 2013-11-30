#tag Class
Protected Class ProjectTest
Inherits ORM
	#tag Method, Flags = &h0
		Function Has(pUserTest As UserTest, pDatabase As Database) As Boolean
		  Return Super.Has("UsersProjects", "project", "user", pUserTest, pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  return "Projects"
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Data("name")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Data("name") = value
			End Set
		#tag EndSetter
		name As String
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
	#tag EndViewBehavior
End Class
#tag EndClass
