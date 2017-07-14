<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mif="urn:hl7-org:v3/mif">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:template match="/">
    <xsl:text>This document contains a listing of the issues, development notes and design considerations in the BRIDG RIM models&#x0A;</xsl:text>
    <xsl:text>&#x0A;ISSUES:&#x0A;(Items that need to be fixed in BRIDG or are not currently properly expressible in the RIM models&#x0A;&#x0A;</xsl:text>
    <xsl:call-template name="sortIssues">
      <xsl:with-param name="issues">
        <xsl:apply-templates select="//mif:openIssues"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#x0A;IMPLEMENTATION CONSIDERATIONS:&#x0A;(Notes to implementers on how to use the RIM model to reflect BRIDG semantics&#x0A;&#x0A;</xsl:text>
    
    <xsl:call-template name="sortIssues">
      <xsl:with-param name="issues">
        <xsl:apply-templates select="//mif:usageNotes"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#x0A;DEVELOPMENT NOTES:&#x0A;(Items that require clean-up or verification within the models.  No action required by SCC&#x0A;&#x0A;</xsl:text>
    <xsl:call-template name="sortIssues">
      <xsl:with-param name="issues">
        <xsl:apply-templates select="//mif:designComments"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="sortIssues">
    <xsl:param name="issues"/>
    <xsl:for-each select="$issues/issue">
      <xsl:sort select="@model"/>
      <xsl:if test="not(preceding-sibling::*[1]=current())">
        <xsl:value-of select="concat('  ', @model, ' ', @class)"/>
        <xsl:if test="@attribute">
          <xsl:value-of select="concat('.', @attribute)"/>
        </xsl:if>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:value-of select="concat('    ', ., '&#x0A;&#x0A;')"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="mif:openIssues|mif:usageNotes|mif:designComments">
    <issue>
      <xsl:variable name="model">
        <xsl:for-each select="ancestor::mif:staticModel/mif:packageLocation">
          <xsl:value-of select="concat(@subSection, @domain, '_')"/>
          <xsl:choose>
            <xsl:when test="@artifact='DIM'">DM</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring(@artifact,1,2)"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="concat(@id, @realm, @version)"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:attribute name="model" select="$model"/>
      <xsl:attribute name="class" select="ancestor::mif:class[1]/@name"/>
      <xsl:if test="ancestor::mif:attribute">
        <xsl:attribute name="attribute" select="ancestor::mif:attribute/@name"/>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
    </issue>
  </xsl:template>
</xsl:stylesheet>
