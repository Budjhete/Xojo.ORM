#tag Class
Protected Class QueryBuilderUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub JoinTest()
		  System.DebugLog("BEGINS TESTS FOR QueryBuilder.Join()")
		  Dim Record As RecordSet
		  
		  DB.Delete("Groups").Execute(ORMTestDatabase)
		  DB.Delete("Users").Execute(ORMTestDatabase)
		  
		  DB.Insert("Users", Array("username", "password")).Values("Hete.ca", "hete").Execute(ORMTestDatabase)
		  DB.Insert("Groups", Array("name", "userId")).Values("Developpeur", 1).Execute(ORMTestDatabase)
		  DB.Insert("Groups", Array("name")).Values("Gestionnaire").Execute(ORMTestDatabase)
		  
		  System.DebugLog(DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.userId").Compile())
		  Record = DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.userId").Execute(ORMTestDatabase)
		  System.DebugLog(ShowSelect(Record))
		  Assert.IsTrue(Record.RecordCount = 1, "We should have exactly one record")
		  
		  System.DebugLog(DB.Find("Groups").Join("LEFT", "Users").On("Groups.userId", "=", "Users.id").Compile())
		  Record = DB.Find("Groups").Join("LEFT", "Users").On("Groups.userId", "=", "Users.id").Execute(ORMTestDatabase)
		  System.DebugLog(ShowSelect(Record))
		  Assert.IsTrue(Record.RecordCount = 2, "We should have exactly two records")
		  
		  System.DebugLog(DB.Find("Groups").Join("","Users").On("Groups.userId", "=", "Users.id").Compile())
		  Record = DB.Find("Groups").Join("","Users").On("Groups.userId", "=", "Users.id").Execute(ORMTestDatabase)
		  System.DebugLog(ShowSelect(Record))
		  Assert.IsTrue(Record.RecordCount = 1, "We should have exactly one record")
		  
		  Record = DB.Find("Users").Join("LEFT", "Groups").On("Users.id", "=", "Groups.user").Where("Users.username", "LIKE", "%ete%").Execute(ORMTestDatabase)
		  System.DebugLog("ENDS TESTS FOR QueryBuilder.Join()")
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
		    StringRecord = StringRecord + "}" + EndOfLine
		    pRecord.MoveNext
		  Wend
		  
		  return StringRecord
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ValuesTest()
		  Dim Record As RecordSet
		  Dim MyValues() As Variant
		  
		  // Inserts a new entry with ParamArrays in Values
		  DB.Insert("Users", Array("username", "password")).Values("Hete", ".ca").Execute(ORMTestDatabase)
		  
		  Record = DB.Find("Users").Where("username", "=", "Hete").OrderBy("id", "DESC").Limit(1).Execute(ORMTestDatabase)
		  Assert.IsNotNil(Record, "We should have found at least one entry where the username is Hete")
		  
		  // Inserts a new entry with a Variant Array in Values
		  MyValues.Append("Hete.ca")
		  MyValues.Append(".ca")
		  DB.Insert("Users", Array("username", "password")).Values(MyValues).Execute(ORMTestDatabase)
		  
		  Record = DB.Find("Users").Where("username", "=", "Hete.ca").OrderBy("id", "DESC").Limit(1).Execute(ORMTestDatabase)
		  Assert.IsNotNil(Record, "We should have found at least one entry where the username is Hete.ca")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WhereTest()
		  System.DebugLog("BEGINS TESTS QueryBuilder.Where()")
		  Dim Record As RecordSet
		  
		  // Creates a new entry in the Database
		  DB.Insert("Users", Array("username", "password")).Values("Paul", "Willy").Execute(ORMTestDatabase)
		  DB.Insert("Users", Array("username", "password")).Values("Paul", "1234").Execute(ORMTestDatabase)
		  
		  // Creates a second entry with an empty field in the Database
		  DB.Insert("Users", Array("username")).Values("John Lajoie").Execute(ORMTestDatabase)
		  
		  // Create a third entry with all fields set
		  DB.Insert("Users", Array("username", "password")).Values("John Lajoie", "1234").Execute(ORMTestDatabase)
		  
		  // Looks up a record where the username contains "John" and where
		  // the password is NULL or where the username contains "John" and where the password is "1234"
		  Record = DB.Find("Users").Where("username", "LIKE", "%John%").AndWhere("password", "IS", Nil).OrWhere("password", "=", "1234").Execute(ORMTestDatabase)
		  Assert.IsNotNil(Record, "We should have at least one entry where the username contains"+_
		  "John and where the password is NULL or where the username is anything and the password equals ""1234""")
		  System.DebugLog(DB.Find("Users").Where("username", "LIKE", "%John%").AndWhere("password", "=", Nil).OrWhere("password", "=", "1234").Compile())
		  System.DebugLog(ShowSelect(Record))
		  
		  // Looks up a record where the username is Paul
		  Record = DB.Find("Users").Where("username", "=", "Paul").OrderBy("id").Execute(ORMTestDatabase)
		  // Logs the new Entry
		  System.DebugLog(DB.Find("Users").Where("username", "=", "Paul").OrderBy("id").Compile())
		  System.DebugLog(ShowSelect(Record))
		  
		  // Tests a where using a LIKE comparison
		  Record = DB.Find("Users").Where("username", "LIKE", "Pau%").Execute(ORMTestDatabase)
		  System.DebugLog(DB.Find("Users").Where("username", "LIKE", "Pau%").Compile())
		  System.DebugLog(ShowSelect(Record))
		  
		  Assert.IsNotNil(Record)
		  
		  System.DebugLog("ENDS TESTS QueryBuilder.Where()")
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
