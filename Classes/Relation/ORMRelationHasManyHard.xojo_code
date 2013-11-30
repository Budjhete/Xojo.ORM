#tag Class
Protected Class ORMRelationHasManyHard
Inherits ORMRelationHasMany
	#tag Method, Flags = &h0
		Sub Remove(pORM As ORM, pDatabase As Database)
		  // Remove the entry instead of nullifying the primary key
		  DB.Delete(mORM.TableName). _
		  Where(mORM.Pks). _
		  AndWhere(mForeignColumn, "=", pORM.Pk). _
		  Execute(pDatabase)
		End Sub
	#tag EndMethod


End Class
#tag EndClass
