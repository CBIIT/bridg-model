<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mif="urn:hl7-org:v3/mif" xmlns:mif2="urn:hl7-org:v3/mif2">
  <xsl:output method="text"/>
  <xsl:variable name="uvVocab" select="document('DEFN=UV=VO=908-20090830.coremif')/mif2:vocabularyModel"/>
  <xsl:variable name="caVocab" select="document('DEFN=CA=VO=R02.04.xx.coremif')/mif2:vocabularyModel"/>
  <xsl:template match="/">
    <xsl:variable name="mifs" select="."/>
    <xsl:variable name="conceptDomains">
      <xsl:for-each select="//mif:supplierDomainSpecification[@domainName or @valueSetName]">
        <xsl:sort select="concat(@domainName, @valueSetName)"/>
        <domain>
          <xsl:value-of select="concat(@domainName, @valueSetName)"/>
        </domain>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$conceptDomains/domain">
      <xsl:if test="not(preceding-sibling::domain[1]=current())">
        <xsl:value-of select="concat(., '&#x0A;')"/>
        <xsl:text>  Domain exists?: </xsl:text>
        <xsl:choose>
          <xsl:when test="count($uvVocab/mif2:conceptDomain[@name=current()])!=0">Yes&#x0A;</xsl:when>
          <xsl:otherwise>No&#x0A;</xsl:otherwise>
        </xsl:choose> 
        <xsl:text>  UV binding?:    </xsl:text>
        <xsl:choose>
          <xsl:when test="count($uvVocab/mif2:contextBinding[@conceptDomain=current()])!=0">Yes&#x0A;</xsl:when>
          <xsl:otherwise>No&#x0A;</xsl:otherwise>
        </xsl:choose> 
        <xsl:text>  CA binding?:    </xsl:text>
        <xsl:choose>
          <xsl:when test="count($caVocab/mif2:contextBinding[@conceptDomain=current()])!=0">Yes&#x0A;</xsl:when>
          <xsl:otherwise>No&#x0A;</xsl:otherwise>
        </xsl:choose> 
        <xsl:text>  Used in: &#x0A;</xsl:text>
        <xsl:for-each select="$mifs//mif:supplierDomainSpecification[@domainName=current() or @valueSetName=current()]">
          <xsl:for-each select="ancestor::mif:staticModel/mif:packageLocation">
            <xsl:value-of select="concat('    ', @subSection, @domain, '_')"/>
            <xsl:choose>
              <xsl:when test="@artifact='DIM'">DM</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring(@artifact,1,2)"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat(@id, @realm, @version)"/>
          </xsl:for-each>
          <xsl:value-of select="concat(' ', ancestor::mif:class[1]/@name, '.', ancestor::mif:attribute/@name, '&#x0A;')"/>
        </xsl:for-each>
        <xsl:text>&#x0A;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
