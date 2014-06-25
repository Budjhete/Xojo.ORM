#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Event
		Sub TearDown()
		  // Clean the database
		  ORMTestDatabase.SQLExecute("DELETE FROM Users")
		  ORMTestDatabase.SQLExecute("DELETE FROM Projects")
		  ORMTestDatabase.SQLExecute("DELETE FROM Groups")
		  ORMTestDatabase.Commit
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddTest()
		  Dim pUser As New UserTest
		  pUser.username = "John Doe"
		  Call pUser.Create(ORMTestDatabase)
		  
		  Dim pGroup As New GroupTest
		  Call pGroup.Create(ORMTestDatabase)
		  
		  Dim pProject As New ProjectTest
		  pProject.name = "ORM"
		  Call pProject.Create(ORMTestDatabase)
		  
		  // HasMany
		  Assert.IsFalse pUser.Has("user", pGroup, ORMTestDatabase)
		  
		  Call pUser.Add("user", pGroup).Update(ORMTestDatabase)
		  Assert.IsTrue pUser.Has("user", pGroup, ORMTestDatabase)
		  
		  Call pGroup.Reload(ORMTestDatabase)
		  Assert.AreEqual(pUser.Pk.IntegerValue, pGroup.Data("user").IntegerValue)
		  
		  // HasManyThrough
		  Assert.IsFalse pUser.Has(pProject, ORMTestDatabase)
		  
		  Call pUser.Add("UsersProjects", "user", "project", pProject)
		  Assert.IsFalse pUser.Has(pProject, ORMTestDatabase)
		  
		  Call pUser.Update(ORMTestDatabase)
		  Assert.IsTrue pUser.Has(pProject, ORMTestDatabase)
		  
		  
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConstructorTest()
		  DB.Insert("Users", "id", "username", "password"). _
		  Values(1, "foo", "bar"). _
		  Execute(ORMTestDatabase)
		  
		  // Primary key and Database
		  Dim pUser As New UserTest(1, ORMTestDatabase)
		  Assert.IsTrue pUser.Loaded
		  
		  // Criteria dictionary
		  pUser = New UserTest("id": 1)
		  Assert.IsFalse pUser.Loaded
		  Call pUser.Find(ORMTestDatabase)
		  Assert.IsTrue pUser.Loaded
		  
		  // From a RecordSet
		  Dim pRecordSet As RecordSet = DB.Find.From("Users").Where("id", "=", 1).Execute(ORMTestDatabase)
		  Assert.AreEqual(pRecordSet.RecordCount, 1)
		  pUser = New UserTest(pRecordSet)
		  Assert.IsTrue pUser.Loaded
		  
		  // From another ORM (not a copy!)
		  pUser = New UserTest(pUser)
		  Assert.IsFalse pUser.Loaded
		  Call pUser.Find(ORMTestDatabase)
		  Assert.IsTrue pUser.Loaded
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConverFromRecordSetTest()
		  Dim pUsers As New UserTest
		  
		  Dim pRecords As RecordSet = pUsers.FindAll(ORMTestDatabase)
		  
		  While Not pRecords.EOF
		    Dim pUser As New UserTest(pRecords)
		    Assert.AreEqual(pRecords.Field("username").StringValue, pUser.Data("username").StringValue)
		    pRecords.MoveNext
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CopyTest()
		  Dim pUser As New UserTest
		  
		  pUser.Data("username") = "Paul-Willy"
		  pUser.Data("password") = "password"
		  
		  Dim pCopy As UserTest = pUser.Copy
		  
		  Assert.IsFalse(pUser Is pCopy)
		  Assert.AreEqual(pUser.username, pCopy.username)
		  Assert.AreEqual(pUser.password, pCopy.password)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateTest()
		  Dim pUser As New UserTest()
		  
		  Assert.IsFalse pUser.Loaded()
		  Assert.IsFalse pUser.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("username") = "Jean"
		  pValues.Value("password") = "LOL"
		  
		  Call pUser.Data(pValues).Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUser.Loaded()
		  Assert.IsFalse pUser.Changed(), "L'ORM a change"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DataTest()
		  Dim pUser As New UserTest
		  
		  Assert.IsFalse pUser.Changed
		  
		  pUser.Data("name") = "Foo"
		  Assert.AreEqual(pUser.Data("name").StringValue, "Foo")
		  Assert.IsTrue pUser.Changed
		  
		  // Computed property
		  pUser.name = "Bar"
		  Assert.AreEqual(pUser.name, "Bar")
		  Assert.IsTrue pUser.Changed
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteTest()
		  Dim pUser As New UserTest
		  
		  Call pUser.Data("username", "Paul-Willy Jean").Data("password", "Jean").Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUser.Loaded, "Created model is not loaded."
		  Assert.IsFalse pUser.Changed, "Created model is changed."
		  
		  Call pUser.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse pUser.Loaded, "Deleted model is loaded."
		  Assert.IsFalse pUser.Changed, "Deleted model is changed."
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindTest()
		  Dim pUser As New UserTest
		  
		  Call pUser.Data("username", "james").Data("password", "james22").Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUser.Loaded
		  
		  Dim pk As Variant = pUser.Pk()
		  
		  Call pUser.Unload()
		  
		  Assert.IsFalse pUser.Loaded
		  
		  Call pUser.Where("id", "=", pk).Find(ORMTestDatabase)
		  
		  Assert.AreEqual("james", pUser.username)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HasTest()
		  Dim pUser As New UserTest(1, ORMTestDatabase)
		  
		  // Has for HasMany
		  
		  
		  // Has for HasManyThrough
		  ' Assert.IsTrue mUserTest.Has("UsersProjects", "user", "project", ORMTestDatabase)
		  
		  Call pUser.Delete(ORMTestDatabase)
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InflateTest()
		  // @deprecated This feature is deprecated
		  
		  Dim OriginalORM As New UserTest
		  
		  Dim username As String = "Kandjo"
		  Dim password As String = "ca"
		  
		  Call OriginalORM.Data("username", username)
		  Call OriginalORM.Data("password", password)
		  
		  Dim NewORM As New UserTest()
		  Call OriginalORM.Inflate(NewORM)
		  
		  Assert.AreEqual(NewORM.TableName(), OriginalORM.TableName(), NewORM.TableName() + " " + OriginalORM.TableName())
		  Assert.AreEqual(username, OriginalORM.Data("username"), "The original ORM's username should be " + username)
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
		Sub JSONValueTest()
		  Dim pUserTest As New UserTest
		  
		  pUserTest.username = "John Doe"
		  
		  Dim pJSONItem As JSONItem = pUserTest.JSONValue
		  
		  Assert.AreEqual(pUserTest.username, pJSONItem.Value("username"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrimaryKeysTest()
		  Dim pUserProject As New UserProjectTest
		  Dim pUser As New UserTest
		  Dim pAnotherUser As New UserTest
		  Dim pProject As New ProjectTest
		  
		  pUser.username = "John"
		  pUser.password = "Michael"
		  Call pUser.Create(ORMTestDatabase)
		  
		  pAnotherUser.username = "James"
		  pAnotherUser.password = "Norton"
		  Call pAnotherUser.Create(ORMTestDatabase)
		  
		  pProject.name = "Work in a store!"
		  Call pProject.Create(ORMTestDatabase)
		  
		  Assert.IsFalse pUserProject.Loaded
		  
		  pUserProject.user = pUser
		  pUserProject.project = pProject
		  
		  Assert.IsFalse pUserProject.Loaded
		  Assert.IsTrue pUserProject.Changed
		  
		  Call pUserProject.Create(ORMTestDatabase)
		  
		  Assert.IsTrue pUserProject.Loaded
		  Assert.IsFalse pUserProject.Changed
		  
		  Assert.IsTrue pUser.Has(pProject, ORMTestDatabase)
		  Assert.IsTrue pProject.Has(pUser, ORMTestDatabase)
		  
		  // Update
		  System.DebugLog pUserProject.Dump
		  pUserProject.user = pAnotherUser
		  System.DebugLog pUserProject.Dump
		  
		  Call pUserProject.Update(ORMTestDatabase)
		  
		  Assert.IsTrue pUserProject.Loaded
		  
		  // Delete
		  Call pUserProject.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse pUserProject.Loaded
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
		  // Fixtures
		  DB.Insert("Users", "username", "password").Values("Budjhete", ".com").Execute(ORMTestDatabase)
		  DB.Insert("Users", "username", "password").Values("Kanjo", ".com").Execute(ORMTestDatabase)
		  
		  DB.Insert("Projects", "name").Values("Budjhete").Execute(ORMTestDatabase)
		  DB.Insert("Projects", "name").Values("Kanjo").Execute(ORMTestDatabase)
		  DB.Insert("Projects", "name").Values("Hete").Execute(ORMTestDatabase)
		  DB.Insert("Projects", "name").Values("Vee").Execute(ORMTestDatabase)
		  
		  // Loads the UsertTest model from the database
		  Dim pUserTest As New UserTest
		  Call pUserTest.Find(ORMTestDatabase)
		  
		  // Loads the ProjectTest model from the database
		  Dim pProjectTest As New ProjectTest
		  Call pProjectTest.Find(ORMTestDatabase)
		  
		  // Remove all relationships
		  Call pUserTest.Remove("UsersProjects", "user", "project").Update(ORMTestDatabase)
		  Assert.IsFalse pUserTest.Has("UsersProjects", "user", ORMTestDatabase)
		  
		  // Add a single relationship
		  Call pUserTest.Add("UsersProjects", "user", "project", pProjectTest).Update(ORMTestDatabase)
		  Assert.IsTrue pUserTest.Has("UsersProjects", "user", "project", pProjectTest, ORMTestDatabase)
		  
		  // Remove a single relationship
		  Call pUserTest.Remove("UsersProjects", "user", "project", pProjectTest).Update(ORMTestDatabase)
		  Assert.IsFalse pUserTest.Has("UsersProjects", "user", "project", pProjectTest, ORMTestDatabase)
		  
		  // Add multiple relationships
		  
		  // Remove multiple relationships
		  
		  // HasMany
		  
		  Dim pGroup As New GroupTest
		  Call pGroup.Create(ORMTestDatabase)
		  
		  Assert.IsTrue pGroup.Loaded
		  
		  // Add a relationship
		  Assert.IsFalse pUserTest.Has("user", pGroup, ORMTestDatabase)
		  Call pUserTest.Add("user", pGroup).Update(ORMTestDatabase)
		  Assert.IsTrue pUserTest.Has("user", pGroup, ORMTestDatabase)
		  
		  // Remove a relationship
		  Call pUserTest.Remove("user", pGroup).Update(ORMTestDatabase)
		  Assert.IsFalse pUserTest.Has("user", pGroup, ORMTestDatabase)
		  
		  // Add the same relationship
		  Call pUserTest.Add("user", pGroup).Update(ORMTestDatabase)
		  
		  // Hard-remove the relationship
		  Call pUserTest.Remove(New ORMRelationHasManyHard("user", pGroup)).Update(ORMTestDatabase)
		  Assert.IsFalse pUserTest.Has("user", pGroup, ORMTestDatabase)
		  Assert.IsFalse pGroup.Reload(ORMTestDatabase).Loaded
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveTest()
		  Dim pUser As New UserTest()
		  
		  Call pUser.Data("username","Paul-Willy Jean").Data("password", "pile4626")
		  Assert.AreEqual("Paul-Willy Jean", pUser.Data("username"))
		  Assert.AreEqual("pile4626", pUser.Data("password"))
		  Assert.IsTrue pUser.Changed
		  
		  Call pUser.Save(ORMTestDatabase)
		  Assert.IsFalse pUser.Changed
		  Assert.IsTrue pUser.Loaded
		  
		  Call pUser.Delete(ORMTestDatabase)
		  Assert.IsFalse pUser.Loaded
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TableColumnsTest()
		  Dim pUser As New UserTest
		  
		  Dim pColumns() As String = Array("id", "username", "password")
		  
		  Dim pTableColumns() As String = pUser.TableColumns(ORMTestDatabase)
		  
		  For i As Integer = 0 To pColumns.UBound
		    Assert.AreEqual(pColumns(i), pTableColumns(i))
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

	#tag Method, Flags = &h0
		Sub XMLValueTest()
		  Dim pUserTest As New UserTest
		  
		  pUserTest.username = "John Doe"
		  
		  Dim pXmlDocument As New XmlDocument
		  Dim pXmlNode As XmlNode = pUserTest.XMLValue(pXmlDocument)
		  
		  Assert.AreEqual(pUserTest.username, pXmlNode.GetAttribute("username"))
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
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
