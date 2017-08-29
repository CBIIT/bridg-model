'******************************************************************************
'* Purpose:  Validate EAP Model information
'* Author:   Steve Sandberg
'* Date:     2009-12-25
'* Updated by: Mike Woodcock woodcock.mike -at- mayo.edu 5-10-2010 to 2-24-2011
'* Change Log: See EAP - Validate Model Change Log.doc
'******************************************************************************
		' control line feed = vbCrLf
option explicit
	Repository.ClearOutput("Script")
	Session.Output( "=Start================================= " & Time )
	Session.Output( "VBScript to Validate BRIDG EAP Model" )
	Session.Output( "----------------------------------------" )
	
' Define Global variables 
    Dim XL			' Excel object
    DIM Sheet1, Sheet2		' Excel worksheets
    Dim Row1, Row2 		' Excel row counters

    dim MESSAGE_OUTPUT		' EA Project Output
    'dim xmlDOM			' EA Project output

    dim Msg, MsgError, MsgWarning, MsgInformation, Pkg ' message components
    dim outputType
	outputType = "Excel"
	'outputType = "EASession"
	const HKEY_CURRENT_USER = &H80000001
	
    ' Create Array of diagram names in BRIDG Model to be used for checking
	' diagrams for elements
	' Changed tempArray(9) to tempArray(10), added Imaging - WNV 20170828
    dim tempArray(10)
	tempArray(0) = "UML-Based Comprehensive BRIDG Model Diagram"
	tempArray(1) = "View AE: Adverse Event"
	tempArray(2) = "View BSP: Biospecimen"
	tempArray(3) = "View CM: Common"
	tempArray(4) = "View EX: Experiment"
	tempArray(5) = "View MB: Molecular Biology"
	tempArray(6) = "View PR: Protocol Representation"
	tempArray(7) = "View RG: Regulatory"
	tempArray(8) = "View SA: Statistical Analysis"	
	tempArray(9) = "View SC: Study Conduct"	
	tempArray(10) = "View IM: Imaging"	

' Initialization
	InitializeOutput

' Iterate through all models in the project
	dim currentPackage as EA.Package 'dim here to scope variable for entire script
	dim currentModel as EA.Package
	for each currentModel in Repository.Models
		Session.Output( "Model = " & currentModel.Name )
		Msg = currentModel.Name
		WriteMessage "Model", "Name", MsgInformation, Msg, Pkg
		
		ProcessPackage currentModel
	next

' Finalization
	FinalizeOutput

' Clean Up	
	set XL= Nothing			
	Sheet1 = ""
	Sheet2 = ""
	Row1 = ""
	Row2 = ""
	set MESSAGE_OUTPUT = Nothing
	'set xmlDOM = Nothing
	Msg = ""
	MsgError = ""
	MsgWarning = ""
	MsgInformation = ""
	Pkg = ""
	outputType = ""

	Session.Output( "=End================================== " & Time )

'******************************************************************************
' Process each package in the model
'
' Parameters:
' - thePackage	: The package object to be processed
'******************************************************************************
sub ProcessPackage ( thePackage )
	
	set currentPackage = thePackage
	Pkg = currentPackage.Name
	Session.Output( "Package=" & currentPackage.Name )
	If currentPackage.Name = "ISO 21090 Data Types"	then
		Exit Sub
	end if
	' Process the elements within the package
	dim currentElement as EA.Element
	for each currentElement in currentPackage.Elements
		'Session.Output( " - Element = " & currentElement.Name & _
		'	" (" & currentElement.Type & ")" )
		Select Case currentElement.Type
		Case "Class"
			'Session.Output( " - Element = " & currentElement.Name & _
			'	" (" & currentElement.Type & ")" )
			ValidateClass CurrentElement
		Case "Text"
			'ValidateText CurrentElement
		Case "Note"
			'ValidateNote CurrentElement
		Case "Object"
			'ValidateObject CurrentElement
		Case "State"
			'ValidateState CurrentElement
		Case "StateNode"
			'ValidateStateNode CurrentElement
		Case "Boundary"
			'ValidateBoundary CurrentElement
		Case "Port"
			'ValidatePort CurrentElement
		Case Else
			'Session.Output( "*** ERROR: Unknown Element = " & currentElement.Name & _
			'" (" & currentElement.Type & ")" )
			Msg = "Unknown model element type found."
			WriteMessage currentElement.Type, currentElement.Name, MsgError, Msg, Pkg
		End Select
	next
		
	' Recursively process any child packages
	dim childPackage as EA.Package
	for each childPackage in currentPackage.Packages
		ProcessPackage childPackage
	next

	Set currentElement = Nothing

