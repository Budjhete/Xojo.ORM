#tag Class
Protected Class ORMRelationHasMany
Implements ORMRelation
	#tag Method, Flags = &h0
		Sub Add(pForeignKey As Variant, pDatabase As Database)
		  DB.Update(mTableName). _
		  Set(mForeignColumn : pForeignKey) ._
		  Where(mPrimaryColumn, "=", mPrimaryKey). _
		  Execute(pDatabase)
		  
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
		Function Dump() As String
		  Return mTableName + ":" + Str(mPrimaryKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(pForeignKey As Variant, pDatabase As Database)
		  DB.Update(mTableName). _
		  Set(mForeignColumn : Nil) ._
		  Where(mPrimaryColumn, "=", mPrimaryKey). _
		  AndWhere(mForeignColumn, "=", pForeignKey). _
		  Execute(pDatabase)
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mForeignColumn As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mPrimaryColumn As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mPrimaryKey As Variant
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mTableName As String
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
