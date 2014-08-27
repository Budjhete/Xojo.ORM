#tag Class
Protected Class UserTest
Inherits ORM
	#tag Method, Flags = &h0
		Function Add(pProject As ProjectTest) As ORM
		  Return Add("UsersProjects", "user", "project", pProject)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(pPk As Integer)
		  Super.Constructor(New Dictionary(Me.PrimaryKey: pPk))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Groups() As GroupTest
		  Return HasMany(New GroupTest, "user")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pProject As ProjectTest, pDatabase As Database) As Boolean
		  Return Has("UsersProjects", "user", "project", pProject, pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Projects() As ProjectTest
		  Return HasManyThrough(New ProjectTest, "UsersProjects", "user", "project")
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
			  Return BelongsTo(New GroupTest, "group")
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
			Name="Handle"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
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
			Name="MouseX"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MouseY"
			Group="Behavior"
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
			Name="PanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="password"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
		#tag ViewProperty
			Name="Window"
			Group="Behavior"
			InitialValue="0"
			Type="Window"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mInitialParent"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mWindow"
			Group="Behavior"
			InitialValue="0"
			Type="Window"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
