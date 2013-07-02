#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  App.AutoQuit = True
		  
		  ORM.Database = ORMTestDatabase
		  mModel = New ModelORMTest()
		  
		  TestCreate()
		  
		  TestUpdate()
		  
		  TestDelete()
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AssertEquals(pValue As Variant, pExpected As Variant)
		  If Not pValue = pExpected Then
		    Raise New RuntimeException()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AssertFalse(pExpression As Boolean)
		  If pExpression Then
		    Raise New RuntimeException()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AssertTrue(pExpression As Boolean)
		  If Not pExpression Then
		    Raise New RuntimeException()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TestCreate()
		  AssertFalse mModel.Loaded()
		  AssertFalse mModel.Changed()
		  
		  Dim pValues As New Dictionary()
		  pValues.Value("nom") = "Jean"
		  
		  mModel.Data(pValues).Create()
		  
		  AssertTrue mModel.Loaded()
		  AssertFalse mModel.Changed()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TestDelete()
		  AssertTrue mModel.Loaded()
		  
		  mModel.Delete()
		  
		  AssertFalse mModel.Loaded()
		  AssertFalse mModel.Changed()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TestUpdate()
		  AssertFalse mModel.Changed()
		  AssertTrue mModel.Loaded()
		  
		  mModel.Data("nom", "Jean Dupont")
		  
		  AssertEquals(mModel.Data("nom"), "Jean Dupont")
		  
		  AssertTrue mModel.Changed()
		  
		  mModel.Update()
		  
		  AssertFalse mModel.Changed()
		  AssertTrue mModel.Loaded()
		  
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mModel As ModelORMTest
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
