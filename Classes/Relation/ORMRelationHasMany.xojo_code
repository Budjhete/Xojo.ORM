#tag Class
Protected Class ORMRelationHasMany
Implements ORMRelation
	#tag Method, Flags = &h0
		Sub Add(pORM As ORM, pDatabase As Database)
		  DB.Update(mORM.TableName). _
		  Set(mForeignColumn : pORM.Pk) ._
		  Where(mORM.Pks). _
		  Execute(pDatabase)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pForeignColumn As String, pORM As ORM)
		  mForeignColumn = pForeignColumn
		  
		  mORM = pORM
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As String
		  Return mORM.TableName + ":" + Str(mORM.Pk)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pORM As ORM, pDatabase As Database)
		  DB.Update(mORM.TableName). _
		  Set(mForeignColumn : Nil) ._
		  Where(mORM.Pks). _
		  AndWhere(mForeignColumn, "=", pORM.Pk). _
		  Execute(pDatabase)
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mForeignColumn As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mORM As ORM
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