end sub
'******************************************************************************
'  process class validation rules
'
' Parameters:
' - theClass		: the element object to process
'******************************************************************************
Sub ValidateClass ( theClass )

	dim currentClass as EA.Element
	set currentClass = theClass
	dim tempText1, tempText2

	' Each class must have a name
	If currentClass.Name = Empty Then
		Msg = "Each class must have a name."
		WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
	else
		' Each class name must begin with capital letter
		If Mid(currentClass.Name,1,1) <> ucase(Mid(currentClass.Name,1,1)) Then
			Msg = "Class name should begin with a capital letter."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg 
		End if
		
		' Each class name must not contain spaces, conjuntions or prepositions
		if InStr(1,currentClass.Name," ") <> 0 Then 
			Msg = "Class name should not contain spaces."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg 
		end if
		if InStr(1,currentClass.Name,"-") <> 0 Then 
			Msg = "Class name should not contain special characters (dash)."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg 
		end if
		if InStr(1,currentClass.Name,"_") <> 0 Then 
			Msg = "Class name must not contain special characters (underscore)."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg  
		end if
		if InStr(1,currentClass.Name,"And") <> 0 Then 
			Msg = "Class name must not contain conjunctions (and)."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg 
		end if
		if InStr(1,currentClass.Name,"Or") <> 0 Then
			if InStr(1,currentClass.Name,"Or") <> InStr(1,currentClass.Name,"Org") Then 
				Msg = "Class name must not contain conjunctions (or)."
				WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg 
			end if
		end if
		'if InStr(1,currentClass.Name,"The") <> 0 Then 
		'	Msg = "Class name must not contain prepositions."
		'	WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
		'end if
		
	end if
	
	' Each class must have a definition.  Minimum character count is 15. MWW
	dim tempDef, tempExample, tempLoc, tempLoca, tempLocb
	tempLoc = instr(1,currentClass.Notes,"DEFINITION",1)
	tempLoca = instr(1,currentClass.Notes,"EXAMPLE(S)",1)
	tempLocb = instr(1,currentClass.Notes,"OTHER NAME(S)",1)
	tempDef = mid(currentClass.Notes, (tempLoc + 11), tempLoca)
	tempExample = mid(currentClass.Notes, (tempLoca + 11), tempLocb)
	'session.Output (CurrentClass.Name &" temploc: " & tempLoc & " Temploca: " & tempLoca & " TempLocb: " _
	'& tempLocb & " tempDef: " & tempDef & " TempExample: " & tempExample)
	If Len(tempDef) < 26 Then
		Msg = "Each class must have a definition."
		WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
	else
		'Each class description should contain examples. Min. characters is 5
		if Len(tempExample) < 16 Then 
			Msg = "Each class should contain examples."
			WriteMessage currentClass.Type, currentClass.Name, MsgWarning, Msg, Pkg
		end if
	end if
	
	if currentClass.Status <> "<none>" Then
		Msg = "The status for a class must be '<none>'."
		WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
	end if

	'Each class should have mapping tags (tagged values)
	'Session.Output ("Class tag count = " & currentClass.TaggedValuesEx.Count )
	If currentClass.TaggedValuesEx.Count = 0 Then
		Msg = "Each class should have at least one mapping tag."
		WriteMessage currentClass.Type, currentClass.Name, MsgWarning, Msg, Pkg
	end if
	
	'Check for duplicate mapping tags (tagged values)
	'If (currentClass.TaggedValuesEx.Count > 1) then
	'	Dim dupTags
	'	Dim intElem
	'	Dim intLoop
	'	Dim intCount
	'	Dim curElemValue, curElemName, curElemNotes
	'	Dim curLoop
		
		'Look for duplicate mapping tags (tagged values)
	'	For intElem = 0 to currentClass.TaggedValuesEx.Count - 1
	'		intCount = 0 ' count of occurences
	'		curElemValue = currentClass.TaggedValuesEx.GetAt(intElem).Value 'get a tag value
	'		curElemName = currentClass.TaggedValuesEx.GetAt(intElem).Name 'get a tag value
	'		Session.Output "intElem = " & intElem
	'		Session.Output'
	'		"curElemValue =" & curElemValue & ", curElemName =" & curElemName & ", curElemNotes =" & curElemNotes
	'		For intLoop = 0 to currentClass.TaggedValuesEx.Count - 1 'compare tag value to the rest
	'			curLoop = currentClass.TaggedValuesEx.GetAt(intLoop).Value
	'			Session.Output "curLoop =" & curLoop
	'			Session.Output "intLoop = " & intElem
	'			If curElemValue = curLoop then
	'				intCount = intCount + 1 'count duplicates
	'			Session.Output "curLoop =" & curLoop & " has " & intCount & " instances."	
	'			end if
	'		Next
			
	'		If intCount > 1 Then 'if count > 1 add to list of dupes
	'			If Instr(dupTags, curElem & ", ") = 0 then
	'				dupTags = dupTags & curElem & ", "
	'			end if
	'		end if	
	'	Next	
	'End if
	
	' Each class should have at least one attribute
	'If currentClass.Attributes.Count = 0 Then
	'	Msg = "Each class should have at least one attribute."
	'	WriteMessage currentClass.Type, currentClass.Name, MsgWarning, Msg, Pkg
	'end if
	
	' Each class must have at least one relationship
	If currentClass.Connectors.Count = 0 Then
		Msg = "Each class must have at least one relationship."
		WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
	end if

	' Process the connectors associated to the class
	dim currentConnector as EA.Connector
	for each currentConnector in currentClass.Connectors
		If currentClass.ElementID = currentConnector.ClientID Then
			'Session.Output( " - Connector = " & currentConnector.Type & _
			'	" " & currentConnector.Name & _
			'	" (" & currentConnector.ConnectorID & ")" )
			Select Case currentConnector.Type
			Case "Association", "Aggregation", "Composition"
				ValidateAssociation CurrentConnector
			Case "Generalization"
				ValidateGeneralization CurrentConnector
			Case "NoteLink"
				' Ignore note links
			Case Else
				'Session.Output( "*** ERROR: Unknown Connector = " & currentConnector.ConnectorID & _
				'" (" & currentConnector.Type & ")" )
				Msg = "Unknown connector type."
				WriteMessage currentConnector.Type, currentConnector.ConnectorID, MsgError, Msg, Pkg
			End Select
		end if
	next
	
	' Process the attributes within the class
	dim currentAttribute as EA.Attribute
	for each currentAttribute in currentClass.Attributes
		'Session.Output( "    Attribute=" & currentClass.Name & _
		'"." & currentAttribute.Name & _
		'" (" & currentAttribute.Type & ")" )
		ValidateAttribute currentAttribute
	next

	' Since there is no easy method to determine the default color of a class belonging to 
	' a particular sub-Domain (EA Package), these values are hard coded (Colors are decimal
	' representation of hex colors exactly as stored by EA). Each package is assigned its
	' default diagram. MWW
	' Added cases for Imaging, Out of Scope MB, updated colors after setting defaults correctly
	' in EAP - WNV 20170828
	dim tempSearchColor, tempSearchColorName, tempDiagToCheck
	tempDiagToCheck = 0	
	Select Case currentPackage.Name
	Case "Adverse Event Sub-Domain"
		tempSearchColor = "13434828"
		tempSearchColorName = "Green"
		tempDiagToCheck = "View AE: Adverse Event"
	Case "Biospecimen Sub-Domain"
		tempSearchColor = "33023"
		tempSearchColorName = "Default"
		tempDiagToCheck = "View BSP: Biospecimen"
	Case "Common Sub-Domain"
		tempSearchColor = "16777102"
		tempSearchColorName = "Aqua Blue"
		tempDiagToCheck = "View CM: Common"
	Case "Experiment Sub-Domain"
		tempSearchColor = "16729600"
		tempSearchColorName = "Default"
		tempDiagToCheck = "View EX: Experiment"
	Case "Molecular Biology Sub-Domain"
		tempSearchColor = "49280"
		tempSearchColorName = "Default"
		tempDiagToCheck = "View MB: Molecular Biology"
	Case "Out of Scope for HL7 May 2017 Ballot Cycle: Molecular Biology Sub-Domain"
		tempSearchColor = "49280"
		tempSearchColorName = "Default"
		tempDiagToCheck = "View MB: Molecular Biology"
	Case "Protocol Representation Sub-Domain"
		tempSearchColor = "15445455"
		tempSearchColorName = "Purple"
		tempDiagToCheck = "View PR: Protocol Representation"
	Case "Regulatory Sub-Domain"
		tempSearchColor = "10738942"
		tempSearchColorName = "Orange"
		tempDiagToCheck = "View RG: Regulatory"
	Case "Statistical Analysis Sub-Domain"
		tempSearchColor = "10092287"
		tempSearchColorName = "Yellow"
		tempDiagToCheck = "View SA: Statistical Analysis"
	Case "Study Conduct Sub-Domain"
		tempSearchColor = "13684974"
		tempSearchColorName = "Pink"
		tempDiagToCheck = "View SC: Study Conduct"
	Case "Imaging Sub-Domain"
		tempSearchColor = "16752895"
		tempSearchColorName = "Magenta"
		tempDiagToCheck = "View IM: Imaging"
