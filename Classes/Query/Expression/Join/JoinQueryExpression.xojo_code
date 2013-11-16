#tag Class
Protected Class JoinQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
		  Return "JOIN " + QueryCompiler.TableName(mTableName, mTableAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String, pTableAlias As String)
		  mTableName = pTableName
		  mTableAlias = pTableAlias
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 3
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mTableAlias As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableName As String
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
