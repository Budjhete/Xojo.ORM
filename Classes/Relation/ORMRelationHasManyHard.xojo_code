#tag Class
Protected Class ORMRelationHasManyHard
Inherits ORMRelationHasMany
	#tag Method, Flags = &h0
		Sub Remove(pForeignKey As Variant, pDatabase As Database)
		  // Remove the entry instead of nullifying the primary key
		  DB.Delete(mTableName). _
		  Where(mPrimaryColumn, "=", mPrimaryKey). _
		  AndWhere(mForeignColumn, "=", pForeignKey). _
		  Execute(pDatabase)
		End Sub
	#tag EndMethod


End Class
#tag EndClass
