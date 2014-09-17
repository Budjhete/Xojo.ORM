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
