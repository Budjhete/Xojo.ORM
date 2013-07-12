#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CycleTest()
		  Dim pModel As New UserTest()
		  
		  Assert.IsFalse pModel.Loaded()
		  Assert.IsFalse pModel.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("username") = "Jean"
		  pValues.Value("password") = "LOL"
		  
		  pModel.Data(pValues).Create(ORMTestDatabase)
		  
		  Assert.IsTrue pModel.Loaded()
		  Assert.IsFalse pModel.Changed()
		  
		  pModel.Data("username", "Jean Dupont")
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
		  Assert.IsTrue pModel.Changed()
		  
		  pModel.Update(ORMTestDatabase)
		  
		  Assert.IsFalse pModel.Changed()
		  Assert.IsTrue pModel.Loaded()
		  
		  // Modifie le modele et l'enregistre avec Save
		  pModel.Data("username","Paul-Willy Jean")
		  Assert.AreEqual(pModel.Data("username"), "Paul-Willy Jean")
		  Assert.IsTrue pModel.Changed
		  pModel.Save(ORMTestDatabase)
		  Assert.IsFalse pModel.Changed
		  Dim NewModel As New UserTest()
		  NewModel.Where("id","=", Str(pModel.Pk)).Find(ORMTestDatabase)
		  Assert.AreEqual(pModel.Data("username").StringValue,NewModel.Data("username").StringValue)
		  
		  // Cree le modele et l'enregistre avec Save
		  NewModel = New UserTest()
		  Assert.IsFalse NewModel.Loaded
		  Assert.IsFalse NewModel.Changed
		  NewModel.Data("username", "Guillaume Poirier-Morency")
		  NewModel.Data("password", "pile4626")
		  'Assert.IsTrue NewModel.Changed, "Le modele n'a pas change"
		  NewModel.Save(ORMTestDatabase)
		  Assert.IsFalse NewModel.Changed
		  Assert.IsTrue NewModel.Loaded
		  Assert.IsTrue((NewModel.Pk <> 0), "La cle primaire egale " + Str(NewModel.Pk))
		  
		  // Supprime le modele et verifie l'etat de l'ORM
		  pModel.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse  pModel.Loaded()
		  Assert.IsFalse  pModel.Changed()
		  
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
