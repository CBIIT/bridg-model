This directory contains tools used to manipulate the UML model.  This file
explains how those tools are to be used.

1. ProduceDomainViews.bat
- This process uses saxon8.jar and ProduceDomainViews.xslt to create the domain views.  The domainInfo.xml file
  contains information about the domains to be exported.
- The batch file expects an XMI export of the BRIDG model called "BRIDG.xml" to be located in the parent directory
- The output XMI files will also be placed in the parent directory

2. TagDescriptions.xslt
- This is a one-time conversion that added additional boiler-plate text to the class, attribute and association
  descriptions of the UML model.  It has been retained as a starting point for similar future mass changes.