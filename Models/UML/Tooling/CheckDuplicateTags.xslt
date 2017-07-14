<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <xsl:if test="not(xmi:XMI/@xmi:version='2.1')">
      <xsl:message terminate="yes" select="'This transform only works on XMI 2.1 files'"/>
    </xsl:if>
    <xsl:for-each select="//tags/tag">
      <xsl:if test="exists(preceding-sibling::tag[@name=current()/@name and @value=current()/@value])">
        <xsl:text>Duplicate tag in </xsl:text>
        <xsl:for-each select="parent::tags/parent::*">
          <xsl:choose>
            <xsl:when test="self::element[@xmi:type='uml:Package']">
              <xsl:value-of select="concat('Package: ', @name)"/>
            </xsl:when>
            <xsl:when test="self::element[@xmi:type='uml:Class']">
              <xsl:value-of select="concat('Class: ', @name)"/>
            </xsl:when>
            <xsl:when test="self::attribute">
              <xsl:value-of select="concat('Attribute: ', parent::attributes/parent::element/@name, '.', @name)"/>
            </xsl:when>
            <xsl:when test="self::connector">
              <xsl:value-of select="concat('Association: ', source/model/@name, '.', source/role/@name)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        <xsl:value-of select="concat(' - tagName=&quot;', @name, '&quot; tagValue=&quot;', @value, '&quot;&#x0a;')"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