Session.Output( "Got here 1" )
	Case Else
		tempSearchColor = "Undefined"
		tempSearchColorName = "Undefined"
		tempDiagToCheck = "1"
Session.Output( "Got here 1" )
		Session.Output( "No colors defined for package " & currentPackage.Name )
	End Select	
	
	' Loop through array of diagramIDs/names and query repository to see if class
	' is found in diagram. tempArray is global array of BRIDG diagram names. MWW
	dim tempDiagramID, i, tempDiagramName
	dim tempInhere, tempResult
	For i = 0 to UBound(tempArray)
		tempDiagramName = tempArray(i)
		tempResult = Repository.SQLQuery("SELECT t_object.Name, t_diagram.Diagram_ID, " _
			& "t_diagramobjects.ObjectStyle, t_object.Backcolor FROM " _
			& "(t_diagram INNER JOIN t_diagramobjects ON t_diagram.Diagram_ID = " _
			& "t_diagramobjects.Diagram_ID) INNER JOIN t_object ON t_diagramobjects.Object_ID = " _
			& "t_object.Object_ID WHERE (((t_object.Name)='" & currentClass.Name & "')" _
			& "AND ((t_diagram.Name)= '" & tempDiagramName & "'))")

		' Check for class name in string of search results of BRIDG diagram
		tempInhere = instr(1,tempResult,currentClass.Name,1)
		
		'If current diagram is main BRIDG model, make sure current class is in it.
		if tempDiagramName = "UML-Based Comprehensive BRIDG Model Diagram" _
		AND (tempInhere = 0 or tempInhere = Null) Then
			'Session.Output("String " & currentClass.Name & " was not found in " & tempDiagramName)
			Msg = "Each class must be in the BRIDG Comprehensive Model Diagram."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
		end if
		
		' Test to see if the Class is in the diagram belonging to the package
		' as assigned by CASE statement above
		If (tempDiagToCheck = tempDiagramName) AND (tempInhere = 0 or tempInhere = Null) Then
			Msg = "Each class from the " & pkg & " package must be in the diagram " _
			& tempDiagramName & "."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg		
		End if
		
		' If class is in diagram then make sure it is the correct color.
		' Diagram object fill color is stored in objects.backcolor (table.field) but
		' is overridden by "BCol=" portion of string stored in diagramobjects.objectstyle.
		' If no color is specified color is determined by user default color stored
		' in HK_CURRENT_USER hive of Windows Registry. MWW
		dim NodelistStyle, ElemStyle, xmldoc, Elem, Root, Nodelist, tempBC, tempFoundDia
		if (tempInhere <> 0 or tempInhere <> Null) Then
			tempFoundDia = 1 'Signal that class was found in a sub-diagram
			
			' Create & load XML Object to hold returned query results (EA returns XML when using 
			' SQLQuery method)
			set xmlDoc=CreateObject("Microsoft.XMLDOM")
			xmlDoc.async="false"
			xmlDoc.loadXML(tempResult)

			Set Root = xmlDoc.documentElement
			Set NodeList = Root.getElementsByTagName("Backcolor")
			Set NodeListStyle = Root.getElementsByTagName("ObjectStyle")
			tempBC = Nodelist.length
			
			' Loop through one or more XML records returned by query for this class
			' and look for correct color in two different nodes
			dim tempCorrectColorB, tempCorrectColorOS, tempFindOS, tempColorToMatch
			dim tempOSColor, idx, tempfBColor, tempfosColor, tempFoundColorOS

			for idx = 0 to tempBC - 1
	
				tempfBColor = NodeList.item(idx).text 'backcolor
				tempfosColor = NodeListStyle.item(idx).text 'objectstyle
				
				'Look at BackColor node contents
				if tempfBColor = tempSearchColor then
					tempCorrectColorB = 1
				Elseif instr(1,tempfBColor, "-1",1) then
					tempCorrectColorB = -1
				Else
					tempCorrectColorB = 0
				end if
				Session.Output("tempfBColor: " & tempfBColor)
				'Session.Output("tempCorrectColorB value: " & tempCorrectColorB)

				'Look for BCol= in ObjectStyle node string; if it exists, extract and compare
				'to search color value
				tempFindOS = instr(1,tempfosColor,"BCol=",1)
				dim tempGetColon 
				if tempFindOS <> 0 or tempFindOS <> Null Then
					tempGetColon = instr((tempFindOS + 5),tempfosColor,";",1)
					tempOSColor = Mid(tempfosColor,(tempFindOS + 5), (tempGetColon - (tempFindOS + 5)))
					Session.Output("tempGetObjectStyle color is = " & tempOSColor)
					
					If tempOSColor = tempSearchColor then
						tempCorrectColorOS = 1
					Elseif instr(1,tempOSColor, "-1",1) then
						tempCorrectColorOS = -1
					Else
						tempCorrectColorOS = 0
					end if
					Session.Output("tempCorrectColorOS value is = " & tempCorrectColorOS)
					
				else
					tempCorrectColorOS = 0
				end if
				
				'Get default fill color from user registry
				dim strComputer, tempReg, tempKeyPath, tempFill, tempDefaultColor
				strComputer = "."
				Set tempReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
				strComputer & "\root\default:StdRegProv")
 
				tempKeyPath = "SOFTWARE\Sparx Systems\EA400\EA\OPTIONS"
				tempFill = "FILLCLR"
				tempReg.GetDWORDValue HKEY_CURRENT_USER,tempKeyPath,tempFill,tempDefaultColor
				'Session.Output("Current User default Color is: " & tempDefaultColor)
				
				' Color of diagram objects depends on values found in three locations
				' and the states of each location. Colors match (1), no match (0) and override (-1)
				' If correct color is found in ObjectStyle and -1 in Backcolor
				if tempCorrectColorOS = 1 and tempCorrectColorB = -1 then
					tempColorToMatch = tempOSColor
				' If  -1 found in ObjectStyle and -1 in Backcolor
				elseif tempCorrectColorOS = -1 and tempCorrectColorB = -1 then
					tempColorToMatch = tempDefaultColor				
				' If correct color is not found in ObjectStyle and is found (1) in Backcolor
				elseif tempCorrectColorOS = 0 and tempCorrectColorB = 1 then
					tempColorToMatch = tempfbColor
				' If correct color is found in ObjectStyle and found in Backcolor
				elseif tempCorrectColorOS = 1 and tempCorrectColorB = 1 then
					tempColorToMatch = tempOSColor
				' If -1 is found in ObjectStyle and color matches in Backcolor
				elseif tempCorrectColorOS = -1 and tempCorrectColorB = 1 then
					tempColorToMatch = tempfbColor
				' If correct color is found in ObjectStyle and no color found in Backcolor
				elseif tempCorrectColorOS = 1 and tempCorrectColorB = 0 then
					tempColorToMatch = tempOSColor
				' If -1 is found in ObjectStyle and no color match in Backcolor
				elseif tempCorrectColorOS = -1 and tempCorrectColorB = 0 then
					tempColorToMatch = tempfbColor				
				else 
					tempColorToMatch = "Not Found(" & tempfBColor & "&" & tempOSColor & ")"
				end if
				
				Session.Output("tempColorToMatch is = " & tempColorToMatch)
				Session.Output("tempSearchColor is  = " & tempSearchColor)
				
				' Process color information
				if tempColorToMatch <> tempSearchColor then
					Msg = "Instance " & idx & " of " & currentClass.Name & " from the " & _
					currentPackage.Name & " package has incorrect fill color (" & tempColorToMatch &") in " & _
					tempDiagramName & " diagram. Color should be " & tempSearchColorName & "."
					WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
					Session.Output("Error************************************")
					Session.Output("Instance " & idx & " of " & currentClass.Name & " from the  " _
					& currentPackage.Name & " has incorrect fill color (" & tempColorToMatch &") in " & tempDiagramName & _
					". Color should be " & tempSearchColorName & ".")
				end if	
			next
		end if
	next 

	' If a class in not found in any sub-diagram throw an error. MWW
	if 	tempFoundDia <> 1 then
			Msg = currentClass.Name & " from the " & currentPackage.Name & _
			" package has not been found in any sub-diagram."
			WriteMessage currentClass.Type, currentClass.Name, MsgError, Msg, Pkg
			'Session.Output(currentClass.Name & " from the  " & currentPackage.Name & _ 
			'" has not been found in any diagram.")
	end if
	
	' Clean up
	tempText1 = ""
	tempText2 = ""
	tempDef = ""
	tempExample = ""
	tempLoc = ""
	tempLoca = ""
	tempLocb = ""
	tempSearchColor = ""
	tempSearchColorName = ""
	tempDiagToCheck = ""
	tempDiagramID = ""
	i = ""
	tempDiagramName = ""
	tempInhere = ""
	tempResult = ""
	NodelistStyle = ""
	ElemStyle = ""
	set	xmldoc = Nothing
	set	Elem = Nothing
	set	Root = Nothing
	set	Nodelist = Nothing
	tempBC = ""
	tempFoundDia = ""
	tempCorrectColorB = ""
	tempCorrectColorOS = ""
	tempFindOS = ""
	tempColorToMatch = ""
	tempOSColor = ""
	idx = ""
	tempfBColor = ""
	tempfosColor = ""
	tempFoundColorOS = ""
	tempGetColon = ""
	strComputer = ""
	tempReg = ""
	tempKeyPath = ""
	tempFill = ""
	tempDefaultColor = ""
	
