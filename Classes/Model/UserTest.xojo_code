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
		  Return GroupTest(HasMany(New GroupTest, "user"))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(pProject As ProjectTest, pDatabase As Database) As Boolean
		  Return Has("UsersProjects", "user", "project", pProject, pDatabase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Projects() As ProjectTest
		  Return ProjectTest(HasManyThrough(New ProjectTest, "UsersProjects", "user", "project"))
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
			  Return GroupTest(BelongsTo(New GroupTest, "group"))
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
			Name="hasHandler"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mLogs"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FinishLoaded"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mReplaced"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SchemaToCreateTable"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="isNew"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mRow"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="password"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="username"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
