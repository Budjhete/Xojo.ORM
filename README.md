# ORM
ORM is a object-relation-mapper for Xojo applications. It is fast, consise, lightweight and secure!

## What's so great about it?
* It is database-independant
You may fetch a model from a database and save it in another if that pleases you! Also, basic SQL is used, so it is compatible with pretty much any database supported by Xojo.

* It is secure
All values are processed and quoted against SQL injections.

* It is elegant
It implements closures for doing builder-like syntax, function parameters and name are consistent and exploit ParamArray and Pair

* It is fast and memory efficient
Do not fear an overheap, ORM is nearly stateless and does not load unecessary information.

* It is based on native class such as RecordSet, Database

* Is is independent from the database
Many ORM handles Database object internally, but that's restrictive when you want to work on multiple database.

* It is unit-tested
It will not break in your hand! 

* It is event-driven
It can be efficiently implemented as a control.

* ORM and QueryBuilder inherit from Control
There are fully qualified to be used as such.

* It has a documentation
Yep, look below.

## Quick tour of ORM internals
ORM is coded surprisingly simply. It has 4 internal state: mData, mChanged, mAdd and mRemove.
* mData contains fetched data matching the content of the database.
* mChanged contains the changes done by the user
* mAdd contains the added related models
* mRemove contains the removed related models

All other information are deduced from these information.

Using ORM is very simple. They are designed to make programming efficient. For the following examples, two models will be defined: ModelUser and ModelGroup, both inheriting from ORM. Reading this section in order should prepare you for creating and using your own models.

User and Group models are available in the module for testing purposes and examples.

More specific documentation is providen here <url>.

## Defining models
Let's say we have the following table definition

Our users

```sql
    CREATE TABLE `Users` (
        `id` INTEGER PRIMARY KEY,
        `group` INTEGER REFERENCES Groups(id),
        `username` TEXT NOT NULL,
        `password` TEXT, --- unset password is NULL
        UNIQUE ( `username` )
    );
```

Our groups of users

```sql
    CREATE TABLE `Groups` (
        `id` INTEGER PRIMARY KEY,
        `user` INTEGER REFERENCES Users(id), --- an administrator
        `name` TEXT NOT NULL,
        UNIQUE ( `name` )
    );
```

Some projects for our users

```sql
    CREATE TABLE `Projects` (
        `id` INTEGER PRIMARY KEY,
        `name` TEXT NOT NULL,
    );
```
And project memberships

```sql
    CREATE TABLE `UsersProjects` (
        `project` INTEGER REFERENCES Projects(id),
        `user` INTEGER REFERENCES Users(id),
        `role` TEXT, -- role occupied by the member
        PRIMARY KEY ( `project`, `user` )
    );
```

We need models to map those data conveniently. Let's create classes that subclass ORM.

```rb
    ModelUser As ORM

    ModelGroup As ORM

    ModelProject As ORM

    ModelUserProject As ORM
```

Prepending "Model" is a recommended convention, but you can call the models the way you wish.

The basic definition of a model implies the definition of ORM.TableName and ORM.PrimaryKey functions in your model. ORM.TableName will tell the ORM where your model is stored in the database and ORM.PrimaryKey will indicate which row it is related to.

By default, the ORM pluralizes the class name without the "Model" prefix, but if you need a custom table name, you must override ORM.TableName

```vb
    ModelUser.TableName As String
        Return "Users"
```

By default, the ORM defines PrimaryKey as "id", but if your model has a custom primary key name, you must override ORM.PrimaryKey

In ModelUser.PrimaryKey
    Return "id"

Also, for convenience, you can define computed properties for your table columns like so

In ModelUser.user
    Get As String
        Return Me.Data("user")
    Set(value As String)
        Me.Data("user") = value

It is very useful to define computed properties with built-in types like String, Date or Integer. Be cautious with NULL values, as native types cannot take that value nor return it.

When using ORM as a Control, computed properties might are set without any consent. Yet, we are looking forward solution to this problem.

### Handling multiple primary keys
It often happens that models have multiple column as a primary key or simply does not have any. To implement those behaviours, just overload PrimaryKeys and return an array of primary keys.

    In ModelUser.PrimaryKeys As String()
        Return Array("username", "email")

At any moment, you can fetch your primary key values with ORM.Pks, which returns a dictionary of column to value.

    Dim pPks As Dictionary = pUser.Pks

All right! At this point, your models are ready-to-use! But not so fast, as we can make things better.

### Defining relationships
Relationships are very important for models, otherwise they will feel lonely. This ORM supports 3 kind of relationships:
* BelongsTo
* HasMany and HasOne
* HasManyThrough

