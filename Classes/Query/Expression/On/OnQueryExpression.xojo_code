#tag Class
Protected Class OnQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As Text
		  If pLastQueryExpression IsA OnQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA OnCloseQueryExpression Then
		    Return "AND " + Predicate()
		  End If
		  
		  If pLastQueryExpression IsA OnOpenQueryExpression Then
		    Return Predicate()
		  End If
		  
		  Return "ON " + Predicate()
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLeftColumn As Auto, pOperator As Text, pRightColumn As Auto)
		  mLeftColumn = pLeftColumn
		  mOperator = pOperator
		  mRightColumn = pRightColumn
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLeftColumn as Auto, pOperator as Text, pRightColumn as Auto, pDataType as DataType)
		  mLeftColumn = pLeftColumn
		  mOperator = pOperator
		  mRightColumn = pRightColumn
		  mDatatype = pDataType
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 3
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Predicate() As Text
		  if mDatatype = DataType.IntegerType or mRightColumn.IsNumeric then
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + mRightColumn.AutoTextValue
		  elseif mDatatype = DataType.TextType or mDatatype = DataType.CharType or mDatatype = DataType.VarCharType  then
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + mRightColumn.AutoTextValue
		    
		  else
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + QueryCompiler.Column(mRightColumn)
		  end if
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDatatype As DataType
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLeftColumn As Auto
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOperator As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRightColumn As Auto
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
