#tag Class
Protected Class QueryBuilderUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CachedTest()
		  // Cache for 5 seconds
		  Dim pExpiration As Date = New Date
		  pExpiration.Year = pExpiration.Year + 1
		  
		  Dim pRecordSet As RecordSet = DB.Find("id"). _
		  From("Users"). _
		  Execute(ORMTestDatabase, pExpiration)
		  
		  Dim pCachedRecordSet As RecordSet = DB.Find("id"). _
		  From("Users"). _
		  Execute(ORMTestDatabase, pExpiration)
		  
		  Assert.AreSame(pRecordSet, pCachedRecordSet)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindTest()
		  Dim pStatement As String
		  Dim pRecordSet As RecordSet
		  
		  // SELECT * statement
		  pStatement = DB.Find.From("Users").Compile()
		  pRecordSet = DB.Find.From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users`", pStatement)
		  
		  // Simple SELECT statement
		  pStatement = DB.Find("id").From("Users").Compile()
		  pRecordSet = DB.Find("id").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT `id` FROM `Users` AS `Users`", pStatement)
		  
		  // Multiple SELECT statement
		  pStatement = DB.Find("id", "username").From("Users").Compile()
		  pRecordSet = DB.Find("id", "username").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT `id`, `username` FROM `Users` AS `Users`", pStatement)
		  
		  // Count Expression in SELECT
		  pStatement = DB.Find(DB.Count("id"), "username").From("Users").Compile()
		  pRecordSet = DB.Find(DB.Count("id"), "username").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT COUNT( `id` ), `username` FROM `Users` AS `Users`", pStatement)
		  
		  pStatement = DB.Find(DB.Count("id", "count"), "username").From("Users").Compile()
		  pRecordSet = DB.Find(DB.Count("id", "count"), "username").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT COUNT( `id` ) AS `count`, `username` FROM `Users` AS `Users`", pStatement)
		  
		  pStatement = DB.Find(DB.Count(), "username").From("Users").Compile()
		  pRecordSet = DB.Find(DB.Count(), "username").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT COUNT( * ), `username` FROM `Users` AS `Users`", pStatement)
		  
		  
		  // Distinct Expression in SELECT
		  pStatement = DB.Find(DB.Distinct("id"), "username").From("Users").Compile()
		  pRecordSet = DB.Find(DB.Distinct("id"), "username").From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT DISTINCT ( `id` ), `username` FROM `Users` AS `Users`", pStatement)
		  
		  // Add more SELECT expression on existing SELECT expression
		  Dim pColumns() As Variant
		  pColumns.Append("username")
		  
		  pStatement = DB.Find("id").Append(new SelectQueryExpression(pColumns)).From("Users").Compile()
		  pRecordSet = DB.Find("id").Append(new SelectQueryExpression(pColumns)).From("Users").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT `id` , `username` FROM `Users` AS `Users`", pStatement)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HavingTest()
		  Dim pStatement As String
		  Dim pRecordSet As RecordSet
		  
		  // Tests for HavingOpen and HavingClose
		  pStatement = DB.Find.From("Users").GroupBy("username").HavingOpen.Having("username", "=", "Paul").HavingClose.Compile()
		  pRecordSet = DB.Find.From("Users").GroupBy("username").HavingOpen.Having("username", "=", "Paul").HavingClose.Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` GROUP BY `username` HAVING ( `username` = 'Paul' )", pStatement)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InflateTest()
		  Dim pQueryBuilder As New QueryBuilder
		  
		  Call pQueryBuilder.Where("A", "=", "A")
		  
		  Dim pNewQueryBuilder As New QueryBuilder
		  
		  Call pNewQueryBuilder.Inflate(pQueryBuilder)
		  
		  Assert.AreEqual(pQueryBuilder.Compile, pNewQueryBuilder.Compile)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub JoinTest()
		  System.DebugLog("BEGINS TESTS FOR QueryBuilder.Join()")
		  Dim pRecordSet As RecordSet
		  Dim pStatement As String
		  
		  DB.Delete("Groups").Execute(ORMTestDatabase)
		  DB.Delete("Users").Execute(ORMTestDatabase)
		  
		  DB.Insert("Users", "username", "password").Values("Hete.ca", "hete").Execute(ORMTestDatabase)
		  DB.Insert("Groups", "name", "user").Values("Developpeur", 1).Execute(ORMTestDatabase)
		  DB.Insert("Groups", "name").Values("Gestionnaire").Execute(ORMTestDatabase)
		  
		  // Tests for a simple left join on the Users table. The syntax is likely to change very soon
		  pStatement = DB.Find().From("Users").Join("Groups").On("Users.id", "=", "Groups.user").Compile()
		  pRecordSet = DB.Find().From("Users").Join("Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  Assert.AreEqual ("SELECT * FROM `Users` AS `Users` JOIN `Groups` AS `Groups` ON `Users`.`id` = `Groups`.`user`", pStatement)
		  
		  // Tests for a simple left join on the Groups table.
		  pStatement = DB.Find.From("Groups").Join("Users").On("Groups.user", "=", "Users.id").Compile()
		  pRecordSet = DB.Find.From("Groups").Join("Users").On("Groups.user", "=", "Users.id").Execute(ORMTestDatabase)
		  Assert.AreEqual ("SELECT * FROM `Groups` AS `Groups` JOIN `Users` AS `Users` ON `Groups`.`user` = `Users`.`id`", pStatement)
		  
		  // Join with different alias
		  pStatement =  DB.Find.From("Users", "U").Join("Groups", "G").Where("U.username", "LIKE", "%ete%").Compile()
		  pRecordSet = DB.Find.From("Users", "U").Join("Groups", "G").Where("U.username", "LIKE", "%ete%").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `U` JOIN `Groups` AS `G` WHERE `U`.`username` LIKE '%ete%'", pStatement)
		  
		  // Multi-join
		  pStatement = DB.Find.From("Users").Join("Groups").On("Groups.id", "=", "G.id").Join("Groups", "G").On("Groups.id", "=", "G.id").Where("Users.username", "LIKE", "%ete%").Compile()
		  pRecordSet = DB.Find.From("Users").Join("Groups").On("Groups.id", "=", "G.id").Join("Groups", "G").On("Groups.id", "=", "G.id").Where("Users.username", "LIKE", "%ete%").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` JOIN `Groups` AS `Groups` ON `Groups`.`id` = `G`.`id` JOIN `Groups` AS `G` ON `Groups`.`id` = `G`.`id` WHERE `Users`.`username` LIKE '%ete%'", pStatement)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LeftOuterJoinTest()
		  System.DebugLog("BEGINS TESTS FOR QueryBuilder.Join()")
		  Dim pRecordSet As RecordSet
		  Dim pStatement As String
		  
		  DB.Delete("Groups").Execute(ORMTestDatabase)
		  DB.Delete("Users").Execute(ORMTestDatabase)
		  
		  DB.Insert("Users", "username", "password").Values("Hete.ca", "hete").Execute(ORMTestDatabase)
		  DB.Insert("Groups", "name", "user").Values("Developpeur", 1).Execute(ORMTestDatabase)
		  DB.Insert("Groups", "name").Values("Gestionnaire").Execute(ORMTestDatabase)
		  
		  // Tests for a simple left join on the Users table. The syntax is likely to change very soon
		  pStatement = DB.Find().From("Users").LeftOuterJoin("Groups").On("Users.id", "=", "Groups.user").Compile()
		  pRecordSet = DB.Find().From("Users").LeftOuterJoin("Groups").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  Assert.AreEqual ("SELECT * FROM `Users` AS `Users` LEFT OUTER JOIN `Groups` AS `Groups` ON `Users`.`id` = `Groups`.`user`", pStatement)
		  
		  // Tests for a simple left join on the Groups table.
		  pStatement = DB.Find.From("Groups").LeftOuterJoin("Users").On("Groups.user", "=", "Users.id").Compile()
		  pRecordSet = DB.Find.From("Groups").LeftOuterJoin("Users").On("Groups.user", "=", "Users.id").Execute(ORMTestDatabase)
		  Assert.AreEqual ("SELECT * FROM `Groups` AS `Groups` LEFT OUTER JOIN `Users` AS `Users` ON `Groups`.`user` = `Users`.`id`", pStatement)
		  
		  // Join with different alias
		  pStatement =  DB.Find.From("Users", "U").LeftOuterJoin("Groups", "G").Where("U.username", "LIKE", "%ete%").Compile()
		  pRecordSet = DB.Find.From("Users", "U").LeftOuterJoin("Groups", "G").Where("U.username", "LIKE", "%ete%").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `U` LEFT OUTER JOIN `Groups` AS `G` WHERE `U`.`username` LIKE '%ete%'", pStatement)
		  
		  // Multi-join
		  pStatement =  DB.Find.From("Users").LeftOuterJoin("Groups").LeftOuterJoin("Groups", "G").On("Groups.id", "=", "G.id").Where("Users.username", "LIKE", "%ete%").Compile()
		  pRecordSet = DB.Find.From("Users").LeftOuterJoin("Groups").LeftOuterJoin("Groups", "G").On("Groups.id", "=", "G.id").Where("Users.username", "LIKE", "%ete%").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` LEFT OUTER JOIN `Groups` AS `Groups` LEFT OUTER JOIN `Groups` AS `G` ON `Groups`.`id` = `G`.`id` WHERE `Users`.`username` LIKE '%ete%'", pStatement)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NestedQueryExpressionTest()
		  Dim pRecordSet As RecordSet
		  Dim pStatement As String
		  
		  pStatement = DB.Find().From("Groups").Where("name", "IN", DB.Find("name").From("Groups")).Compile()
		  pRecordSet = DB.Find().From("Groups").Where("name", "IN", DB.Find("name").From("Groups")).Execute(ORMTestDatabase)
		  
		  Assert.AreEqual(pStatement, "SELECT * FROM `Groups` AS `Groups` WHERE `name` IN (SELECT `name` FROM `Groups` AS `Groups`)")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OnTest()
		  Dim pStatement As String
		  Dim pRecordSet As RecordSet
		  
		  pStatement = DB.Find.From("Users").Join("Groups").On("Users.id", "=", "Groups.user").On("Users.id", "=", "Groups.user").Compile()
		  pRecordSet = DB.Find.From("Users").Join("Groups").On("Users.id", "=", "Groups.user").On("Users.id", "=", "Groups.user").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` JOIN `Groups` AS `Groups` ON `Users`.`id` = `Groups`.`user` AND `Users`.`id` = `Groups`.`user`", pStatement)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTest()
		  Dim valeurs() As Variant
		  valeurs.Append("Paul-willy Jean")
		  valeurs.Append("paulwillyjean")
		  
		  // Creates a new entry in the database
		  DB.Insert("Users", "username", "password").Values(valeurs).Execute(ORMTestDatabase)
		  
		  // Fetches the new entry in the database
		  Dim Record As RecordSet = DB.Find.From("Users").Where("username", "=", valeurs(0)).OrderBy("id").Execute(ORMTestDatabase)
		  Record.MoveLast()
		  
		  // Updates the entry in the database
		  DB.Update("Users").Set(New Dictionary("username": "P-Dob", "password": "paul")).Where("id", "=", Record.Field("id")).Execute(ORMTestDatabase)
		  
		  // Fetches the modified entry int the database
		  Dim UpdateRecord As RecordSet = DB.Find.From("Users").Where("id", "=", Record.Field("id")).Execute(ORMTestDatabase)
		  
		  // Compares the old and the new entry to make sure that the values are indeed different
		  Assert.IsFalse(Record.Field("username").StringValue = UpdateRecord.Field("username").StringValue)
		  
		  // Updates @Record to reflect the modification in the DB
		  Record = DB.Find.From("Users").Where("id", "=", Record.Field("id")).Execute(ORMTestDatabase)
		  
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
		  Dim pRecordSet As RecordSet
		  Dim pStatement As String
		  
		  DB.Delete("Users").Execute(ORMTestDatabase)
		  DB.Delete("Projects").Execute(ORMTestDatabase)
		  
		  // Inserts a new entry with ParamArrays in Values
		  pStatement = DB.Insert("Users", "username", "password").Values("Hete", ".ca").Compile()
		  pRecordSet = DB.Insert("Users", "username", "password").Values("Hete", ".ca").Execute(ORMTestDatabase)
		  Assert.AreEqual("INSERT INTO `Users` ( `username`, `password` ) VALUES ( 'Hete', '.ca' )", pStatement)
		  
		  // Set a value to Nil
		  pStatement = DB.Insert("Projects", "name", "description").Values("Rock & Roll", Nil).Compile()
		  pRecordSet = DB.Insert("Projects", "name", "description").Values("Rock & Roll", Nil).Execute(ORMTestDatabase)
		  Assert.AreEqual("INSERT INTO `Projects` ( `name`, `description` ) VALUES ( 'Rock & Roll', NULL )", pStatement)
		  
		  // Use a QueryExpression
		  pStatement = DB.Insert("Users", "username").Values(DB.Expression("John")).Compile()
		  Assert.AreEqual("INSERT INTO `Users` ( `username` ) VALUES ( John )", pStatement)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WhereTest()
		  Dim pRecordSet As RecordSet
		  Dim pStatement As String
		  
		  // Creates a new entry in the Database
		  pRecordSet = DB.Insert("Users", "username", "password").Values("Paul", "Willy").Execute(ORMTestDatabase)
		  pRecordSet = DB.Insert("Users", "username", "password").Values("Henri", "1234").Execute(ORMTestDatabase)
		  
		  // Creates a second entry with an empty field in the Database
		  pRecordSet = DB.Insert("Users", "username").Values("James").Execute(ORMTestDatabase)
		  
		  // Create a third entry with all fields set
		  pRecordSet = DB.Insert("Users", "username", "password").Values("Arnold", "1234").Execute(ORMTestDatabase)
		  
		  // Looks up a record where the username contains "John" and where
		  // the password is NULL or where the username contains "John" and where the password is "1234"
		  pStatement = DB.Find.From("Users").Where("username", "LIKE", "%John%").AndWhere("password", "IS",Nil).OrWhere("password", "=", "1234").Compile()
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` WHERE `username` LIKE '%John%' AND `password` IS NULL OR `password` = '1234'", pStatement)
		  
		  // Looks up a record where the username is Paul
		  pRecordSet =  DB.Find().From("Users").Where("username", "=", "Paul").OrderBy("id").Execute(ORMTestDatabase)
		  // Logs the new Entry
		  System.DebugLog(DB.Find().From("Users").Where("username", "=", "Paul").OrderBy("id").Compile())
		  System.DebugLog(ShowSelect(pRecordSet))
		  
		  // Tests a where using a LIKE comparison
		  pRecordSet =  DB.Find.From("Users").Where("username", "LIKE", "Pau%").Execute(ORMTestDatabase)
		  System.DebugLog(DB.Find().From("Users").Where("username", "LIKE", "Pau%").Compile())
		  System.DebugLog(ShowSelect(pRecordSet))
		  
		  Assert.IsNotNil(pRecordSet)
		  
		  // Tests for WhereOpen and WhereClose
		  pStatement = DB.Find.From("Users").WhereOpen.Where("username", "=", "Paul").WhereClose.Compile()
		  pRecordSet = DB.Find.From("Users").WhereOpen.Where("username", "=", "Paul").WhereClose.Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` WHERE ( `username` = 'Paul' )", pStatement)
		  
		  // WHERE after a WhereClose
		  pStatement = DB.Find.From("Users").WhereOpen.Where("username", "=", "Paul").WhereClose.Where("username", "=", "Paul").Compile()
		  pRecordSet = DB.Find.From("Users").WhereOpen.Where("username", "=", "Paul").WhereClose.Where("username", "=", "Paul").Execute(ORMTestDatabase)
		  Assert.AreEqual("SELECT * FROM `Users` AS `Users` WHERE ( `username` = 'Paul' ) AND `username` = 'Paul'", pStatement)
		  
		  // Clean the database
		  DB.Delete("Users").Execute(ORMTestDatabase)
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
