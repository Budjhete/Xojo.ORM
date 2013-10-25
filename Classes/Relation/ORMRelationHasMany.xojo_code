#tag Class
Protected Class ORMRelationHasMany
Implements ORMRelation
	#tag Method, Flags = &h0
		Sub Add(pForeignKey As Variant, pDatabase As Database)
		  Raise New ORMException("Model cannot be added in HasMany relation.")
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String, pForeignColumn As String, pPrimaryColumn As String, pPrimaryKey As Variant)
		  mTableName = pTableName
		  
		  mForeignColumn = pForeignColumn
		  
		  mPrimaryColumn = pPrimaryColumn
		  mPrimaryKey = pPrimaryKey
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pForeignKey As Variant, pDatabase As Database)
		  DB.Delete(mTableName)._
		  Where(mPrimaryColumn, "=", mPrimaryKey). _
		  AndWhere(mForeignColumn, "=", pForeignKey). _
		  Execute(pDatabase)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mForeignColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrimaryColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrimaryKey As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		mTableName As String
	#tag EndProperty


End Class
#tag EndClass
