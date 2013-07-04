#tag Class
Protected Class SelectQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  return "SELECT " + QueryCompiler.Columns(mColumns) + " FROM " + QueryCompiler.TableName(mTableName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String, pColumn As String = "*")
		  Constructor(pTableName, Array(pColumn))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String, pColumns() As String)
		  mTableName = pTableName
		  mColumns = pColumns
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  return 0
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As String
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
