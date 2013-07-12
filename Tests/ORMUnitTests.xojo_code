#tag Class
Protected Class ORMUnitTests
Inherits TestGroup
	#tag Method, Flags = &h1000
		Sub Constructor(controller As TestController, groupName As String)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(controller, groupName)
		  
		  mModel = New ModelORMTest()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CycleTest()
		  Assert.IsFalse mModel.Loaded()
		  Assert.IsFalse mModel.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("nom") = "Jean"
		  
		  mModel.Data(pValues).Create(ORMTestDatabase)
		  
		  Assert.IsTrue mModel.Loaded()
		  Assert.IsFalse mModel.Changed()
		  
		  mModel.Data("nom", "Jean Dupont")
		  
		  Assert.AreEqual(mModel.Data("nom"), "Jean Dupont")
		  
		  Assert.IsTrue mModel.Changed()
		  
		  mModel.Update(ORMTestDatabase)
		  
		  Assert.IsFalse mModel.Changed()
		  Assert.IsTrue mModel.Loaded()
		  
		  mModel.Delete(ORMTestDatabase)
		  
		  Assert.IsFalse  mModel.Loaded()
		  Assert.IsFalse  mModel.Changed()
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mModel As ModelORMTest
	#tag EndProperty


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
