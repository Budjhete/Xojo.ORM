#tag Module
Protected Module DB
	#tag Method, Flags = &h0
		Function Delete(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new DeleteQueryExpression(pTableName))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pTableName As String) As QueryBuilder
		  Return Find(pTableName, Array("*"))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(pTableName As String, pColumns() As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new SelectQueryExpression(pColumns, pTableName))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Insert(pTableName As String, pColumns() As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new InsertQueryExpression(pTableName, pColumns))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update(pTableName As String) As QueryBuilder
		  Dim pQueryBuilder As New QueryBuilder
		  
		  pQueryBuilder.Append(new UpdateQueryExpression(pTableName))
		  
		  Return pQueryBuilder
		End Function
	#tag EndMethod


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
End Module
#tag EndModule
