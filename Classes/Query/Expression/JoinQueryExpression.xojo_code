#tag Class
Protected Class JoinQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  Return mDirection + " JOIN " + QueryCompiler.TableName(mTableName) + " AS " + QueryCompiler.TableName(mAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pDirection As String, pTableName As String)
		  Constructor(pDirection, pTableName, pTableName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pDirection As String, pTableName As String, pAlias As String)
		  mDirection = pDirection
		  mTableName = pTableName
		  mAlias = pAlias
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 2
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAlias As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDirection As String
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
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
