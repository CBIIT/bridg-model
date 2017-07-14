<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:variable name="BRIDGPackage" select="'BRIDG Domain Analysis Model'"/>
  <xsl:template match="/">
    <xsl:for-each select="xmi:XMI/uml:Model">
      <xsl:element name="uml:Model" namespace="http://www.eclipse.org/uml2/3.0.0/UML">
        <xsl:copy-of select="parent::xmi:XMI/@xmi:version"/>
        <xsl:apply-templates select="@*"/>
        <xsl:attribute name="name" select="'BRIDG'"/>
        <xsl:if test="not(//packagedElement[@name=$BRIDGPackage])">
          <xsl:message terminate="yes" select="concat('Unable to find packaged element with name: ', $BRIDGPackage)"/>
        </xsl:if>
        <xsl:for-each select="//packagedElement[@name=$BRIDGPackage]">
          <xsl:for-each select="packagedElement[@xmi:type='uml:Package']/packagedElement[@xmi:type='uml:Class' and @name and @name!='Text' and @name!='Legend']">
            <xsl:sort select="@name"/>
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="//packagedElement[@name=$BRIDGPackage]">
          <xsl:for-each select="packagedElement[@xmi:type='uml:Package']/packagedElement[@xmi:type='uml:Association']">
            <xsl:sort select="@name"/>
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="//packagedElement[@xmi:type='uml:PrimitiveType']">
          <xsl:sort select="@name"/>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*" priority="3">
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@*"/>
      <xsl:namespace name="uml" select="'http://www.eclipse.org/uml2/3.0.0/UML'"/>
      <xsl:apply-templates select="text()|*|comment()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="packagedElement[@xmi:type='uml:Class']" priority="5">
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@*"/>
      <xsl:namespace name="uml" select="'http://www.eclipse.org/uml2/3.0.0/UML'"/>
      <xsl:apply-templates select="*"/>
      <xsl:for-each select="//packagedElement[@xmi:type='uml:Association']/ownedEnd[type[@xmi:idref=current()/@xmi:id]]">
        <xsl:choose>
          <xsl:when test="count(preceding-sibling::ownedEnd) + count(following-sibling::ownedEnd)=0">
            <xsl:apply-templates mode="attribute" select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="attribute" select="preceding-sibling::ownedEnd|following-sibling::ownedEnd"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="preceding-sibling::ownedEnd|following-sibling::ownedEnd">
        </xsl:for-each>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <xsl:template mode="attribute" match="ownedEnd">
    <xsl:element name="ownedAttribute">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="name" select="concat(@name, //packagedElement[@xmi:id=current()/type/@xmi:idref]/@name)"/>
      <xsl:attribute name="association" select="parent::packagedElement/@xmi:id"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="type[count(//*[@xmi:id=current()/@xmi:idref][not(self::EAStub)])=0]" priority="5"/>
  <xsl:template match="node()[parent::*/@xmi:type='uml:PrimitiveType']" priority="5"/>
  <xsl:template match="packagedElement[@xmi:type='uml:StateMachine']|ownedBehavior" priority="5"/>
<!--  <xsl:template match="@isSubmachineState"/>
  <xsl:template match="annotatedElement[count(//*[@xmi:id=current()/@xmi:idref][not(ancestor-or-self::*[self::ownedBehavior or @xmi:type='uml:StateMachine'])])=0]" priority="10"/>
  <xsl:template match="annotatedElement" priority="5">
    <xsl:message select="concat(count(//*[@xmi:id=current()/@xmi:idref]), ':', count(ancestor-or-self::*[self::ownedBehavior or @xmi:type='uml:StateMachine']))"/>
  </xsl:template>
  <xsl:template match="thecustomprofile:*" priority="5"/>-->
  <xsl:template match="@xmi:id|@xmi:idref">
    <xsl:attribute name="{name(.)}">
      <xsl:value-of select="translate(., ' ', '')"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="ownedEnd" priority="5"/>
</xsl:stylesheet>