End sub

'******************************************************************************
'  process Association validation rules
'
' Parameters:
' - theAssociation : the association to be processed
'******************************************************************************
Sub ValidateAssociation ( theAssociation )

	dim currentAssociation as EA.Connector
	set currentAssociation = theAssociation
	dim tempText1
	dim tempCount
	dim holdAssocName, tempName
	holdAssocName = Repository.GetElementByID(currentAssociation.ClientID).name & _
		"->" & Repository.GetElementByID(currentAssociation.SupplierID).name

	' Each association must have a name
	If currentAssociation.Name = Empty Then
		Msg = "Each connection must have a name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		'Session.Output("Current Association Name = " & currentAssociation.Name)	
		' Each association name should be in lower case letters
		If currentAssociation.Name <> lcase(currentAssociation.Name) Then
			Msg = "Connection name should be in lower case letters."
			WriteMessage currentAssociation.Type, holdAssocName, MsgWarning, Msg, Pkg
		End if
		'Select Case currentAssociation.Type
		'Case "Association"
		'	'nothing
		'Case "Aggregation"
		'	If currentAssociation.Name <> "is collected in" Then
		'		Msg = "Aggregation name should be 'is collected in'."
		'		WriteMessage currentAssociation.Type, holdAssocName, MsgWarning, Msg, Pkg
		'	End if
		'Case "Composition"
		'	If currentAssociation.Name <> "is part of" Then
		'		Msg = "Composition name should be 'is part of'."
		'		WriteMessage currentAssociation.Type, holdAssocName, MsgWarning, Msg, Pkg
		'	End if
		'End Select
	end if

	' Each association must appear in BRIDG comprehensive diagram and at least one sub-diagram
	' Loop through array of diagramIDs/names and query repository to see if association 
	' is found in diagram.
	dim tempDiagramID, i, tempDiagramName, tempAssocResult
	dim tempComp, tempFoundAssoc
		
		'Query repository with connector_id to get xml text of found records. Extra result
		' fields are for future error checking. MWW
		tempAssocResult = Repository.SQLQuery("SELECT t_connector.Connector_ID, t_connector.Name " _
		& "AS Connector_Name, start.Name AS StartObjectName, end.Name AS EndObjectName, " _
		& "t_package.Name AS Package_Name, t_diagramlinks.DiagramID, t_diagram.Name AS Diagram_Name " _
		& "FROM t_diagram RIGHT JOIN ((t_diagramlinks RIGHT JOIN ((t_connector INNER JOIN " _
		& " t_object AS start ON t_connector.Start_Object_ID = start.Object_ID) INNER JOIN " _
		& "t_object AS [end] ON t_connector.End_Object_ID = end.Object_ID) ON " _
		& "t_diagramlinks.ConnectorID = t_connector.Connector_ID) INNER JOIN t_package ON " _
		& "start.Package_ID = t_package.Package_ID) ON t_diagram.Diagram_ID = t_diagramlinks.DiagramID " _
		& "WHERE (((t_connector.Connector_ID)= " & currentAssociation.ConnectorID & "))")
		'Session. ("String " & holdAssocName & " query returns " & tempAssocResult)
		For i = 0 to UBound(tempArray) 'Array of BRIDG diagram names from global variables
			tempDiagramName = tempArray(i)
			' Check query result for diagram name
			tempComp = instr(1,tempAssocResult,tempDiagramName,1)
			
			'If current diagram is main BRIDG model, make sure current class is in it.
			if tempDiagramName = "UML-Based Comprehensive BRIDG Model Diagram" _
			AND (tempComp = 0 or tempComp = Null) Then
				'Session.Output("String " & holdAssocName & " was not found in " & tempDiagramName)
				Msg = "Each association must be in the BRIDG Comprehensive Model Diagram."
				WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
			elseif (tempComp <> 0 or tempComp <> Null) AND _
			(tempDiagramName <> "UML-Based Comprehensive BRIDG Model Diagram") Then
				tempFoundAssoc = 1
				'Session.Output("String " & holdAssocName & currentAssociation.ConnectorID _
				'& " was not found in " & tempDiagramName)
			end if
		next

	' If an association is not found in any sub-diagram throw an error.
	if 	tempFoundAssoc <> 1 then
			Msg = holdAssocName & " association from the " & currentPackage.Name & _
			" package has not been found in any sub-diagram."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
			'Session.Output(currentClass.Name & " from the  " & currentPackage.Name & _ 
			'" has not been found in any diagram.")
	end if

	' Each inverse association must have a name
	dim currentConstraint as EA.Constraint
	dim tempInverseName
	tempInverseName = ""
	tempCount = 0
	for each currentConstraint in currentAssociation.Constraints
		'Session.Output( "ConnectorConstraint=" & currentConstraint.Name &_
		'" (" & currentConstraint.Type & ")" )
		'Each constraint must be inverse relation or invariant type
		if (currentConstraint.Type <> "Inverse Relation") and _
		(currentConstraint.Type <> "Invariant") then
			Msg = "Each constraint must be an inverse relation or invariant type."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		end if	
			
		If currentConstraint.Type = "Inverse Relation" then
			tempInverseName = currentConstraint.Name
			tempCount = tempCount + 1
		end if
		
		'Each constraint must have a definition
		'dim tempDef
		'if currentConstraint.Notes = Empty then
		'	Msg = "Each constraint must have a definition."
		'	WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		'end if
	next
		
	If tempCount = 0 Then
		Msg = "Each connection must have an inverse name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	elseif tempCount > 1 Then
		Msg = "Each connection should have only one inverse name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association inverse name should be in lower case letters
		If tempInverseName <> lcase(tempInverseName) Then
			Msg = "Connection inverse name should be in lower case letters."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
	end if

	' Each association must have a source role name
	If currentAssociation.ClientEnd.Role = Empty Then
		Msg = "Each connection should have a source role name. - " + Repository.GetElementByID(currentAssociation.ClientID).name
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	'else
	'	' Each association source role name should be in lower case letters
	'	If currentAssociation.ClientEnd.Role <> lcase(currentAssociation.ClientEnd.Role) Then
	'		Msg = "Connection source role name should be in lower case letters. - " + Repository.GetElementByID(currentAssociation.ClientID).name
	'		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	'	End if
	end if

	' Each association must have a target role name
	If currentAssociation.SupplierEnd.Role = Empty Then
		Msg = "Each connection should have a target role name. - " + Repository.GetElementByID(currentAssociation.SupplierID).name
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	'else
	'	' Each association target role name should be in lower case letters
	'	If currentAssociation.SupplierEnd.Role <> lcase(currentAssociation.SupplierEnd.Role) Then
	'		Msg = "Connection target role name should be in lower case letters. - " + Repository.GetElementByID(currentAssociation.SupplierID).name
	'		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	'	End if
	end if
	
