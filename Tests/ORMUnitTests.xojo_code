#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CloneTest()
		  Dim OriginalORM As New UserTest
		  Dim username As String = "Kandjo"
		  Dim password As String = "ca"
		  
		  Call OriginalORM.Data("username", username)
		  Call OriginalORM.Data("password", password)
		  
		  Dim NewORM As New UserTest(OriginalORM)
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
		Sub DeleteTest()
		  Dim DeleteModel As New UserTest()
		  
		  Call DeleteModel.Data("username", "Paul-Willy Jean").Data("password", "Jean").Create(ORMTestDatabase)
		  
		  Assert.IsTrue(DeleteModel.Loaded())
		  Assert.IsFalse(DeleteModel.Changed()), "Le modele est enregistre, mais il a quand-meme change"
		  
		  // Supprime le modele et verifie l'etat de l'ORM
		  DeleteModel.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse  DeleteModel.Loaded(), "Le modele reste tout de meme charge"
		  Assert.IsFalse  DeleteModel.Changed(), "L'ORM a change, mais il n'existe plus."
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
