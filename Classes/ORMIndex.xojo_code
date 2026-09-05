#tag Class
Protected Class ORMIndex
	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As String, pUnique As Boolean = False)
		  For Each columnName As String In pColumns
		    If columnName.Trim = "" Then
		      Raise New ORMException("An index column cannot be empty.")
		    End If
		    mColumns.Add(columnName.Trim)
		  Next

		  If mColumns.Count = 0 Then
		    Raise New ORMException("An index must contain at least one column.")
		  End If

		  Unique = pUnique
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Columns() As String()
		  Var result() As String
		  For Each columnName As String In mColumns
		    result.Add(columnName)
		  Next
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Unique As Boolean
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
		#tag ViewProperty
			Name="Unique"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
