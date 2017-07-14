<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" exclude-result-prefixes="uml xmi">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <modelElements>
      <xsl:for-each select="/xmi:XMI/uml:Model//packagedElement[@name='BRIDG Domain Analysis Model']">
        <xsl:for-each select="packagedElement[@xmi:type='uml:Package'][@name!='Deleted Classes']/packagedElement[@xmi:type='uml:Class'][@name!='Legend' and @name!='bridg' and @name]">
          <xsl:sort select="@name"/>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="packagedElement[@xmi:type='uml:Package'][@name!='Deleted Classes']/packagedElement[@xmi:type='uml:Class'][@name!='Legend' and @name!='bridg' and @name]/ownedAttribute[@name]">
          <xsl:sort select="parent::*/@name"/>
          <xsl:sort select="@name"/>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:variable name="associations">
          <xsl:apply-templates select="packagedElement[@xmi:type='uml:Package'][@name!='Deleted Classes']/packagedElement[@xmi:type='uml:Association']"/>
        </xsl:variable>
        <xsl:for-each select="$associations/*">
          <xsl:sort select="@className"/>
          <xsl:sort select="@name"/>
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:for-each>
    </modelElements>
  </xsl:template>
  <xsl:template match="packagedElement[@xmi:type='uml:Class']">
    <xsl:if test="count(//element[@xmi:idref=current()/@xmi:id]/properties[@stereotype='DEPRECATED'])=0">
      <class>
        <xsl:attribute name="name" select="@name"/>
        <xsl:for-each select="//packagedElement[@xmi:id=current()/generalization/@general]">
          <xsl:attribute name="specializes" select="@name"/>
        </xsl:for-each>
      </class>
    </xsl:if>
  </xsl:template>
  <xsl:template match="packagedElement[@xmi:type='uml:Association']">
<!--    <xsl:variable name="fromName" select="normalize-space(substring-before(@name, '/'))"/>
    <xsl:variable name="toName" select="normalize-space(substring-after(@name, '/'))"/>
    <xsl:if test="$fromName='' or $toName=''">
      <xsl:message select="concat('Unrecognized association name structure: ', @name)"/>
    </xsl:if>-->
    <xsl:variable name="source" select="//*[@xmi:id=current()/memberEnd[1]/@xmi:idref]"/>
    <xsl:variable name="target" select="//*[@xmi:id=current()/memberEnd[2]/@xmi:idref]"/>
    <xsl:if test="count(//connector[@xmi:idref=current()/@xmi:id]/properties[@stereotype='DEPRECATED'])=0">
      <xsl:for-each select="$source">
        <associationEnd>
          <xsl:attribute name="className" select="//packagedElement[@xmi:id=$target/type/@xmi:idref]/@name"/>
<!--        <xsl:attribute name="name" select="$fromName"/>-->
<!--        <xsl:attribute name="name" select="concat(@name,'[',//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name,']')"/>-->
          <xsl:attribute name="name" select="@name"/>
          <xsl:attribute name="targetClass" select="//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name"/>
          <xsl:attribute name="lowerCardinality" select="lowerValue/@value"/>
          <xsl:choose>
            <xsl:when test="upperValue/@value=-1">
              <xsl:attribute name="upperCardinality" select="'*'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="upperCardinality" select="upperValue/@value"/>
            </xsl:otherwise>
          </xsl:choose>
        </associationEnd>
      </xsl:for-each>
      <xsl:for-each select="$target">
        <associationEnd>
          <xsl:attribute name="className" select="//packagedElement[@xmi:id=$source/type/@xmi:idref]/@name"/>
<!--        <xsl:attribute name="name" select="$toName"/>-->
<!--        <xsl:attribute name="name" select="concat(@name,'[',//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name,']')"/>-->
          <xsl:attribute name="name" select="@name"/>
          <xsl:attribute name="targetClass" select="//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name"/>
          <xsl:attribute name="lowerCardinality" select="lowerValue/@value"/>
          <xsl:choose>
            <xsl:when test="upperValue/@value=-1">
              <xsl:attribute name="upperCardinality" select="'*'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="upperCardinality" select="upperValue/@value"/>
            </xsl:otherwise>
          </xsl:choose>
        </associationEnd>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ownedAttribute[not(@association or @isDerived='true')]">
    <xsl:if test="count(//attribute[@xmi:idref=current()/@xmi:id]/stereotype[@stereotype='DEPRECATED'])=0">
      <attribute>
        <xsl:attribute name="className" select="parent::*/@name"/>
        <xsl:attribute name="name" select="@name"/>
        <xsl:variable name="type">
          <xsl:for-each select="//*[@xmi:id=current()/type/@xmi:idref]">
            <xsl:value-of select="@name"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="type" select="$type"/>
      </attribute>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
