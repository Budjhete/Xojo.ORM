#tag Class
Protected Class OnQueryExpression
Implements QueryExpression
	#tag Method, Flags = &h0
		Function Compile(pLastQueryExpression As QueryExpression = Nil) As String
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
		Sub Constructor(pLeftColumn As Variant, pOperator As String, pRightColumn As Variant)
		  mLeftColumn = pLeftColumn
		  mOperator = pOperator
		  mRightColumn = pRightColumn
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pLeftColumn as Variant, pOperator as String, pRightColumn as Variant, pDataType as DB.DataType)
		  mLeftColumn = pLeftColumn
		  mOperator = pOperator
		  mRightColumn = pRightColumn
		  mDatatype = pDataType
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetAndroid and (Target64Bit))
		Sub Constructor(pLeftColumn As Variant, pOperator As String, pRightColumn As Variant, pDataType As Variant)
		  mLeftColumn = pLeftColumn
		  mOperator = pOperator
		  mRightColumn = pRightColumn
		  Select Case pDataType.IntegerValue
		  Case 1
		    mDatatype = DB.DataType.TextType
		  Case 2
		    mDatatype = DB.DataType.IntegerType
		  Case 3
		    mDatatype = DB.DataType.VarCharType
		  Case 4
		    mDatatype = DB.DataType.CharType
		  Case 5
		    mDatatype = DB.DataType.DoubleType
		  Case 6
		    mDatatype = DB.DataType.DateType
		  Case 7
		    mDatatype = DB.DataType.TimeType
		  Case 8
		    mDatatype = DB.DataType.TimeStampType
		  Case 9
		    mDatatype = DB.DataType.CurrencyType
		  Case 10
		    mDatatype = DB.DataType.BooleanType
		  Case 11
		    mDatatype = DB.DataType.DecimalType
		  Case 12
		    mDatatype = DB.DataType.BlobType
		  Else
		    mDatatype = DB.DataType.Expression
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Nice() As Integer
		  Return 3
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Predicate() As String
		  if mDatatype = DB.DataType.IntegerType or mRightColumn.IsNumeric then
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + mRightColumn.StringValue
		  elseif mDatatype = DB.DataType.TextType or mDatatype = DB.DataType.CharType or mDatatype = DB.DataType.VarCharType  then
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + mRightColumn.StringValue
		    
		  else
		    Return QueryCompiler.Column(mLeftColumn) + " " + QueryCompiler.Operator(mLeftColumn, mOperator, mRightColumn) + " " + QueryCompiler.Column(mRightColumn)
		  end if
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDatatype As DB.DataType
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLeftColumn As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOperator As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRightColumn As Variant
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
	#tag EndViewBehavior
End Class
#tag EndClass
