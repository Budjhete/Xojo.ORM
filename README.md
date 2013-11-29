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

* It is unit-tested
It will not break in your hand! 

* It is event-driven
It can be efficiently implemented as a control.

* It has a documentation
Yep, look below.

## Quick tour of ORM internals
ORM is coded surprisingly simply. It has 4 internal state: mData, mChange, mAdd and mRemove.
* mData contains fetched data matching the content of the database.
* mChanged contains the changes done by the user
* mAdd contains the added related models
* mRemove contains the removed related models

All other information are deduced from these information.

## Usage
Using ORM is very simple. They are designed to make programming efficient. For the following examples, two models will be defined: ModelClient and ModelGroup, both inheriting from ORM. Reading this section in order should prepare you for creating and using your own models.

User and Group models are available in the module for testing purposes and examples.

### Defining models
The basic definition of a model implies the definition of ORM.TableName and ORM.PrimaryKey functions in your model. ORM.TableName will tell the ORM where your model is stored in the database and ORM.PrimaryKey will indicate which row it is related to.

By default, the ORM pluralizes the class name without the "Model" prefix, but if you need a custom table name, you must override ORM.TableName

In ModelUser.TableName
    Return "Users"

In ModelGroup.TableName
    Return "Groups"

By default, the ORM defines PrimaryKey as "id", but if your model has a custom primary key name, you must override ORM.PrimaryKey

In ModelUser.PrimaryKey
    Return "id"

In ModelGroup.PrimaryKey
    Return "id"

#### Handling multiple primary keys (or none)
It often happens that models have multiple column as a primary key or simply does not have any. To implement those behaviours, just overload PrimaryKey and return an array of primary keys.

In ModelUser.PrimaryKey
    Return Array("username", "email")

If your model has no primary key, just return an empty array

In ModelUser.PrimaryKey
    Return Array()

All right! At this point, your models are ready-to-use! But not so fast, as we can make things better.

#### Defining relationships
Relationships are very important for models, otherwise they will feel lonely. This ORM supports 3 kind of relationships:
* BelongsTo
* HasMany and HasOne
* HasManyThrough

HasOne is only a special case of HasMany where you call Find instead of FindAll.

##### BelongsTo
BelongsTo are implemented through computed property like the following:

In ModelUser.group
Get
    Return New ModelGroup(Me.Data("group"))
Set
    Me.Data("group") = value.Pk

##### HasMany And HasOne
HasMany are implemented in a method using the HasMany helper.

In ModelGroup.users
    Return ModelUser(Me.HasMany(New ModelUser, "group")) // The second parameter is the column in Users that relates to the group it belongs

HasOne is implemented using the ORM.HasOne helper instead, but it is only an alias for HasMany. Just make sure you call ORM.Find instead of ORM.FindAll.

##### HasManyThrough
HasManyThrough are a little more complex as you have to specify the pivot table

In ModelUser.projects
    Return ModelProject("UsersProjects", "user", "project", New ModelProject)

You have now defined all the relationships you need to avoid complicated joins!

To deal with relationships, you can use ORM.Add, ORM.Remove and ORM.Has. These three methods are not very practical as you have to specify everything every time, but you can make it much simpler by overriding it with a custom signature like:

In ModelGroup.Add(ParamArray pUsers As ModelUser)
    Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))

In ModelGroup.Remove(ParamArray pUsers As ModelUser)
    Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))

In ModelGroup.Has(ParamArray pUsers As ModelUser)
    Return ModelGroup(Super.Add("UsersGroups", "group", "user", pUsers))

Now, you have friendly methods to deal with relationships :)

### Basic model utilization
This section convers basic model utilization. 

#### Creating new entries
To create a new entry in your database for a given model, the ORM.Create function is given.

    pClient = New ModelClient()

    pClient.name = "John" // Through a computed property
    pClient.Data("name") = "John" // Directly using Data

    pClient.Create(pDatabase)

#### Fetching models

##### Fetching a single model
    pClient = New ModelClient(pPk) // Given its primary key (which applies a WHERE PrimaryKey = pPk)
    pClient.Find(pDatabase)

    pClient = New ModelClient
    pClient.Where("name", "=", "John") // Using conditional expression
    pClient.Find(pDatabase)

Whenever you want to know if what you have fetched exists, just call ORM.Loaded

    If pClient.Loaded Then
        // Do some work
    Else
        // Do other work (like creating a new model!)

This method will check if the defined primary key (ORM.PrimaryKey) is not Nil. Explicitly setting the parimary key value to Nil will not unload the model, as it check the initial value.

If your model may not exist, but should be updated if it does and created otherwise, it is strongly suggested to use the ORM.Save method which can avoid writing too much code. This method will be covered below.

##### Fetching multiple models
    pClient = New ModelClient
    pClient.
    pRecordSet = pClient.FindAll(pDatabase)

#### Changing your models

#### Updating your changes

#### Deleting existing entries

## Advanced usages
This section convers most of advanced usages you can do with the ORM.

### Properly clearing data
ORM offers 3 way to clear internal data and one to reset them:
* Clear clear changes, not data
* Unload clear data, not changes
* Reset clear the QueryBuilder (inherited)
* Reload which call Unload the call Find

Use these methods with caution. Events will be thrown to give you scopes to cancel these operations. Event-driven model is covered below.

### Event-driven programming
ORM is completely event-driven in the sense that it provides events definition to do and not do pretty much all actions possible. This is extremely useful for calcelling Delete for instance. It raises events before the action and after.

A complete example of event-drived interface with ORM is shown in the Views folder.

The most important thing is to respect the event cycle. In this case, we have a simple interface with a button bFind and a text field tName. When you press on bFind, the model is loaded and tName contains mUser.name.

Let's say a user wishes to see the model 1 and presses a button to do so
bFind.Action
    mUser.Where("id", "=", 1).Find(pDatabase)

Calling Find on the model will trigger Finding, you may check if the user will not wipe the model if its changed
User.Finding
    If mUser.Changed Then
         // Confirm with the user and return True to cancel the find
    End If

Found is called, it's time to present the model
User.Found
    tName.Text = Me.name

### Make complex request with the QueryBuilder

