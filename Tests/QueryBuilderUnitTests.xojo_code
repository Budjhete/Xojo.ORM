#tag Class
Protected Class QueryBuilderUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub JoinTest()
		  DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  
		  Dim recordSet As RecordSet = DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  
		  DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Where("Users.username", "LIKE", "%John%").Execute(ORMTestDatabase)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTest()
		  Dim valeurs() As Variant
		  valeurs.Append("Paul-willy Jean")
		  valeurs.Append("paulwillyjean")
		  
		  // Creates a new entry in the database
		  DB.Insert("Users", Array("username", "password")).Values(valeurs).Execute(ORMTestDatabase)
		  
		  // Fetches the new entry in the database
		  Dim Record As RecordSet = DB.Find("Users").Where("username", "=", valeurs(0).StringValue).OrderBy("id").Execute(ORMTestDatabase)
		  Record.MoveLast()
		  
		  // Updates the entry in the database
		  DB.Update("Users").Set(New Dictionary("username": "P-Dob", "password": "paul")).Where("id", "=", Record.Field("id").StringValue).Execute(ORMTestDatabase)
		  
		  // Fetches the modified entry int the database
		  Dim UpdateRecord As RecordSet = DB.Find("Users").Where("id", "=", Record.Field("id")).Execute(ORMTestDatabase)
		  
		  // Compares the old and the new entry to make sure that the values are indeed different
		  Assert.IsFalse(Record.Field("username").StringValue = UpdateRecord.Field("username").StringValue)
		  
		  // Updates @Record to reflect the modification in the DB
		  Record = DB.Find("Users").Where("id", "=", Record.Field("id").StringValue).Execute(ORMTestDatabase)
		  
		  // Compares @Record and @UpdateRecord to make sure that they are both the same
		  Assert.AreEqual(Record.Field("username").StringValue, UpdateRecord.Field("username").StringValue)
		  
		  // In order not to pollute the DB
		  DB.Delete("Users").Where("id", "=", Record.Field("id").StringValue).Execute(ORMTestDatabase)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShowSelect(pRecord As RecordSet) As String
		  If pRecord Is Nil Then
		    return ""
		  End If
		  
		  Dim StringRecord As String = ""
		  
		  While Not pRecord.EOF
		    Dim FieldCount As Integer = pRecord.FieldCount
		    StringRecord = StringRecord + "{"
		    For Field As Integer = 1 To FieldCount
		      StringRecord = StringRecord + pRecord.IdxField(Field).Name + " : """ + pRecord.IdxField(Field).Value + """"
		      
		      If Field <> FieldCount Then
		        StringRecord = StringRecord + ", "
		      End If
		    Next
		    StringRecord = StringRecord + "}\n"
		    pRecord.MoveNext
		  Wend
		  
		  return StringRecord
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WhereTest()
		  DB.Find("Users").Where("username", "LIKE", "%John%").Execute(ORMTestDatabase)
		  
		  MsgBox DB.Find("Users").Where("username", "LIKE", "%John%").AndWhere("password", "=", Nil).OrWhere("password", "=", "1234").Compile()
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
