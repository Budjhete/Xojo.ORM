#tag Class
Protected Class ORMRelationHasManyThrough
Implements ORMRelation
	#tag Method, Flags = &h0
		Sub Add(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Insert(mPivotTableName, mForeignColumn, mFarColumn)._
		  Values(pORM.Pk, mORM.Pk)._
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pORM As ORM)
		  mPivotTableName = pPivotTableName
		  
		  mForeignColumn = pForeignColumn
		  mFarColumn = pFarColumn
		  
		  mORM = pORM
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As String
		  Return mPivotTableName + ":" + Str(mORM.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Delete(mPivotTableName)._
		  Where(mForeignColumn, "=", pORM.Pk)._
		  AndWhere(mFarColumn, "=", mORM.Pk)._
		  Execute(pDatabase)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mFarColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mForeignColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mORM As ORM
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPivotTableName As String
	#tag EndProperty


	#tag ViewBehavior
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
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
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
