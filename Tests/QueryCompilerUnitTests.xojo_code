#tag Class
Protected Class QueryCompilerUnitTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub ColumnTest()
		  Assert.AreEqual("`column`", QueryCompiler.Column("column"))
		  Assert.AreEqual("`Table`.`column`", QueryCompiler.Column("Table.column"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DateTest()
		  Dim pDate As New Date
		  
		  Assert.AreEqual("'" + pDate.SQLDateTime + "'", QueryCompiler.Value(pDate))
		  
		  pDate = Nil
		  
		  Assert.AreEqual("NULL", QueryCompiler.Value(pDate))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DoubleTest()
		  Assert.AreEqual("1.000000000000", QueryCompiler.Value(1.0))
		  
		  // Very small number
		  Assert.AreEqual("0.000000000001", QueryCompiler.Value(0.000000000001))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IntegerTest()
		  Assert.AreEqual("1", QueryCompiler.Value(1))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NilTest()
		  Assert.AreEqual("NULL", QueryCompiler.Value(Nil))
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
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
			Name="PassedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Group="Behavior"
			Type="Integer"
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
