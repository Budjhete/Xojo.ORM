#tag Class
Protected Class FromQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  Dim pStatement As Text
		  
		  If pLastQueryExpression IsA FromQueryExpression Then
		    pStatement = ", "
		  Else
		    pStatement = "FROM "
		  End If
		  
		  If Xojo.Introspection.GetType(mTable) = GetTypeInfo(Text) Then // Text
		    Return pStatement + QueryCompiler.TableName(mTable, mTableAlias)
		  ElseIf mTable IsA QueryBuilder Then
		    Return pStatement + QueryCompiler.Column(mTable) + " AS " + QueryCompiler.Alias(mTableAlias)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTable As Auto, pTableAlias As Text)
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
			mTable can be either a Text containing a table name, either a QueryExpression containing the definition of a temporary table
		#tag EndNote
		Private mTable As Auto
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableAlias As Text
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
