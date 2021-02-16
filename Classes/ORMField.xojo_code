#tag Class
Protected Class ORMField
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pType as TypeList, pLenght as String, pNotNull as Boolean, pDefaultValue as String, pUnique as Boolean, pPrimary as Boolean)
		  mType = pType
		  mLength = pLenght
		  mNotNull = pNotNull
		  PrimaryKey = pPrimary
		  Unique = pUnique
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DefaultValue(Assigns pDefault as String)
		  mDefaultValue = pDefault
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function DefaultValue(pDatabase as Database) As String
		  if pDatabase isa MySQLCommunityServer then
		    if mDefaultValue<>"" then
		      dim dv as String
		      select case mDefaultValue
		      case "NULL", "NIL"
		        dv = "NULL"
		      case "CURRENT_TIMESTAMP"
		        dv = "CURRENT_TIMESTAMP"
		      else
		        dv = "'"+mDefaultValue+"'"
		      end
		      
		      Return "DEFAULT " + dv
		    else
		      Return ""
		    end if
		  else
		    
		    
		    if mDefaultValue<>"" then
		      dim dv as String
		      select case mDefaultValue
		      case "NULL", "NIL"
		        dv = "NULL"
		      case "CURRENT_TIMESTAMP"
		        dv = "CURRENT_TIMESTAMP"
		      else
		        dv = "'"+mDefaultValue+"'"
		      end
		      
		      Return "DEFAULT " + dv
		    else
		      Return ""
		    end if
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Extra(Assigns pExtra as ExtraList)
		  mExtra = pExtra
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Extra(pDatabase as Database) As String
		  if pDatabase isa MySQLCommunityServer then
		    select case mExtra
		    case ExtraList.AutoIncremente
		      Return "AUTO_INCREMENT"
		      
		    end
		  else
		    select case mExtra
		    case ExtraList.AutoIncremente
		      Return ""
		      
		    end
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Length() As String
		  if mLength="" then return ""
		  if mType = TypeList.BOOLEAN or mType = TypeList.DATETIME or mType = TypeList.BLOB or mType = TypeList.LONGBLOB or mType = TypeList.LONGTEXT or mType = TypeList.TIMESTAMP or mType = TypeList.DATETIME then return ""
		  return "("+mLength+")"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Length(Assigns pLength as String)
		  mLength = pLength
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NotNull() As String
		  if mNotNull then
		    Return "NOT NULL"
		  else
		    return ""
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NotNull(Assigns pValue as Boolean)
		  mNotNull = pValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As ORMFIELD.TypeList
		  Return mType
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Type(Assigns pType as TypeList)
		  mType = pType
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Type(pDatabase as Database) As String
		  If pDatabase ISA MySQLCommunityServer Then
		    select case mType
		    case TypeList.VARCHAR
		      Return "VarChar"
		    case TypeList.TEXT
		      Return "TEXT"
		    case TypeList.INTEGER
		      Return "INT"
		    Case TypeList.SMALLINT
		      Return "SMALLINT"
		    case TypeList.BLOB
		      Return "BLOB"
		    case TypeList.LONGBLOB
		      Return "LONGBLOB"
		    case TypeList.BOOLEAN
		      Return "TINYINT(1)"
		    case TypeList.DATETIME
		      Return "DATETIME"
		    case TypeList.DATE
		      Return "DATE"
		    case Typelist.TIMESTAMP
		      Return "TIMESTAMP"
		    case TypeList.DECIMAL
		      Return "DECIMAL"
		    case TypeList.LONGTEXT
		      Return "LONGTEXT"
		    end select
		  else
		    select case mType
		    case TypeList.TEXT, TypeList.LONGTEXT, TypeList.VARCHAR
		      Return "TEXT"
		    case TypeList.INTEGER, typelist.SMALLINT
		      Return "INTEGER"
		    case TypeList.BLOB, TypeList.LONGBLOB
		      Return "BLOB"
		    case TypeList.BOOLEAN
		      Return "BOOLEAN"
		    case Typelist.TIMESTAMP, TypeList.DATETIME
		      Return "TIMESTAMP"
		    case TypeList.DECIMAL
		      Return "DECIMAL"
		    end select
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDefaultValue As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mExtra As ExtraList
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLength As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNotNull As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mType As TypeList
	#tag EndProperty

	#tag Property, Flags = &h0
		PrimaryKey As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Unique As Boolean = False
	#tag EndProperty


	#tag Enum, Name = ExtraList, Type = Integer, Flags = &h0
		None
		  AutoIncremente
		CurrentTimeStamp
	#tag EndEnum

	#tag Enum, Name = TypeList, Type = Integer, Flags = &h0
		VARCHAR
		  TEXT
		  INTEGER
		  BOOLEAN
		  DECIMAL
		  BLOB
		  DATETIME
		  TIMESTAMP
		  LONGTEXT
		  LONGBLOB
		  DATE
		SMALLINT
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
			Name="PrimaryKey"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Unique"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
