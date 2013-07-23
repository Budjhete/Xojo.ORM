#tag Class
Protected Class SelectQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  return "SELECT " + QueryCompiler.Columns(mColumns) + " FROM " + QueryCompiler.TableNames(mTableNames, mAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String)
		  Dim pColumns() As Variant
		  
		  pColumns.Append(new ExpressionQueryExpression("*"))
		  
		  Constructor(pColumns, Array(pTableName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Variant, pTableNames() As String)
		  Constructor(pColumns, pTableNames, pTableNames)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Variant, pTableNames() As String, pAlias() As String)
		  mColumns = pColumns
		  mTableNames = pTableNames
		  mAlias = pAlias
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Variant, pTableName As String)
		  Constructor(pColumns, Array(pTableName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Variant, pTableName As String, pAlias As String)
		  Constructor(pColumns, Array(pTableName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As Variant, pTableName As String)
		  Constructor(Array(pColumn), Array(pTableName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As Variant, pTableName As String, pAlias As String)
		  Constructor(Array(pColumn), Array(pTableName), Array(pAlias))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  return 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAlias() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mColumns() As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableNames() As String
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
