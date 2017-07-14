<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This transform takes an XMI export of the BRIDG model and, based on on the specified "domain" parameter produces a constrained BRIDG
  - model that only shows the classes relevant to a single domain, including removing unnecessary classes and attributes and renaming
  - attributes based on tags.
  -
  - The transform is dependent on two things: 
  - 1. Having a diagram for the target domain
  -    - The name of the diagram is hard-coded into the transform in the "diagram" variable.  If new domains are added, the transform must be updated
  -    - The specified diagram is the only one retained.  All others are removed from the diagram
  -    - Only those classes shown in the diagram are retained.  Everything else is removed.
  - 2. Having tags on classes and attributes to indicate the need to rename classes and rename or remove attributes
  -
  - NOTE: This transform assumes the use of a UML 2.1 export from Enterprise Architect.  It will not run on anything else.
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <!--
    - Read in domain information from separate source file
    -->
  <xsl:variable name="domains" select="document('domainInfo.xml')/domains"/>
  <!--
    - Read in domain information from separate source file
    -->
  <xsl:template match="/">
    <xsl:if test="not(xmi:XMI)">
      <xsl:message terminate="yes" select="'Error: File must be an XMI 2.1 file.  Unable to process'"/>
    </xsl:if>
    <xsl:if test="not(xmi:XMI/xmi:Extension[@extender='Enterprise Architect'])">
      <xsl:message terminate="yes" select="'Error: File must be an export from Enterprise Architect.  Unable to process'"/>
    </xsl:if>
    <xsl:if test="count($domains/domain)=0">
      <xsl:message terminate="yes" select="'Error: Unable to find domainInfo.xml file or appropriate content within it'"/>
    </xsl:if>
    <!--
      - Put root element in a variable so we can iterate through domains from separate file
      -->
    <xsl:variable name="modelContent" select="xmi:XMI"/>
    <!--
      - Loop through each of the domains specified in the reference file
      -->
    <xsl:for-each select="$domains/domain">
      <xsl:variable name="domain" select="@code"/>
      <xsl:variable name="domainName" select="@diagramTitle"/>
      <xsl:message select="concat('Processing domain ', $domain, ' - ', $domainName)"/>
      <!--
        - Look up the diagram id based on the diagram name.  (Diagram name should be 'View [code]: [title]')
        -->
      <xsl:variable name="diagramId" select="normalize-space($modelContent/xmi:Extension/diagrams/diagram[properties[@name = concat('View ', $domain, ': ', $domainName)]]/@xmi:id)"/>
      <xsl:if test="$diagramId=''">
        <xsl:message terminate="yes" select="concat('Unable to find diagram in model with name: View ', $domain, ': ', $domainName)"/>
      </xsl:if>
      <!--
        - Now that we know what what domain we're dealing with, go through the domain and create the separate domain file
        -->
      <xsl:for-each select="$modelContent">
        <!--
          - Check all tags for this domain and ensure they're recognized and valid
          -->
        <xsl:call-template name="checkTags">
          <xsl:with-param name="domain" select="$domain"/>
        </xsl:call-template>
        <!--
          - The set of classes to include are those in the domain diagram plus all ancestors.  Grab a list of them
          -->
        <xsl:variable name="includedElements">
          <xsl:call-template name="checkGeneralizations">
            <xsl:with-param name="elements">
              <xsl:for-each select="xmi:Extension/diagrams/diagram[@xmi:id=$diagramId]/elements/element">
                <element>
                  <xsl:value-of select="@subject"/>
                </element>
              </xsl:for-each>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <!--
          - Produce a separate domain view for each domain, filtering content
          -->
        <xsl:result-document href="{concat('../', $domain, ' - ', $domainName, ' View.xml')}" >
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="xmi:Documentation"/>
            <xsl:variable name="umlContent">
              <xsl:apply-templates select="uml:Model">
                <xsl:with-param name="domain" select="$domain" tunnel="yes"/>
                <xsl:with-param name="includedElements" select="$includedElements" tunnel="yes"/>
                <xsl:with-param name="modelContent" select="$modelContent" tunnel="yes"/>
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:copy-of select="$umlContent"/>
            <xsl:apply-templates select="xmi:Extension">
              <xsl:with-param name="umlContent" select="$umlContent" tunnel="yes"/>
              <xsl:with-param name="diagramId" select="$diagramId" tunnel="yes"/>
              <xsl:with-param name="includedElements" select="$includedElements" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:copy>
        </xsl:result-document>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  <!--
    - Recursively called template to find exhaustive list of elements that are up the generalization hierarchy of a list of classes
    -->
  <xsl:template name="checkGeneralizations">
    <xsl:param name="elements"/>
    <xsl:variable name="newElements">
      <!--
        - Find any elements that are the start or end of a generalization relationship where the other end isn't already in the list.
        -->
      <xsl:for-each select="//Generalization">
        <xsl:if test="count($elements/element[.=current()/@start]) != 0 and count($elements/element[.=current()/@end]) = 0">
          <element>
            <xsl:value-of select="@end"/>
          </element>
        </xsl:if>
        <xsl:if test="count($elements/element[.=current()/@start]) = 0 and count($elements/element[.=current()/@end]) != 0">
          <element>
            <xsl:value-of select="@start"/>
          </element>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!--
      - If additional elements were found, then repeat the process until we don't find anything new, otherwise we're done.
      -->
    <xsl:choose>
      <xsl:when test="count($newElements/*)=0">
        <xsl:copy-of select="$elements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="checkGeneralizations">
          <xsl:with-param name="elements">
            <xsl:copy-of select="$elements/*"/>
            <xsl:copy-of select="$newElements/*"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    - Look through all the tags in the document checking for those that start with the prefix indicating they're associated with a domain.
    - Verify that the tag is one that is supported and the values specified for the tag are 'legal'.  At the moment there are two tags supported:
    - - 'Exclude', which must have a value of 'yes' or 'true'
    - - 'Alias', which must have a value of the new string to use
    -->
  <xsl:template name="checkTags">
    <xsl:param name="domain" required="yes"/>
    <xsl:for-each select="//tags/tag[starts-with(@name, concat($domain, ':'))]">
      <xsl:choose>
        <xsl:when test="substring-after(@name, ':')='Exclude'">
          <xsl:if test="upper-case(@value)!='TRUE' and upper-case(@value)!='YES'">
            <xsl:message select="concat('Exclude tag value must be be TRUE, not anything else: ', ancestor::element/@name, '.', ancestor::attribute/@name, ' - ', @value)"/>
          </xsl:if>
          <xsl:if test="not(parent::tags/parent::attribute)">
            <xsl:message select="'Exclude tag is only supported on attributes'">
              <xsl:copy-of select="parent::tags/parent::*"/>
            </xsl:message>
          </xsl:if>
        </xsl:when>
        <xsl:when test="substring-after(@name, ':')='Alias'">
          <xsl:if test="not(parent::tags/parent::element[@xmi:type='uml:Class'])">
            <xsl:message select="'Exclude tag is only supported on classes'">
              <xsl:copy-of select="parent::tags/parent::*"/>
            </xsl:message>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('Unrecognized tag name: ', @name, ' on element ', ancestor::element[1]/@name)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!--
    - Default behavior is to just copy everything through
    -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <!--
    - When processing packages, only copy those elements that appropriate for the diagram.
    -->
  <xsl:template match="packagedElement[@xmi:type='uml:Package']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="strip" select="node()"/>
    </xsl:copy>
  </xsl:template>
  <!--
    - Default 
    -->
  <xsl:template mode="strip" match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates mode="strip" select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <!--
    - Filter contained classes and associations
    -->
  <xsl:template mode="strip" match="packagedElement">
    <xsl:param name="domain" tunnel="yes"/>
    <xsl:param name="modelContent" tunnel="yes"/>
    <xsl:param name="includedElements" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not(@xmi:type='uml:Package') and @xmi:id and count($includedElements/*[.=current()/@xmi:id])=0">
        <!--
          - Exclude elements that aren't listed in the "includedElements" list
          -->
      </xsl:when>
      <xsl:when test="not(@xmi:type='uml:Package') and @xmi:idref and count($includedElements/element[.=current()/@xmi:idref])=0">
        <!--
          - Exclude elements that aren't listed in the "includedElements" list
          -->
      </xsl:when>
      <xsl:when test="@xmi:type='uml:Class'">
        <!--
          - When dealing with classes, rename the class if there's an alias tag.
          -->
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:variable name="name" select="@name"/>
          <xsl:for-each select="$modelContent/xmi:Extension/elements/element[@xmi:idref=current()/@xmi:id]/tags/tag[@name=concat($domain, ':Alias')]">
            <xsl:attribute name="name" select="@value"/>
            <xsl:message select="concat('Renamed class ', $name, ' to ', @value)"/>
          </xsl:for-each>
          <xsl:apply-templates mode="strip" select="node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="strip" select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    - Only include comments that are attached to 'included' elements or aren't attached at all
    -->
  <xsl:template mode="strip" match="ownedComment" priority="10">
    <xsl:param name="includedElements" tunnel="yes"/>
    <xsl:variable name="includeComment">
      <xsl:choose>
        <xsl:when test="count(annotatedElement)=0">true</xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="annotatedElement">
            <xsl:if test="count($includedElements/*[.=current()/@xmi:idref])!=0">true</xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$includeComment!=''">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:for-each select="annotatedElement">
          <xsl:if test="count($includedElements/*[.=current()/@xmi:idref])!=0">
            <xsl:copy-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!--
    - When processing attributes, strip them if they're flagged as "Exclude".
    -->
  <xsl:template mode="strip" match="ownedAttribute">
    <xsl:param name="domain" tunnel="yes"/>
    <xsl:param name="modelContent" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="count($modelContent/xmi:Extension/elements/element[@xmi:idref=current()/parent::packagedElement[@xmi:type='uml:Class']/@xmi:id]/attributes/attribute[@name=current()/@name]/tags/tag[@name=concat($domain, ':Exclude')])=0">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('Stripped ', @name)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    - Remove tags now that they've been applied
    -->
  <xsl:template mode="strip" match="tag">
    <xsl:param name="domain" tunnel="yes"/>
    <xsl:if test="not(starts-with(@name, concat($domain, ':')))">
      <xsl:copy>
        <xsl:apply-templates mode="strip" select="node()|@*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!--
    - Only include extension elements that were retained in the UML model
    -->
  <xsl:template match="element">
    <xsl:param name="umlContent" tunnel="yes"/>
    <xsl:if test="not(@xmi:refid and count($umlContent//*[xmi:id=current()/@xmi:refid])=0)">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!--
    - Only include the identified "view" diagram when copying diagrams
    -->
  <xsl:template match="diagram" priority="10">
    <xsl:param name="diagramId" tunnel="yes"/>
    <xsl:if test="@xmi:id=$diagramId">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>  
</xsl:stylesheet>