HasOne is only a special case of HasMany where you call Find instead of FindAll.

#### BelongsTo
BelongsTo are implemented through computed property like the following:

```
ModelUser.group
    Get As ORM
        Return Me.BelongsTo("group", New ModelGroupe)
    Set(value As ORM)
        Me.BelongsTo("group", value)
```

#### HasMany And HasOne
HasMany are implemented in a method using the HasMany helper.

    ModelGroup.users As ModelUser
        Return ModelUser(Me.HasMany(New ModelUser, "group")) // The second parameter is the column in Users that relates to the group it belongs

HasOne is implemented using the ORM.HasOne helper instead, but it is only an alias for HasMany. Just make sure you call ORM.Find instead of ORM.FindAll.

#### HasManyThrough
HasManyThrough are a little more complex as you have to specify the pivot table

```
    ModelUser.projects As ModelProject
        Return ModelProject("UsersProjects", "user", "project", New ModelProject)
```

You have now defined all the relationships you need to avoid complicated joins!

To deal with relationships, you can use ORM.Add, ORM.Remove and ORM.Has. These three methods are not very practical as you have to specify everything every time, but you can make it much simpler by overriding it with a custom signature like:

```
    ModelGroup.Add(ParamArray pUsers As ModelUser)
        Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))

    ModelGroup.Remove(ParamArray pUsers As ModelUser)
        Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))

    ModelGroup.Has(ParamArray pUsers As ModelUser)
        Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))
```

Now, you have friendly methods to deal with relationships :)

## Basic model utilization
This section convers basic model utilization.

### Creating new entries
To create a new entry in your database for a given model, the ORM.Create function is given.

```
    pUser = New ModelUser()

    pUser.name = "John" // Through a computed property
    pUser.Data("name") = "John" // Directly using Data

    Call pUser.Create(pDatabase)
```

### Fetching a single model

```
    pUser = New ModelUser
    pUser.Where("name", "=", "John") // Using conditional expression
    Call pUser.Find(pDatabase)

    pUser = New ModelUser(New Dictionary("id": 5)) // from a dictionary of criterias

    Dim pAdministrator As ModelUser = New ModelUser(pUser) // New ModelUser(pUser.Pks)

    pUser = New ModelUser(pRecordSet) // from a RecordSet
```

Whenever you want to know if what you have fetched exists, just call ORM.Loaded

```
    If pUser.Loaded Then
        // Do some work
    Else
        // Do other work (like creating a new model!)
    End If
```

This method will check if any defined primary key (ORM.PrimaryKeys) has a Nil value and otherwise returns True.

### Fetching multiple models

```
    pUser = New ModelUser
    pUser.Where("group", "=", 1)
    pRecordSet = pUser.FindAll(pDatabase) // returns all users from group 1
```

Then you can fetch the data by looping through the RecordSet

```
    While Not pRecordSet.EOF
        Dim pUser As New ModelUser(pRecordSet)
        // Do stuff with your user...
    WEnd
```

## Changing your models
Changing models is done through ORM.Data

```
    pUser.Data("name") = "John"

    Call pUser.Data("name", "John") // can be used like a closure
```

Using a dictionary of values

```
    pDictionary As New Dictionary("name": "John")
    pUser.Data(pDictionary) // Using any dictionary
```

Using a ParamArray of Pair

```
    pUser.Data("name" : "John") // Using a ParamArray of Pair
```

Or using predefined computed property

```
    pUser.name = "John" // Using a precomputed property
```

### Adding and removing relationship
With HasMany and HasOne

```
    pUser.Add("group", pGroup)

    pUser.Remove("group", pGroup)
```

With HasManyThrough

```
    pUser.Add("UsersGroups", "user", "group", pGroup)

    pUser.Remove("UsersGroups", "user", "group", pGroup)
```

It is explicit, but you can avoid specifying all these parameters by writing a signature for Add and Remove specifically for the ModelGroup.

In ModelUser.Add(ParamArray pGroups As ModelGroup)
    Return Add("UsersGroups", "user", "group", pGroups)

Now you may write

```
    pUser.Add(pGroup)
```

## Updating your changes
Sending your changes back in the database is done through ORM.Update.

```
    Call pUser.Update(pDatabase)
```

ORM.Update throws an ORMException if it happens not to be loaded.

If your model might be unloaded, you will prefer the ORM.Save method which call ORM.Create if ORM.Loaded is False

```
    Call pUser.Save(pDatabase)
```

## Deleting existing entries
Removing an entry from the database is straight forward!

