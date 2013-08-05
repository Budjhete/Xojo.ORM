#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub AddTest()
		  CreateUsers()
		  CreateProjects()
		  DB.Delete("Projects_Users").Execute(ORMTestDatabase)
		  
		  // Loads the UsertTest model from the database
		  Dim pUserTest As New UserTest(1)
		  Call pUserTest.Find()
		  
		  // Loads the ProjectTest model from the database
		  Dim pProjectTest As New ProjectTest(1)
		  Call pProjectTest.Find()
		  
		  Assert.IsFalse(pUserTest.Has("Project", pProjectTest))
		  
		  Call pUserTest.Add("Project", pProjectTest)
		  
		  Assert.IsTrue(pUserTest.Has("Project", pProjectTest))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CountRelationsTest()
		  // Initializes the model for the test
		  Dim mORM As New UserTest(1)
		  call mORM.Find(mORM.Database)
		  
		  // Tests for any relation with another model in an
		  // Has Many Through relationship
		  Dim Relations As Integer = mORM.CountRelations("Project")
		  Assert.AreEqual(Relations, 1)
		  
		  // Test to see if a provided farkey gives enough constraint
		  Relations = mORM.CountRelations("Project", 1)
		  Assert.AreEqual(Relations, 1)
		  
		  // Makes sure that it never returns a match for an empty
		  // primary key
		  Relations = mORM.CountRelations("Project", 0)
		  Assert.AreEqual(Relations, 0)
		  
		  // Does it work with a string?
		  Relations = mORM.CountRelations("Project", "myProject")
		  Assert.AreEqual(Relations, 0)
		  
		  // Does it work with many strings
		  Relations = mORM.CountRelations("Project", 1,2,3,4)
		  Assert.AreEqual(Relations, 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateProjects()
		  DB.Delete("Projets").Execute(ORMTestDatabase)
		  DB.Insert("Projets", "name").Values("Budjhete").Execute(ORMTestDatabase)
		  DB.Insert("Projets", "name").Values("Kanjo").Execute(ORMTestDatabase)
		  DB.Insert("Projets", "name").Values("Hete").Execute(ORMTestDatabase)
		  DB.Insert("Projets", "name").Values("Vee").Execute(ORMTestDatabase)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateTest()
		  Dim pModel As New UserTest()
		  
		  Assert.IsFalse pModel.Loaded()
		  Assert.IsFalse pModel.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("username") = "Jean"
		  pValues.Value("password") = "LOL"
		  
		  Call pModel.Data(pValues).Create(ORMTestDatabase)
		  
		  Assert.IsTrue pModel.Loaded()
		  Assert.IsFalse pModel.Changed(), "L'ORM a change"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateUsers()
		  DB.Delete("Users").Execute(ORMTestDatabase)
		  DB.Insert("Users", "username", "password").Values("Budjhete", ".com").Execute(ORMTestDatabase)
		  DB.Insert("Users", "username", "password").Values("Kanjo", ".com").Execute(ORMTestDatabase)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteTest()
		  Dim pUserTest As New UserTest()
		  
		  Call pUserTest.Data("username", "Paul-Willy Jean").Data("password", "Jean").Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUserTest.Loaded()
		  Assert.IsFalse pUserTest.Changed(), "Le modele est enregistre, mais il a quand-meme change"
		  
		  // Supprime le modele et verifie l'etat de l'ORM
		  Call pUserTest.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse pUserTest.Loaded(), "Le modele reste tout de meme charge"
		  Assert.IsFalse pUserTest.Changed(), "L'ORM a change, mais il n'existe plus."
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindTest()
		  Dim pUserTest As New UserTest
		  
		  Call pUserTest.Data("username", "james").Data("password", "james22").Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUserTest.Loaded
		  
		  Dim pk As Variant = pUserTest.Pk()
		  
		  Call pUserTest.Unload()
		  
		  Call pUserTest.Where("id", "=", pk).Find(ORMTestDatabase)
		  
		  Assert.AreEqual("james", pUserTest.username)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HasTest()
		  Dim mUserTest As New UserTest(1)
		  call mUserTest.Find()
		  
		  Assert.IsTrue(mUserTest.Has("Project"))
		  Assert.IsTrue(mUserTest.Has("Project", 1), mUserTest.Data("username") + " should have one role.")
		  Assert.IsFalse(mUserTest.Has("Project", 0))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InflateTest()
		  Dim OriginalORM As New UserTest
		  
		  Dim username As String = "Kandjo"
		  Dim password As String = "ca"
		  
		  Call OriginalORM.Data("username", username)
		  Call OriginalORM.Data("password", password)
		  
		  Dim NewORM As New UserTest()
		  Call NewORM.Inflate(OriginalORM)
		  
		  Assert.AreEqual(NewORM.TableName(), OriginalORM.TableName(), NewORM.TableName() + " " + OriginalORM.TableName())
		  Assert.AreEqual(OriginalORM.Data("username"), username, "The original ORM's username should be " + username)
		  System.DebugLog(NewORM.Data("username"))
		  Assert.AreEqual(NewORM.Data("username"), username, "The new ORM's username should be " + username)
		  Assert.AreEqual(OriginalORM.Data("username").StringValue, NewORM.Data("username").StringValue, "Both ORMs should have the same data.")
		  
		  Call NewORM.Data("username", username + password)
		  Assert.AreEqual(NewORM.Data("username"), username + password, "The new ORM's username should now be " + username + password)
		  Assert.AreEqual(OriginalORM.Data("username"), username, "The original ORM's username should still be " + username)
		  System.DebugLog(OriginalORM.Data("username"))
		  System.DebugLog(NewORM.Data("username"))
		  Assert.IsFalse(NewORM.Data("username") = OriginalORM.Data("username"), "Both ORMs should have different usernames.")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReloadTest()
		  Dim pUserTest As New UserTest()
		  
		  Call pUserTest.Data("username", "Paul-Willy Jean").Data("password", "pile4626").Save(ORMTestDatabase)
		  
		  Assert.IsTrue pUserTest.Loaded
		  
		  Dim pAnotherUserTest As New UserTest()
		  Call pAnotherUserTest.Where("id", "=", pUserTest.Pk()).Find(ORMTestDatabase)
		  Call pAnotherUserTest.Data("username", "Jean").Update(ORMTestDatabase)
		  
		  Assert.AreDifferent(pUserTest.Data("username"), pAnotherUserTest.Data("username"))
		  
		  // Reload data in pUserTest
		  Call pUserTest.Reload(ORMTestDatabase)
		  
		  // pUserTest should be reloaded with the changed value
		  Assert.AreEqual(pUserTest.Data("username").StringValue, pAnotherUserTest.Data("username").StringValue)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveTest()
		  CreateUsers()
		  CreateProjects()
		  DB.Delete("Projects_Users").Execute(ORMTestDatabase)
		  
		  // Loads the UsertTest model from the database
		  Dim pUserTest As New UserTest(1)
		  Call pUserTest.Find()
		  
		  // Loads the ProjectTest model from the database
		  Dim pProjectTest As New ProjectTest(1)
		  Call pProjectTest.Find()
		  
		  // Makes sure that pUserTest is not related to pProjectTest
		  Assert.IsFalse(pUserTest.Has("Project", pProjectTest))
		  
		  // Adds a relation between pUserTest and pProjectTest
		  Call pUserTest.Add("Project", pProjectTest)
		  Assert.IsTrue(pUserTest.Has("Project", pProjectTest))
		  
		  // Removes any relation between pUserTest and any ProjectTest
		  Call pUserTest.Remove("Project")
		  Assert.IsFalse(pUserTest.Has("Project", pProjectTest))
		  
		  Call pUserTest.Add("Project", 1, 2, 3, 4)
		  Assert.IsTrue(pUserTest.Has("Project", 1, 2, 3, 4))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveTest()
		  Dim pUserTest As New UserTest()
		  
		  // Modifie le modele et l'enregistre avec Save
		  Call pUserTest.Data("username","Paul-Willy Jean").Data("password", "pile4626")
		  
		  Assert.AreEqual("Paul-Willy Jean", pUserTest.Data("username"))
		  Assert.AreEqual("pile4626", pUserTest.Data("password"))
		  
		  Assert.IsTrue pUserTest.Changed
		  
		  Call pUserTest.Save(ORMTestDatabase)
		  
		  Assert.IsFalse pUserTest.Changed
		  Assert.IsTrue pUserTest.Loaded
		  
		  Call pUserTest.Unload()
		  
		  Assert.IsFalse pUserTest.Loaded()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TableColumnsTest()
		  Dim pUser As UserTest = new UserTest
		  
		  Dim pColumns() As String = Array("id", "username", "password")
		  
		  Dim pTableColumns() As Variant = pUser.TableColumns(ORMTestDatabase)
		  
		  For i As Integer = 0 To pColumns.UBound
		    Assert.AreEqual(pColumns(i), pTableColumns(i).StringValue)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateLoadedTest()
		  Dim pModel As New UserTest()
		  
		  Call pModel.Data("username", "Jean Dupont")
		  Call pModel.Data("password", pModel.Data("username"))
		  
		  Call pModel.Create(ORMTestDatabase)
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
		  Call pModel.Data("password", "paul2012")
		  
		  Assert.IsTrue pModel.Changed()
		  
		  Call pModel.Update(ORMTestDatabase)
		  
		  Assert.IsFalse pModel.Changed()
		  Assert.IsTrue pModel.Loaded()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateUnloadedTest()
		  Dim pModel As New UserTest()
		  
		  Call pModel.Data("username", "Jean Dupont")
		  Call pModel.Data("password", pModel.Data("username"))
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
		  Assert.IsTrue pModel.Changed(), "L'ORM n'as pas change 1"
		  Assert.IsFalse pModel.Loaded(), "L'ORM n'est pas charge 1"
		  
		  If pModel.Loaded() Then
		    Call pModel.Update(ORMTestDatabase)
		  End If
		  
		  Assert.IsFalse pModel.Loaded(), "L'ORM est charge 2"
		  Assert.IsTrue pModel.Changed, "L'ORM n'as pas change 2"
		  'Try
		  'pModel.Update(ORMTestDatabase)
		  'Catch err As ORMException
		  'Assert.IsFalse pModel.Loaded
		  'Assert.IsTrue pModel.Changed
		  'End Try
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
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
