#tag Class
Protected Class DBUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub ConnectSQLiteTest()
		  Dim pDatabase As Database
		  
		  // SQLite
		  Dim pDatabaseRef As New SQLiteDatabase
		  pDatabaseRef.DatabaseFile = GetTemporaryFolderItem
		  Assert.IsTrue pDatabaseRef.CreateDatabaseFile
		  
		  // SQLite avec un AbsolutePath
		  pDatabase = DB.Connect("sqlite://" + pDatabaseRef.DatabaseFile.AbsolutePath)
		  Assert.IsNotNil(pDatabase, "sqlite://" + pDatabaseRef.DatabaseFile.AbsolutePath)
		  Assert.IsTrue pDatabase IsA SQLiteDatabase
		  
		  // SQLite avec un NativePath
		  pDatabase = DB.Connect("sqlite://" + pDatabaseRef.DatabaseFile.NativePath)
		  Assert.IsNotNil(pDatabase, "sqlite://" + pDatabaseRef.DatabaseFile.NativePath)
		  Assert.IsTrue pDatabase IsA SQLiteDatabase
		  
		  // SQLite avec un ShellPath
		  pDatabase = DB.Connect("sqlite://" + pDatabaseRef.DatabaseFile.ShellPath)
		  Assert.IsNotNil(pDatabase, "sqlite://" + pDatabaseRef.DatabaseFile.ShellPath)
		  Assert.IsTrue pDatabase IsA SQLiteDatabase
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
