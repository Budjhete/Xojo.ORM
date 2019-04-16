#tag Class
Protected Class InsertQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  #Pragma Unused pLastQueryExpression
		  
		  Dim pColumns As Text
		  
		  // No columns makes a simple insertion
		  If mColumns.Ubound > -1 Then
		    pColumns = " ( " + QueryCompiler.Columns(mColumns) + " )"
		  End If
		  
		  Return "INSERT INTO " + QueryCompiler.TableName(mTableName) + pColumns  // MYSQL fonctionne avec IGNORE INTO et SQLITE OR IGNORE INTO, trouver solution pour faire un choix
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pTableName As Text, pColumns() As Auto)
		  mTableName = pTableName
		  mColumns = pColumns
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColumns() As Auto
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableName As Text
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
