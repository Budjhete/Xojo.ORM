#tag Class
Protected Class ORMRelationHasMany
Implements ORMRelation
	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Add(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Update(mORM.TableName). _
		  Set(mForeignColumn : pORM.Pk) ._
		  Where(mORM.Pks). _
		  Execute(pDatabase, pCommit)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Add(pORM As ORM, pDatabase As iOSSQLiteDatabase, pCommit As Boolean)
		  Dim D as new Dictionary
		  d.Value(mForeignColumn) = pORM.Pk
		  DB.Update(mORM.TableName). _
		  Set(d) ._
		  Where(mORM.Pks). _
		  Execute(pDatabase, pCommit)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pForeignColumn As Text, pORM As ORM)
		  mForeignColumn = pForeignColumn
		  
		  mORM = pORM
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As Text
		  Return mORM.TableName + ":" + mORM.Pk.AutoTextValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Update(mORM.TableName). _
		  Set(mForeignColumn : Nil) ._
		  Where(mORM.Pks). _
		  AndWhere(mForeignColumn, "=", pORM.Pk). _
		  Execute(pDatabase, pCommit)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As iOSSQLiteDatabase, pCommit As Boolean)
		  Dim d as Dictionary
		  d.Value(mForeignColumn) = Nil
		  DB.Update(mORM.TableName).Set(d).Where(mORM.Pks).AndWhere(mForeignColumn, "=", pORM.Pk).Execute(pDatabase, pCommit)
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mForeignColumn As Text
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
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
