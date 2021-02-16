#tag Class
Protected Class ORMRelationHasManyHard
Inherits ORMRelationHasMany
	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As Database, pCommit As Boolean)
		  #Pragma Unused pORM
		  
		  // Remove the entry instead of nullifying the primary key
		  DB.Delete(mORM.TableName). _
		  Where(mORM.Pks). _
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pORM as ORM, pSocket as KanjoSocket)
		  // Calling the overridden superclass method.
		  Super.Remove(pORM, pSocket)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetIOS and (Target32Bit or Target64Bit))
		Sub Remove(pORM As ORM, pDatabase As SQLiteDatabase, pCommit As Boolean)
		  // Calling the overridden superclass method.
		  // Note that this may need modifications if there are multiple  choices.
		  // Possible calls:
		  // Remove(pORM As ORM, pDatabase As Database, pCommit As Boolean) -- From ORMRelationHasMany
		  // Remove(pORM As ORM, pDatabase As SQLiteDatabase, pCommit As Boolean) -- From ORMRelationHasMany
		  Super.Remove(pORM, pDatabase, pCommit)
		  #Pragma Unused pORM
		  
		  // Remove the entry instead of nullifying the primary key
		  DB.Delete(mORM.TableName). _
		  Where(mORM.Pks). _
		  Execute(pDatabase, pCommit)
		End Sub
	#tag EndMethod


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