' Each association must have source multiplicity
	If currentAssociation.ClientEnd.Cardinality = Empty Then
		Msg = "Each connection must have multiplicity defined for source."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association must have valid source multipliticy
		If currentAssociation.ClientEnd.Cardinality = "0..1" or _
		currentAssociation.ClientEnd.Cardinality = "0..*" or _
		currentAssociation.ClientEnd.Cardinality = "1" or _
		currentAssociation.ClientEnd.Cardinality = "1..*" then
			' ok
		else
			Msg = "Each connection must have valid source multipliticy."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
	end if
	
	' Each association must have target multiplicity
	If currentAssociation.SupplierEnd.Cardinality = Empty Then
		Msg = "Each connection must have multiplicity defined for target."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association must have valid target multipliticy
		If currentAssociation.SupplierEnd.Cardinality = "0..1" or _
		currentAssociation.SupplierEnd.Cardinality = "0..*" or _
		currentAssociation.SupplierEnd.Cardinality = "1" or _
		currentAssociation.SupplierEnd.Cardinality = "1..*" then
			' ok
		else
			Msg = "Each connection must have valid target multipliticy."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
	end if
	
	'Following suggstion of Abdul-Malik Shakur, associations should have 0..* relationship on the 
	' Supplier (Source) side of the association. MWW 12-13-2010
	If currentAssociation.ClientEnd.Cardinality = "1..*" and _
		currentAssociation.SupplierEnd.Cardinality = "0..*" then
			Msg = "Each connection must have 0...* as the Source cardinality. Found 1..* as Source Cardinality and" _
			& " 0..* as Destination cardinality."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	End if
	
	' Each association should have a description
	If currentAssociation.Notes = Empty Then
		Msg = "Each connection should have a description. Notes is empty."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association description should be in a valid format
		tempText1 = "Each "
		tempText1 = tempText1 & Repository.GetElementByID(currentAssociation.ClientID).name
		if Mid(currentAssociation.SupplierEnd.Cardinality,1,1) = "0" Then 
			tempText1 = tempText1 & " might "
		else
			tempText1 = tempText1 & " always "
		end if
		tempText1 = tempText1 & currentAssociation.Name
		'tempLength = Len(currentAssociation.SupplierEnd.Cardinality)
		'if tempLength = 1 then tempLength = 2 end if
		if Right(currentAssociation.SupplierEnd.Cardinality,1) = "1" Then 
			tempText1 = tempText1 & " one "
		else
			tempText1 = tempText1 & " one or more "
		end if
		tempText1 = tempText1 & Repository.GetElementByID(currentAssociation.SupplierID).name
		tempText1 = tempText1 & "."

		tempText1 = tempText1 & " Each "
		tempText1 = tempText1 & Repository.GetElementByID(currentAssociation.SupplierID).name
		if Mid(currentAssociation.ClientEnd.Cardinality,1,1) = "0" Then 
			tempText1 = tempText1 & " might "
		else
			tempText1 = tempText1 & " always "
		end if
		tempText1 = tempText1 & tempInverseName
		'tempLength = len(currentAssociation.ClientEnd.Cardinality)
		'if tempLength = 1 then tempLength = 2 end if
		if Right(currentAssociation.ClientEnd.Cardinality,1) = "1" Then 
			tempText1 = tempText1 & " one "
		else
			tempText1 = tempText1 & " one or more "
		end if
		tempText1 = tempText1 & Repository.GetElementByID(currentAssociation.ClientID).name
		tempText1 = tempText1 & "."

		dim tempDef, tempFound
		tempText1 = trim(tempText1)
		tempText1 = replace(temptext1, "  "," ")
		tempDef = trim(currentAssociation.Notes)
		tempDef = replace(tempDef,".  ",". ")
		tempFound = inStr(1,tempDef,tempText1,1)
		'Session.Output ( " -- TEMP Found = " & tempFound)
		'Session.Output ( " -- TEMP Built = " & tempText1)
		
		If (tempFound = 0) or (tempFound = Null) Then
			'Session.Output ( " -- Generated description =" & tempText1 )
			'Session.Output ( " -- Validated description =" & tempDef )
			Msg = "Connection description should be in a valid format." & vbCrlf & _
			"Built: " & tempText1 & vbCrLf & _
			"Found: " & tempDef
			WriteMessage currentAssociation.Type, holdAssocName, MsgWarning, Msg, Pkg
		End if
	end if
	
	' Clean up
	tempText1 = ""
	tempCount = ""
	holdAssocName = ""
	tempName = ""
	tempDiagramID = ""
	i = ""
	tempDiagramName = ""
	tempAssocResult = ""
	tempComp = ""
	tempFoundAssoc = ""
	tempInverseName = ""
	tempDef = ""
	tempFound = ""

