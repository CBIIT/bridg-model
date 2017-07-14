<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mif="urn:hl7-org:v3/mif" xmlns:mif2="urn:hl7-org:v3/mif2">
  <xsl:output method="text"/>
  <xsl:variable name="uvVocab" select="document('DEFN=UV=VO=908-20090830.coremif')/mif2:vocabularyModel"/>
  <xsl:template match="/">
    <xsl:variable name="mifs" select="."/>
    <xsl:variable name="codes">
      <xsl:for-each select="//mif:supplierDomainSpecification[@codeSystemName]">
        <xsl:sort select="@codeSystemName"/>
        <xsl:sort select="@mnemonic"/>
        <code codeSystemName="{@codeSystemName}" mnemonic="{@mnemonic}"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$codes/code">
      <xsl:if test="not(preceding-sibling::code[@codeSystemName=current()/@codeSystemName and @mnemonic=current()/@mnemonic])">
        <xsl:variable name="message">
          <xsl:choose>
            <xsl:when test="count($uvVocab/mif2:codeSystem[@name=current()/@codeSystemName])=0">Code System does not exist</xsl:when>
            <xsl:when test="count($uvVocab/mif2:codeSystem[@name=current()/@codeSystemName]/mif2:releasedVersion/mif2:concept/mif2:code[@code=current()/@mnemonic])=0">Code does not exist within code system</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$message!=''">
          <xsl:value-of select="concat(@codeSystemName, '#', @mnemonic, ': ', $message, '&#x0A;')"/>
          <xsl:text>  Used in: &#x0A;</xsl:text>
          <xsl:for-each select="$mifs//mif:supplierDomainSpecification[@codeSystemName=current()/@codeSystemName and @mnemonic=current()/@mnemonic]">
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
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
