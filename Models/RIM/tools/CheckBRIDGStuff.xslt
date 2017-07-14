<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mif="urn:hl7-org:v3/mif">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:template match="mif:staticModel">
    <xsl:if test="not(mif:packageLocation/@realm='US')">
      <xsl:text>Error: Realm for model is not set to 'US'&#x0A;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="descendant::mif:class"/>
  </xsl:template>
  <xsl:template match="mif:class">
    <xsl:variable name="className" select="@name"/>
    <xsl:if test="count(mif:annotations/mif:mapping[not(@sourceName='BRIDG')])!=0">
      <xsl:value-of select="concat('Error: Class ', $className, ' has a mapping whose source name is not BRIDG.&#x0A;')"/>
    </xsl:if>
    <xsl:if test="count(mif:annotations/mif:mapping[@sourceName='BRIDG' and not(contains(., '.') or contains(., '('))])!=0">
      <xsl:variable name="mapToNames">
        <xsl:for-each select="mif:annotations/mif:mapping[@sourceName='BRIDG' and not(contains(., '.') or contains(., '('))]">
          <xsl:value-of select="concat(' ', normalize-space(.))"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="not(starts-with(normalize-space(mif:annotations/mif:definition), normalize-space($mapToNames)))">
        <xsl:value-of select="concat('Warning: Class ', $className, ' has mappings to BRIDG classes, but does not have an appropriate note.  Expecting: ', normalize-space($mapToNames), ', got: ', normalize-space(mif:annotations/mif:definition), '&#x0A;')"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="count(mif:annotations/mif:mapping[@sourceName='BRIDG' and not(contains(., '.')) and contains(., '(')])!=0">
      <xsl:for-each select="mif:annotations/mif:mapping[@sourceName='BRIDG' and not(contains(., '.')) and contains(., '(')]">
        <xsl:variable name="modelClass" select="normalize-space(substring-before(substring-after(., '('), ')'))"/>
        <xsl:variable name="umlClass" select="normalize-space(substring-before(., '('))"/>
        <xsl:for-each select="//mif:class[@name=$modelClass]">
          <xsl:if test="not(contains(normalize-space(mif:annotations/mif:definition), $umlClass))">
            <xsl:value-of select="concat('Warning: Class ', $modelClass, ' has indirect mappings to a BRIDG class (noted on ', $className, '), but does not have an appropriate note.  Expecting to contain: ', $umlClass, ', got: ', normalize-space(mif:annotations/mif:definition), '&#x0A;')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
    <xsl:apply-templates select="mif:attribute"/>
  </xsl:template>
  <xsl:template match="mif:attribute">
    <xsl:variable name="className" select="parent::mif:class/@name"/>
    <xsl:variable name="attributeName" select="@name"/>
    <xsl:if test="not(@isMandatory='true') and @fixedValue">
      <xsl:value-of select="concat('Error: Attribute ', $className, '.', $attributeName, ' has a fixed value but is not mandatory.&#x0A;')"/>
    </xsl:if>
    <xsl:if test="count(mif:annotations/mif:mapping[not(@sourceName='BRIDG')])!=0">
      <xsl:value-of select="concat('Error: Attribute ', $className, '.', $attributeName, ' has a mapping whose source name is not BRIDG.&#x0A;')"/>
    </xsl:if>
    <xsl:for-each select="mif:annotations/*[not(self::mif:mapping or self::mif:openIssues or self::mif:usageNotes or self::mif:designComments or self::mif:constraint or self::mif:rationale)][normalize-space(.)!='']">
      <xsl:value-of select="concat('Error: Attribute ', $className, '.', $attributeName, ' has an annotation type ', name(.), ' that is not a mapping, constraint design note, implementation note or issue.&#x0A;')"/>
    </xsl:for-each>
    <xsl:if test="not(@fixedValue) and count(mif:annotations/mif:mapping)=0 and count(mif:annotations/mif:usageNotes)=0">
      <xsl:value-of select="concat('Error: Attribute ', $className, '.', $attributeName, ' has does not have a mapping or usage note and is not a fixed value.&#x0A;')"/>
    </xsl:if>
    <xsl:for-each select="mif:annotations/mif:mapping[@sourceName='BRIDG']">
      <xsl:variable name="mappedTo">
        <xsl:choose>
          <xsl:when test="contains(., '(')">
            <xsl:value-of select="normalize-space(substring-before(., '('))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="trimmedMappedTo">
        <xsl:choose>
          <xsl:when test="contains($mappedTo, '.')">
            <xsl:value-of select="normalize-space(substring-after($mappedTo, '.'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$mappedTo"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="count(ancestor::mif:attribute/mif:businessName[contains(@name, $trimmedMappedTo)])=0">
        <xsl:value-of select="concat('Error: Attribute ', $className, '.', $attributeName, ' has a mapping and the name of the mapped-to attribute (', $trimmedMappedTo, ') is not present in the business name (', ancestor::mif:attribute/mif:businessName/@name, ').&#x0A;')"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>

