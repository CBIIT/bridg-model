<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="attribute/documentation/@value|connector/documentation/@value|element[@xmi:type='uml:Class']/properties/@documentation">
    <xsl:attribute name="{name(.)}">
      <xsl:value-of select="."/>
      <xsl:text>&#x0A;&#x0A;DEFINITION:&#x0A;&#x0A;EXAMPLE(S):&#x0A;&#x0A;OTHER NAME(S):&#x0A;&#x0A;NOTE(S):&#x0A;</xsl:text>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
