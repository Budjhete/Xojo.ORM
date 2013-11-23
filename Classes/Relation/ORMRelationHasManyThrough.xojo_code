#tag Class
Protected Class ORMRelationHasManyThrough
Implements ORMRelation
	#tag Method, Flags = &h0
		Sub Add(pForeignKey As Variant, pDatabase As Database)
		  DB.Insert(mPivotTableName, mForeignColumn, mFarColumn)._
		  Values(pForeignKey, mFarKey)._
		  Execute(pDatabase)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pPivotTableName As String, pForeignColumn As String, pFarColumn As String, pFarKey As Variant)
		  mPivotTableName = pPivotTableName
		  
		  mForeignColumn = pForeignColumn
		  
		  mFarColumn = pFarColumn
		  mFarKey = pFarKey
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump() As String
		  Return mPivotTableName + ":" + Str(mFarKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pForeignKey As Variant, pDatabase As Database)
		  DB.Delete(mPivotTableName)._
		  Where(mForeignColumn, "=", pForeignKey)._
		  AndWhere(mFarColumn, "=", mFarKey)._
		  Execute(pDatabase)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mFarColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFarKey As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mForeignColumn As String
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
