#tag Class
Protected Class QueryCompilerUnitTests
Inherits TestGroup
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
		  Assert.AreEqual("1.0", QueryCompiler.Value(1.0))
		  
		  // Very small number
		  Assert.AreEqual("0.00000000001", QueryCompiler.Value(0.00000000001))
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


End Class
#tag EndClass
