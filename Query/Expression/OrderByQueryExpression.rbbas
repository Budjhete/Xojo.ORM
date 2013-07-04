#tag Class
Protected Class OrderByQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  return "ORDER BY " + QueryCompiler.Columns(mColumns) + " " + mDirection
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As String, pDirection As String = "ASC")
		  mColumns = pColumns
		  mDirection = pDirection
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As String, pDirection As String = "ASC")
		  Constructor(Array(pColumn), pDirection)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 6
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDirection As String
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
