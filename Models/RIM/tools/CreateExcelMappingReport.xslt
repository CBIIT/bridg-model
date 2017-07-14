<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:template match="modelElements">
    <xsl:text>BRIDG Element Type, BRIDG Element Name, RIM-based model, RIM-based model element, comments&#x0A;</xsl:text>
    <xsl:for-each select="class">
      <xsl:sort select="@name"/>
      <xsl:sort select="@rimModel"/>
      <xsl:sort select="@rimClass"/>
      <xsl:value-of select="concat('Class,', @name, ',', @rimModel, ',', @rimClass, '&#x0A;')"/>
      <xsl:for-each select="/modelElements/attribute[@className=current()/@name]">
        <xsl:sort select="@name"/>
        <xsl:sort select="@rimModel"/>
        <xsl:sort select="@rimClass"/>
        <xsl:sort select="@rimAttribute"/>
        <xsl:value-of select="concat('Attribute,', @className, '.', @name, ',', @rimModel, ',', @rimClass, '.', @rimAttribute, ',&quot;', @mappingQualifier, '&quot;&#x0A;')"/>
      </xsl:for-each>
      <xsl:for-each select="/modelElements/associationEnd[@className=current()/@name]">
        <xsl:sort select="@name"/>
        <xsl:sort select="@targetClass"/>
        <xsl:sort select="@rimModel"/>
        <xsl:sort select="@rimClass"/>
        <xsl:value-of select="concat('Association,', @className, '.', @name, '.', @targetClass, ',', @rimModel, ',', @rimClass, '&#x0A;')"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