End sub
'******************************************************************************
'  process Generalization validation rules
'
' Parameters:
' - theAssociation : the association to be processed
'******************************************************************************
Sub ValidateGeneralization ( theAssociation )

	dim currentAssociation as EA.Connector
	set currentAssociation = theAssociation
	dim holdAssocName
	holdAssocName = Repository.GetElementByID(currentAssociation.ClientID).name & _
		"->" & Repository.GetElementByID(currentAssociation.SupplierID).name

	' Each association must have a name
	If currentAssociation.Name = "" Then
		Msg = "Each generalization should have a name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association name should be in lower case letters
		If currentAssociation.Name <> lcase(currentAssociation.Name) Then
			Msg = "Generalization name should be in lower case letters."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
		If currentAssociation.Name <> "specializes" Then
			Msg = "Generalization name should be 'specializes'."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
	end if

	' Each inverse association must have a name
	dim currentConstraint as EA.Constraint
	dim tempInverseName, tempCount
	tempInverseName = ""
	tempCount = 0
	for each currentConstraint in currentAssociation.Constraints
		'Session.Output( "ConnectorConstraint=" & currentConstraint.Name &_
		'" (" & currentConstraint.Type & ")" )
		If currentConstraint.Type = "Inverse Relation" Then
			tempInverseName = currentConstraint.Name
			tempCount = tempCount + 1
		end if
	next
	If tempCount = 0 Then
		Msg = "Each generalization should have an inverse name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	elseif tempCount > 1 Then
		Msg = "Each generalization should have only one inverse name."
		WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
	else
		' Each association inverse name should be in lower case letters
		If tempInverseName <> lcase(tempInverseName) Then
			Msg = "Generalization inverse name should be in lower case letters."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
		If tempInverseName <> "be specialized by" Then
			Msg = "Generalization name should be 'be specialized by'."
			WriteMessage currentAssociation.Type, holdAssocName, MsgError, Msg, Pkg
		End if
	end if

	' Clean Up
	holdAssocName = ""
	tempInverseName = ""
	tempCount = ""

End sub
'******************************************************************************
'  process each attribute
'
' Parameters:
' - CurrentItem	: the element object to process
'******************************************************************************

