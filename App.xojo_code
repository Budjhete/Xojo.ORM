#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  Dim pQueryBuilderMenuItem As MenuItem = New MenuItem("Live QueryBuilder...")
		  pQueryBuilderMenuItem.Name = "OpenQueryBuilderTestWindow"
		  
		  Dim pORMMenuItem As MenuItem = New MenuItem("Live ORM...")
		  pORMMenuItem.Name = "OpenORMTestWindow"
		  
		  XojoUnitMenuBar.Child("FileMenu").Insert(1, pQueryBuilderMenuItem)
		  XojoUnitMenuBar.Child("FileMenu").Insert(2, pORMMenuItem)
		  
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function OpenORMTestWindow() As Boolean Handles OpenORMTestWindow.Action
			ORMTestWindow.Show
			
			Return True
			
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function OpenQueryBuilderTestWindow() As Boolean Handles OpenQueryBuilderTestWindow.Action
			QueryBuilderTestWindow.Show
			
			Return True
			
		End Function
	#tag EndMenuHandler


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
