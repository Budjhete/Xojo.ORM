ORM
===
ORM is a object-relation-mapper for Xojo applications.

What's so great about it?
-------------------------
* It is database-independant: you may fetch a model from a database and save it 
in another if that pleases you! Also, basic SQL is used, so it is compatible 
with pretty much any database supported by Xojo with tests on their way ;
* It is elegant: it implements closures for doing builder-like syntax, function 
parameters and name are consistent and exploit `ParamArray` and `Pair` ;
* It is fast and memory efficient: do not fear an overheap, `ORM` is nearly 
stateless and does not load unecessary information ;
* it is based on native class such as `RecordSet` and `Database` ;
* it is unit-tested and shall not break! 
* it is event-driven ;
* `ORM` and `QueryBuilder` inherit from `Control` and are fully qualified as 
such ;
* it is extensively documented 
[right here on GitHub](https://github.com/Budjhete/XojoORM/wiki).

NB : you need [XOJOUnit](https://github.com/Budjhete/xojo-unit) project to make it run as is.

Named indexes and foreign keys
------------------------------

`SchemaIndex` and `ORMField.Unique` remain supported for existing models. New
models can describe several distinct named indexes and exact foreign keys with
the opt-in `SchemaIndexes` and `SchemaForeignKeys` dictionaries:

```xojo
SchemaIndexes.Value("uq_role_organisation_code") = New ORMIndex(Array("organisationNo", "code"), True)
SchemaIndexes.Value("idx_role_active") = New ORMIndex(Array("organisationNo", "actif"))

SchemaForeignKeys.Value("fk_role_organisation") = New ORMForeignKey( _
  Array("organisationNo"), _
  "Organisation", _
  Array("noOrganisation"), _
  ORMForeignKey.ActionCascade, _
  ORMForeignKey.ActionRestrict)
```

On MySQL/MariaDB, `CreateTable` emits those definitions and `TableUpdate`
adds a missing named definition. If a definition already exists under the
requested name but its columns, uniqueness, referenced table, referenced
columns or actions differ, the update stops and reports the mismatch. It never
drops or silently rewrites that existing constraint.
