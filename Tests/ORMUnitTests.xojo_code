#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CreateTest()
		  Dim pModel As New UserTest()
		  
		  Assert.IsFalse pModel.Loaded()
		  Assert.IsFalse pModel.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("username") = "Jean"
		  pValues.Value("password") = "LOL"
		  
		  pModel.Data(pValues).Create(ORMTestDatabase)
		  
		  Assert.IsTrue pModel.Loaded()
		  Assert.IsFalse pModel.Changed(), "L'ORM a change"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteTest()
		  Dim DeleteModel As New UserTest()
		  DeleteModel.Data("username", "Paul-Willy Jean")
		  DeleteModel.Data("password", "Jean")
		  DeleteModel.Create(ORMTestDatabase)
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
		  System.DebugLog(DB.Find().From("User").Compile())
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReloadTest()
		  Dim ReloadModel As New UserTest()
		  ReloadModel.Data("username", "Paul-Willy Jean")
		  ReloadModel.Data("password", "pile4626")
		  ReloadModel.Save(ORMTestDatabase)
		  Dim NewReloadModel As New UserTest()
		  NewReloadModel.Where("id", "=", ReloadModel.Pk()).Find(ORMTestDatabase)
		  
		  // S'assure qu'on aie repris la bonne entree en BD
		  Assert.AreEqual(ReloadModel.Data("username").StringValue, NewReloadModel.Data("username").StringValue)
		  
		  ReloadModel.Data("username", "Paul")
		  // Les deux objets ne doivent pas avoir le meme username
		  Assert.IsFalse(ReloadModel.Data("username").StringValue = NewReloadModel.Data("username").StringValue)
		  ReloadModel.Save(ORMTestDatabase)
		  // Recharge du modele copie pour qu'il reprenne les valeurs de la BD
		  NewReloadModel.Reload(ORMTestDatabase)
		  // Les deux objects devraient avoir le meme username
		  Assert.AreEqual(ReloadModel.Data("username").StringValue, NewReloadModel.Data("username").StringValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveTest()
		  Dim SaveModel As New UserTest()
		  // Modifie le modele et l'enregistre avec Save
		  SaveModel.Data("username","Paul-Willy Jean")
		  SaveModel.Data("password", "pile4626")
		  Assert.AreEqual(SaveModel.Data("username"), "Paul-Willy Jean")
		  Assert.AreEqual(SaveModel.Data("password"), "pile4626")
		  Assert.IsTrue SaveModel.Changed
		  SaveModel.Save(ORMTestDatabase)
		  Assert.IsFalse SaveModel.Changed
		  Dim NewSaveModel As New UserTest()
		  NewSaveModel.Where("id","=", SaveModel.Pk).Find(ORMTestDatabase)
		  Assert.AreEqual(SaveModel.Data("username").StringValue,NewSaveModel.Data("username").StringValue), "SaveModel = " + SaveModel.Data("username") + ", NewSaveModel = " + NewSaveModel.Data("username")
		  
		  // Cree le modele et l'enregistre avec Save
		  NewSaveModel = New UserTest()
		  Assert.IsFalse NewSaveModel.Loaded
		  Assert.IsFalse NewSaveModel.Changed
		  NewSaveModel.Data("username", "Guillaume Poirier-Morency")
		  NewSaveModel.Data("password", "pile4626")
		  Assert.IsTrue NewSaveModel.Changed, "Le modele n'a pas change"
		  NewSaveModel.Save(ORMTestDatabase)
		  Assert.IsFalse NewSaveModel.Changed
		  Assert.IsTrue NewSaveModel.Loaded, "La cle primaire egale " + Str(NewSaveModel.Pk)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateLoadedTest()
		  Dim pModel As New UserTest()
		  
		  pModel.Data("username", "Jean Dupont")
		  pModel.Data("password", pModel.Data("username"))
		  
		  pModel.Create(ORMTestDatabase)
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
		  pModel.Data("password", "paul2012")
		  
		  Assert.IsTrue pModel.Changed()
		  
		  pModel.Update(ORMTestDatabase)
		  
		  Assert.IsFalse pModel.Changed()
		  Assert.IsTrue pModel.Loaded()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateUnloadedTest()
		  Dim pModel As New UserTest()
		  
		  pModel.Data("username", "Jean Dupont")
		  pModel.Data("password", pModel.Data("username"))
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
		  Assert.IsTrue pModel.Changed(), "L'ORM n'as pas change 1"
		  Assert.IsFalse pModel.Loaded(), "L'ORM n'est pas charge 1"
		  
		  If pModel.Loaded() Then
		    pModel.Update(ORMTestDatabase)
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
