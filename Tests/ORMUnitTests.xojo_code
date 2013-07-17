#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CreateTest()
		  Dim pModel As New UserTest()
		  
		  For Each pColumn As String In pModel.TableColumns()
		    Assert.IsTrue pModel.Data().HasKey(pColumn)
		  Next
		  
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
		Sub CycleTest()
		  Dim pModel As New UserTest()
		  // Modifie le modele et l'enregistre avec Save
		  pModel.Data("username","Paul-Willy Jean")
		  pModel.Data("password", "pile4626")
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
		  Assert.IsTrue NewModel.Changed, "Le modele n'a pas change"
		  NewModel.Save(ORMTestDatabase)
		  Assert.IsFalse NewModel.Changed
		  Assert.IsTrue NewModel.Loaded
		  Assert.IsTrue((NewModel.Pk <> 0), "La cle primaire egale " + Str(NewModel.Pk))
		  
		  // Supprime le modele et verifie l'etat de l'ORM
		  pModel.Delete(ORMTestDatabase)
		  
		  'Assert.IsFalse  pModel.Loaded()
		  'Assert.IsFalse  pModel.Changed()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateLoadedTest()
		  Dim pModel As New UserTest()
		  
		  pModel.Data("username", "Jean Dupont")
		  pModel.Data("password", pModel.Data("username"))
		  
		  pModel.Create(ORMTestDatabase)
		  
		  Assert.AreEqual(pModel.Data("username"), "Jean Dupont")
		  
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
