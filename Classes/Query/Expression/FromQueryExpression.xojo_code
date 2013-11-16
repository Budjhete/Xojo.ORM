#tag Class
Protected Class FromQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  Dim pStatement As String
		  
		  If pLastQueryExpression IsA FromQueryExpression Then
		    pStatement = ", "
		  Else
		    pStatement = "FROM "
		  End If
		  
		  If mTable.Type = 8 Then // String
		    Return pStatement + QueryCompiler.TableName(mTable, mTableAlias)
		  ElseIf mTable IsA QueryBuilder Then
		    Return pStatement + QueryCompiler.Column(mTable) + " " + mTableAlias
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTable As Variant, pTableAlias As String)
		  mTable = pTable
		  mTableAlias = pTableAlias
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 2
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		#tag Note
			mTable can be either a String containing a table name, either a QueryExpression containing the definition of a temporary table
		#tag EndNote
		Private mTable As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableAlias As String
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