Sub ValidateAttribute (CurrentItem)

	dim currentAttribute as EA.Attribute
	set currentAttribute = CurrentItem
	
	dim currentClass as EA.Element
	set currentClass = Repository.GetElementByID(currentAttribute.ParentID)

	dim holdAttribName
	holdAttribName = currentClass.Name & "." & currentAttribute.Name

	'Each attribute name must begin with lower case
	If Mid(currentAttribute.Name,1,1) <> lcase(Mid(currentAttribute.Name,1,1)) Then
		Msg = "Attribute name should begin with a lower case letter."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	End if
		
	' Each class name should not contain spaces, conjuntions or prepositions
	if InStr(1,currentAttribute.Name," ") <> 0 Then 
		Msg = "Attribute name should not contain spaces."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if
	if InStr(1,currentAttribute.Name,"-") <> 0 Then 
		Msg = "Attribute name should not contain special characters (dash)."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if
	if InStr(1,currentAttribute.Name,"_") <> 0 Then 
		Msg = "Attribute name should not contain special characters (underscore)."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if
	if InStr(1,currentAttribute.Name,"And") <> 0 Then 
		Msg = "Attribute name should not contain conjunctions (and)."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if
	'if InStr(1,currentAttribute.Name,"Or") <> 0 Then
	'	if InStr(1,currentAttribute.Name,"Or") <> InStr(1,currentAttribute.Name,"Org") Then 
	'		Msg = "Attribute name should not contain conjunctions."
	'		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	'	end if
	'end if
	'if InStr(1,currentAttribute.Name,"The") <> 0 Then 
	'	Msg = "Attribute name should not contain prepositions."
	'	WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	'end if

	'Each attribute must have a datatype
	'Each attribute must have a valid datatype
	'Each attribute suffix should match datatype
	'Session.Output ( " Attribute Name = " & currentAttribute.Name &_
	'" (Type = " & currentAttribute.Type & ")" )
	Select Case currentAttribute.Type
	Case "AD", "BAG<AD>"
		if lcase(Right(currentAttribute.Name,13)) <> "postaladdress" and lcase(Right(currentAttribute.Name,15)) <> "physicaladdress" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'postal address' or 'physical address'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "ANY"
		'?	
	Case "BAG<TEL>", "TEL"
		if lcase(Right(currentAttribute.Name,14)) <> "telecomaddress" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'telecomaddress'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "BL"
		if lcase(Right(currentAttribute.Name,9)) <> "indicator" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'indicator'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "CD", "DSET<CD>"
		if lcase(Right(currentAttribute.Name,4)) <> "code" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'code'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "DSET<EN>", "DSET<ON>", "DSET<TN>", "DSET<PN>", "PN", "TN"
		if lcase(Right(currentAttribute.Name,4)) <> "name" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'name'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	' Added ID and DSET<ID> - WNV 20170828
	Case "DSET<II>", "II", "ID", "DSET<ID>"
		if lcase(Right(currentAttribute.Name,10)) <> "identifier" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'identifier'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "DSET<SC>"
		if lcase(Right(currentAttribute.Name,6)) <> "reason" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'reason'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "DSET<ST>"
		if lcase(Right(currentAttribute.Name,4)) <> "text" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'text'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "ED"
		'no further validation required
	Case "EXPR<PQ>"
		'no further validation required
	Case "INT.POS", "INT.NONNEG"
	' Added Coordinate - WNV 20170828
		if lcase(Right(currentAttribute.Name,7)) <> "integer" and _
		lcase(Right(currentAttribute.Name,5)) <> "count" and _
		lcase(Right(currentAttribute.Name,6)) <> "number" and _
		lcase(Right(currentAttribute.Name,5)) <> "order" and _
		lcase(Right(currentAttribute.Name,7)) <> "percent" and _
		lcase(Right(currentAttribute.Name,8)) <> "quantity" and _
		lcase(Right(currentAttribute.Name,10)) <> "coordinate" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'integer', 'count', " _
			& "'order', 'percent', 'number', 'quantity', or 'coordinate'"	
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "OID"
		if lcase(Right(currentAttribute.Name,12)) <> "codingsystem" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'codingsystem'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "PQ", "EXPR<PQ>"
	' Added width, height, diameter, and dimension - WNV 20170828
		if lcase(Right(currentAttribute.Name,8)) <> "quantity" and _ 
		lcase(Right(currentAttribute.Name,4)) <> "dose" and _ 
		lcase(Right(currentAttribute.Name,5)) <> "total" and _ 
		lcase(Right(currentAttribute.Name,5)) <> "width" and _ 
		lcase(Right(currentAttribute.Name,6)) <> "height" and _ 
		lcase(Right(currentAttribute.Name,8)) <> "diameter" and _ 
		lcase(Right(currentAttribute.Name,9)) <> "dimension" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'quantity', 'dose', 'total', 'width', 'height', 'diameter', or 'dimension' "
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "PQ.TIME"
		if lcase(Right(currentAttribute.Name,8)) <> "duration" and lcase(Right(currentAttribute.Name,3)) <> "age" and lcase(Right(currentAttribute.Name,6)) <> "period" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'duration', 'age', 'period'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "REAL"
	' Added Capacity and Quotient - WNV 20170828
		if lcase(Right(currentAttribute.Name,7)) <> "percent" _ 
		and lcase(Right(currentAttribute.Name,6)) <> "number" _
		and lcase(Right(currentAttribute.Name,8)) <> "fraction" _
		and lcase(Right(currentAttribute.Name,8)) <> "capacity" _
		and lcase(Right(currentAttribute.Name,8)) <> "quotient" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'number', 'percent', 'fraction', 'capacity', or 'quotient' "
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "SC"
		if lcase(Right(currentAttribute.Name,7)) <> "comment" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'comment'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "ST"
		'no further verification is needed
	Case "ST.SIMPLE"
		'no further verificaiton is needed
	Case "DSET<TEL.URL>", "TEL.URL"
		if lcase(Right(currentAttribute.Name,24)) <> "uniformresourcelocator" Then 
			Msg = "Verify attribute name is valid for data type (URL). Looking for 'uniformresourcelocator'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "TS", "TS.DATE", "TS.DATE.FULL", "TS.DATETIME"
		if lcase(Right(currentAttribute.Name,4)) <> "date" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'date'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "IVL<TS.DATE>", "IVL<TS.DATETIME>", "IVL<TS.DATE.FULL>"
		if (lcase(Right(currentAttribute.Name,8)) <> "duration" and lcase(Right(currentAttribute.Name,5)) <> "range") Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'duration' or 'range'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "IVL<EXPR<TS.DATETIME>>", "IVL<INT.POS>", "IVL<INT>"
		if (lcase(Right(currentAttribute.Name,5)) <> "range") Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'range'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "RTO<INT.NONNEG,INT.POS>", "RTO<INT.NONNEG,PQ.TIME>", "RTO<PQ,PQ.TIME>", "RTO<PQ,PQ>"
		if lcase(Right(currentAttribute.Name,5)) <> "ratio" _
		and lcase(Right(currentAttribute.Name,4)) <> "rate" _
		and lcase(Right(currentAttribute.Name,6)) <> "weight" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'ratio', 'rate' or 'weight'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case "URG<INT.NONNEG>", "URG<INT.POS>", "URG<PQ.TIME>", "URG<PQ>"
		if lcase(Right(currentAttribute.Name,5)) <> "range" Then 
			Msg = "Verify attribute name is valid for data type (" & currentAttribute.Type & "). Looking for 'range'"
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	Case Else
		Msg = "Each attribute should have a valid data type. Found data type: " & currentAttribute.Type
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	End Select

	'Each attribute must have valid lowerbound and upperbound
	If currentAttribute.LowerBound = "1" _
	or left(currentAttribute.LowerBound,2) = "1." _
	or currentAttribute.LowerBound = "0" Then
		'OK
	else
		Msg = "Each attribute should have a valid LowerBound (0 or 1) - currently " & CurrentAttribute.LowerBound & "."
		WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
	end if
	If currentAttribute.UpperBound = "1" Then
		'OK
	ELSEIf currentAttribute.UpperBound = "*" Then
		if Left(currentAttribute.Type,3) = "BAG" or Left(currentAttribute.Type,4) = "DSET" Then
			'OK
		else
			Msg = "Collection attribute should have a matching data type (BAG or DSET)."
			WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
		end if
	else
		Msg = "Each attribute should have a valid UpperBound."
		WriteMessage "Attribute", holdAttribName, MsgWarning, Msg, Pkg
	end if

	'Each attribute must have a definition MWW
	dim tempDef, tempExample, tempLoc, tempLoca, tempLocb
	tempLoc = instr(1,currentAttribute.Notes,"DEFINITION",1)
	tempLoca = instr(1,currentAttribute.Notes,"EXAMPLE(S)",1)
	'tempLocb = instr(1,currentAttribute.Notes,"OTHER NAME(S)",1)
	tempDef = mid(currentAttribute.Notes, (tempLoc + 11), tempLoca)
	'tempExample = mid(currentClass.Notes, (tempLoca + 11), (tempLocb))
	'session.Output ("temploc: " & tempLoc & " Temploca: " & tempLoca & " TempLocb: " _
	'& tempLocb & " tempDef: " & tempDef & " TempExample: " & tempExample)
	If Len(tempDef) < 26 Then
		Msg = "Each attribute must have a definition."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	'else
		'Each attribute description should contain examples. Min. characters is 5
	'	if Len(tempExample) < 16 = 0 Then 
	'		Msg = "Each attribute should contain examples."
	'		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	'	end if
	end if
	
	'Each attribute should have mapping tags MWW
	'Session.Output ("Attribute Tag count = " & currentAttribute.TaggedValuesEx.Count )
	'If currentAttribute.TaggedValuesEx.Count = 0 Then
	'	Msg = "Attribute should have at least one mapping tag."
	'	WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	'end if
	dim currentTag as EA.TaggedValue
	dim tagFound
	tagFound = False
	for each currentTag in currentAttribute.TaggedValues
		'Session.Output( "Attribute tag =" & currentTag.Name & _
		'"." & currentTag.Value )
		tagFound = True
	next
	If tagFound = False Then
		Msg = "Attribute should have at least one mapping tag."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if

	'Each attribute must have a "public" Scope
	If currentAttribute.Visibility <> "Public" then
		Msg = "Attribute must have a 'Public' scope."
		WriteMessage "Attribute", holdAttribName, MsgError, Msg, Pkg
	end if

	' Clean Up
	holdAttribName = ""
	tempDef = ""
	tempExample = ""
	tempLoc = ""
	tempLoca = ""
	tempLocb = ""
	tagFound = ""

