#tag Class
Protected Class UserProjectTest
Inherits ORM
	#tag Method, Flags = &h0
		Function PrimaryKeys() As String()
		  Return Array("user", "project")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableName() As String
		  Return "UsersProjects"
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return New ProjectTest(Data("project"))
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Data("project") = value.Pk
			End Set
		#tag EndSetter
		project As ProjectTest
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return New UserTest(Data("user"))
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Data("user") = value.Pk
			End Set
		#tag EndSetter
		user As UserTest
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
