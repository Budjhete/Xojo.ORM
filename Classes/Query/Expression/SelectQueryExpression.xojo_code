#tag Class
Protected Class SelectQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile() As String
		  return "SELECT " + QueryCompiler.Columns(mTableNameColumns) + " FROM " + QueryCompiler.TableName(mTableName) + " AS " + QueryCompiler.TableName(mAlias)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As Dictionary, pTableName As String)
		  mTableNameColumns = pColumns
		  mTableName = pTableName
		  For i As Integer = 0 To mTableNameColumns.Ubound
		    If mTableNameColumns(i).Value("TableName") = mTableName Then
		      mAlias = mTableNameColumns(i).Lookup("Alias", pTableName)
		      
		      return
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As String, pTableName As String)
		  Constructor(pColumns, pTableName, pTableName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumns() As String, pTableName As String, pAlias As String)
		  mTableNameColumns = Array(New Dictionary("TableName": pTableName, "Alias": pAlias, "Columns": New Dictionary))
		  
		  For i As Integer = 0 To pColumns.Ubound
		    mTableNameColumns(0).Value("Columns").Value(pColumns(i)) = pColumns(i)
		  Next
		  
		  Constructor(mTableNameColumns, pTableName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As String)
		  Constructor(Array("*"), pTableName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As String, pTableName As String)
		  Constructor(pColumn, pTableName, pTableName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pColumn As String, pTableName As String, pAlias As String)
		  Constructor(Array(pColumn), pTableName, pAlias)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  return 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAlias As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mColumns() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableNameColumns() As Dictionary
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
