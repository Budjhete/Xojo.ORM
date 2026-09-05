#tag Class
Protected Class ORMForeignKey
	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As String, pReferencedTable As String, pReferencedColumns() As String, pOnUpdate As String = ActionNoAction, pOnDelete As String = ActionNoAction)
		  For Each columnName As String In pColumns
		    If columnName.Trim = "" Then
		      Raise New ORMException("A foreign key column cannot be empty.")
		    End If
		    mColumns.Add(columnName.Trim)
		  Next

		  For Each columnName As String In pReferencedColumns
		    If columnName.Trim = "" Then
		      Raise New ORMException("A referenced foreign key column cannot be empty.")
		    End If
		    mReferencedColumns.Add(columnName.Trim)
		  Next

		  If mColumns.Count = 0 Or mColumns.Count <> mReferencedColumns.Count Then
		    Raise New ORMException("A foreign key must contain the same non-zero number of local and referenced columns.")
		  End If
		  If pReferencedTable.Trim = "" Then
		    Raise New ORMException("A foreign key referenced table cannot be empty.")
		  End If

		  ReferencedTable = pReferencedTable.Trim
		  OnUpdate = NormalizeAction(pOnUpdate)
		  OnDelete = NormalizeAction(pOnDelete)
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

	#tag Method, Flags = &h21
		Private Function NormalizeAction(value As String) As String
		  Var action As String = value.Trim.Uppercase
		  Select Case action
		  Case ActionCascade, ActionNoAction, ActionRestrict, ActionSetNull
		    Return action
		  Else
		    Raise New ORMException("Unsupported foreign key action: " + value)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReferencedColumns() As String()
		  Var result() As String
		  For Each columnName As String In mReferencedColumns
		    result.Add(columnName)
		  Next
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReferencedColumns() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		OnDelete As String
	#tag EndProperty

	#tag Property, Flags = &h0
		OnUpdate As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ReferencedTable As String
	#tag EndProperty


	#tag Constant, Name = ActionCascade, Type = String, Dynamic = False, Default = \"CASCADE", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ActionNoAction, Type = String, Dynamic = False, Default = \"NO ACTION", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ActionRestrict, Type = String, Dynamic = False, Default = \"RESTRICT", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ActionSetNull, Type = String, Dynamic = False, Default = \"SET NULL", Scope = Public
	#tag EndConstant


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
			Name="OnDelete"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="OnUpdate"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReferencedTable"
			Visible=false
			Group="Behavior"
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
