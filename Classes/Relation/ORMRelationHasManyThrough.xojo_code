#tag Class
Protected Class ORMRelationHasManyThrough
Implements ORMRelation
	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Add(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Insert(mPivotTableName, mForeignColumn, mFarColumn)._
		  Values(pORM.Pk, mORM.Pk)._
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Add(pORM As ORM, pDatabase As iOSSQLiteDatabase, pCommit As Boolean)
		  DB.Insert(mPivotTableName, mForeignColumn, mFarColumn)._
		  Values(pORM.Pk, mORM.Pk)._
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pPivotTableName As Text, pForeignColumn As Text, pFarColumn As Text, pORM As ORM)
		  mPivotTableName = pPivotTableName
		  
		  mForeignColumn = pForeignColumn
		  mFarColumn = pFarColumn
		  
		  mORM = pORM
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As Text
		  Return mPivotTableName + ":" + mORM.Pk.AutoTextValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  DB.Delete(mPivotTableName)._
		  Where(mForeignColumn, "=", pORM.Pk)._
		  AndWhere(mFarColumn, "=", mORM.Pk)._
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As iOSSQLiteDatabase, pCommit As Boolean)
		  DB.Delete(mPivotTableName)._
		  Where(mForeignColumn, "=", pORM.Pk)._
		  AndWhere(mFarColumn, "=", mORM.Pk)._
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mFarColumn As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mForeignColumn As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mORM As ORM
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPivotTableName As Text
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
