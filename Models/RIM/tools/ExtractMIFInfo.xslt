<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mif="urn:hl7-org:v3/mif" exclude-result-prefixes="mif">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <xsl:variable name="mappings">
      <xsl:apply-templates select="//mif:mapping"/>
    </xsl:variable>
    <xsl:variable name="sortedMappings">
      <xsl:for-each select="$mappings/*">
        <xsl:sort select="name(.)"/>
        <xsl:sort select="@className"/>
        <xsl:sort select="@name"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <modelElements>
      <xsl:for-each select="$sortedMappings/class">
        <xsl:if test="count(preceding-sibling::class[1][@name=current()/@name])=0">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$sortedMappings/attribute">
        <xsl:if test="count(preceding-sibling::attribute[1][@className=current()/@className and @name=current()/@name and @type=current()/@type])=0">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$sortedMappings/associationEnd">
        <xsl:if test="count(preceding-sibling::associationEnd[1][@className=current()/@className and @name=current()/@name and @targetClass=current()/@targetClass])=0">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </modelElements>
  </xsl:template>
  <xsl:template match="mif:mapping">
    <xsl:variable name="mappedElement">
      <xsl:choose>
        <xsl:when test="contains(., '(') and not(contains(., '['))">
          <xsl:value-of select="normalize-space(substring-before(., '('))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(contains($mappedElement, '.'))">
        <class>
          <xsl:attribute name="name" select="$mappedElement"/>
          <xsl:call-template name="mappedTo"/>
        </class>
      </xsl:when>
      <xsl:when test="contains($mappedElement, '[')">
        <associationEnd>
          <xsl:variable name="className" select="substring-before($mappedElement, '.')"/>
          <xsl:choose>
            <xsl:when test="contains($className, '(')">
              <xsl:attribute name="className" select="normalize-space(substring-before($className, '('))"/>
              <xsl:variable name="refClass" select="normalize-space(substring-before(substring-after($className, '('), ')'))"/>
              <xsl:if test="count(ancestor::mif:staticModel/mif:ownedClass/*[@name=$refClass])=0">
                <xsl:message select="concat('Error: Unknown referenced class: ', $refClass, ' in mapping: ', $mappedElement)"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="className" select="normalize-space($className)"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:variable name="fullAssociation" select="substring-after($mappedElement, '.')"/>
          <xsl:attribute name="name" select="normalize-space(substring-before($fullAssociation, '['))"/>
          <xsl:attribute name="targetClass" select="normalize-space(substring-before(substring-after($fullAssociation, '['), ']'))"/>
          <xsl:if test="contains($fullAssociation, '(')">
            <xsl:variable name="refClass" select="normalize-space(substring-before(substring-after($fullAssociation, '('), ')'))"/>
            <xsl:if test="count(ancestor::mif:staticModel/mif:ownedClass/*[@name=$refClass])=0">
              <xsl:message select="concat('Error: Unknown referenced class: ', $refClass, ' in mapping: ', $mappedElement)"/>
            </xsl:if>
          </xsl:if>
          <xsl:call-template name="mappedTo"/>
        </associationEnd>
      </xsl:when>
      <xsl:when test="count(ancestor::mif:class//mif:attribute[not(@fixedValue)])=0">
        <attribute>
          <xsl:attribute name="className" select="substring-before($mappedElement, '.')"/>
          <xsl:attribute name="name" select="substring-after($mappedElement, '.')"/>
          <xsl:attribute name="type" select="'BL'"/>
          <xsl:choose>
            <xsl:when test="contains(., '(')">
              <xsl:attribute name="mappingQualifier" select="substring-before(substring-after(., '('), ')')"/>
            </xsl:when>
            <xsl:when test="preceding-sibling::mif:usageNotes">
              <xsl:attribute name="mappingQualifier" select="normalize-space(preceding-sibling::mif:usageNotes)"/>
            </xsl:when>
          </xsl:choose>
          <xsl:call-template name="mappedTo"/>
        </attribute>
      </xsl:when>
      <xsl:otherwise>
        <attribute>
          <xsl:attribute name="className" select="substring-before($mappedElement, '.')"/>
          <xsl:attribute name="name" select="substring-after($mappedElement, '.')"/>
          <xsl:variable name="type">
            <xsl:apply-templates select="ancestor::mif:attribute/mif:type"/>
          </xsl:variable>
          <xsl:attribute name="type" select="$type"/>
          <xsl:choose>
            <xsl:when test="contains(., '(')">
              <xsl:attribute name="mappingQualifier" select="substring-before(substring-after(., '('), ')')"/>
            </xsl:when>
            <xsl:when test="preceding-sibling::mif:usageNotes">
              <xsl:attribute name="mappingQualifier" select="normalize-space(preceding-sibling::mif:usageNotes)"/>
            </xsl:when>
          </xsl:choose>
          <xsl:call-template name="mappedTo"/>
        </attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mif:type|mif:supplierBindingArgumentDatatype">
    <xsl:if test="preceding-sibling::mif:supplierBindingArgumentDatatype">,</xsl:if>
    <xsl:value-of select="@name"/>
    <xsl:if test="mif:supplierBindingArgumentDatatype">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates select="mif:supplierBindingArgumentDatatype"/>
      <xsl:text>&gt;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="mappedTo">
    <xsl:variable name="model">
      <xsl:for-each select="ancestor::mif:staticModel/mif:packageLocation">
        <xsl:value-of select="concat(@subSection, @domain, '_')"/>
        <xsl:choose>
          <xsl:when test="@artifact='DIM'">DM</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring(@artifact,1,2)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="concat(@id, @realm)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:attribute name="rimModel" select="$model"/>
    <xsl:attribute name="rimClass" select="ancestor::mif:class/@name"/>
    <xsl:if test="ancestor::mif:attribute">
      <xsl:attribute name="rimAttribute" select="ancestor::mif:attribute/@name"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