End sub

'******************************************************************************
'  Write the Error Message
'
' Parameters:
' - theType	: the type of element
' - theItem	: the element with an error
' - theMsgType : the type of message
' - theMsg	: the message
' – thePkg	: the current package name
'******************************************************************************
Sub WriteMessage (theType, theItem, theMsgType, theMsg, thePkg)

	Select Case outputType
	Case "EASession"
		Session.Output( "Item Type = " & theType & "/ Item Name = " & theItem & _
		"/ Message Type = " & theMsgType & "/ Message = " & theMsg & "/ Package Name = " & thePkg)
	Case "Excel"
	    XL.sheets(Sheet1).select
		XL.Cells(Row1,1).Value = theType
		XL.Cells(Row1,2).Value = theItem  
		XL.Cells(Row1,3).Value = theMsgType   
		XL.Cells(Row1,4).Value = theMsg
		XL.Cells(Row1,5).Value = thePkg

		Row1 = Row1 + 1
	end Select

end sub
'******************************************************************************
'*  Initialize the validation output
'
' Parameters:
'******************************************************************************
Sub InitializeOutput ()

	MsgError = "ERROR"
	MsgWarning = "Warning"
	MsgInformation = "Information"

Select Case outputType
	Case "EASession"
		'nothing
	Case "Excel"
		Set XL = CreateObject("Excel.Application") 
		XL.Visible = True 
		XL.Workbooks.Add
		Sheet1="Messages"
		Row1 = 2
	
		XL.sheets("sheet1").name=Sheet1
		XL.sheets(Sheet1).select
		XL.cells(1,1).Value  = "Item Type"
		XL.cells(1,2).Value  = "Item Name"  
		XL.cells(1,3).Value  = "Message Type"
		XL.cells(1,4).Value  = "Message"  
		XL.cells(1,5).Value  = "Package Name"  

	end Select

	Msg = Date & " " & Time
	WriteMessage "Script", "Run Date/Time", MsgInformation, Msg, Pkg
	
	'Session.Output ("Connection String = " & Repository.ConnectionString)
	Msg = Repository.ConnectionString
	WriteMessage "Repository", "ConnectionString", MsgInformation, Msg, Pkg
	
end sub

'******************************************************************************
'  Check for correct color of objects
'
' Parameters:
' - theAssociation : the association to be processed
'******************************************************************************
Sub CheckColor()


end sub

'******************************************************************************
'  Finalize the validation output
'
' Parameters:
'******************************************************************************
Sub FinalizeOutput ()

	Select Case outputType
	Case "EASession"
		'nothing
	Case "Excel"
		XL.sheets(Sheet1).select    
		XL.Rows("1:1").font.size=10
		XL.Rows("1:1").font.bold=True
		XL.columns("A:A").EntireColumn.AutoFit
		XL.Columns("B:B").ColumnWidth =50
		XL.columns("C:C").EntireColumn.AutoFit
		XL.Columns("D:D").ColumnWidth =50
		XL.columns("E:E").EntireColumn.AutoFit
		XL.Columns("A:E").WrapText = True

		'set color of title row
		XL.Rows("1:1").Select
		XL.Range("A1").Activate
		With XL.Selection.Interior
			.ColorIndex = 34
		End With

		'sort sheet
		'XL.Worksheets(Sheet1).Range("A2:Z9999").Sort XL.Range("C1")
	
		'create filters
		XL.Columns("A:E").Select
		XL.Selection.AutoFilter
	
		'freeze title row of sheet
		XL.Range("A2").Select
		XL.ActiveWindow.FreezePanes = True
	end Select
	
End sub