```
    Call pUser.Delete(pDatabase)
```

ORM.Delete throws an ORMException if it happens not to be loaded.

## Advanced usages
This section convers most of advanced usages you can do with the ORM.

### Properly clearing data
ORM offers 3 way to clear internal data and one to reset them:
* ORM.Clear clears changes, not data
* ORM.Unload clears the primary keys
* ORM.UnloadAll clears data, not changes
* ORM.Reset clears the QueryBuilder (inherited)
* ORM.Reload which call Unload then call Find

ORM.Clear is used mainly for clearing

ORM.Unload is useful for making in-place copies of your models.

Use these methods with caution. Events will be thrown to give you scopes to cancel these operations. Event-driven model is covered below.

### Event-driven programming
ORM is completely event-driven in the sense that it provides events definition to do and not do pretty much all actions possible. This is extremely useful for user confirmations.

Events are raised before (ex. Saving) and after (ex. Saved). Returning True in the first event will not trigger the action. Once the action is triggered, you get the second event called.

A complete example of event-drived interface with ORM is shown in the Views folder.

The most important thing is to respect the event cycle. In this case, we have a simple interface with a button bFind and a text field tName. When you press on bFind, the model is loaded and tName contains mUser.name.

Let's say a user wishes to see the model 1 and presses a button to do so
bFind.Action
    mUser.Where("id", "=", 1).Find(pDatabase)

Calling Find on the model will trigger Finding, you may check if the user will not wipe the model if its changed

    ```
    User.Finding As Boolean
        If mUser.Changed Then
             Dim pMessageDialog As New MessageDialog
             pMessageDialog.Title = "Clear your changes?"
             pMessageDialog.Description = "Do you want to clear your changes?"
             pMessageDialog.ActionButton.Caption = "Clear"
             pMessageDialog.AlternateAction.Caption = "Don't clear"
             pMessageDialog.AlternateAction.Visible = True
             // Logic is negative for events: return True not to trigger the action.
             Return pMessageDialog.ShowModal = pMessageDialog.AlternateAction
        End If
    ```

Found is called, it's time to present the model
User.Found
    tName.Text = Me.name

## Make complex request with the QueryBuilder
This section describes some advanced usage with the QueryBuilder. As you have probably already noticed, the ORM inherit from the QueryBuilder, so all that will be explained here is reusable in the fetching process.

The main advantages of using a QueryBuilder for any requests are
* Safety against SQL injections
* Proper quoting for columns and values
* SQL is validated at compile-time (if you do not abuse of QueryExpression)
* Resuable and extendable queries

Find, Create, Update and Delete all have an equivalent in SQL: SELECT, INSERT, UPDATE, DELETE. You never have to specify any of these when you are using the ORM. But if you are using the QueryBuilder directly, there are helpers for that!

```
    DB.Find.From("Users") // SELECT * FROM `Users`
    DB.Insert("Users") // INSERT INTO `Users`
    DB.Update("Users") // UPDATE `Users`
    DB.Delete("Users") // DELETE `Users`
```

There are also other useful helpers in DB

```
    DB.Count() // To count a specified column like COUNT ( `id` )
    DB.Set() // To define a set of values like ( 'a', 'b', 'c' )
```

Then, you start building pretty much what is required
```
    DB.Find.From("Users").Where("name", "LIKE", "John")
```
An interesting feature is that most duplicate expressions will compile into a single one

```
    DB.Find.From("Users").OrderBy("name").OrderBy("id") 
```

This will simply make a sort by name and id columns.

If you need any complex custom expression, use DB.Expression. This piece of request will appear raw in the SQL result.
```
    DB.Expression("TOTAL ( `Users`.`id` )")
```

### Executing your request
Once you're done, call QueryBuilder.Execute on a database.

```
    Dim pRecordSet As RecordSet = DB.Find.From("Users").Where("name", "LIKE", "John").Execute(pDatabase)
```

If no result is found, Nil will be returned instead of an empty RecordSet. If it might be Nil, you must check it.

```
    If pRecordSet <> Nil Then
        // Process data
    Else
        // No record founds :(
    End If
```

If you do not capture the RecordSet, it won't be generated.

```
    DB.Create("Users").Values("name": "John").Execute(pDatabase)
```

### Debugging your request
To debug your request, you can log the compiled value instead of executing it.

```
    System.DebugLog DB.Find.From("Users").Compile
```

This is useful to identify your mistakes, or a bug in ORM.

## Contributing
If you have ideas or patches to improve the ORM, please don't hesitate to get in touch with us. Send us a pull request or create a new issue right here on GitHub.
