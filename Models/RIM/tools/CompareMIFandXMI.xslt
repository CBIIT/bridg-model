<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:param name="xmiInfoName"/>
  <xsl:variable name="XMIExtract" select="document($xmiInfoName)/modelElements"/>
  <xsl:variable name="MIFExtract" select="/modelElements"/>
  <xsl:template match="/">
    <xsl:if test="count($XMIExtract/*)=0">
      <xsl:message terminate="yes" select="concat('Unable to find XMI Export file: ', $xmiInfoName)"/>
    </xsl:if>
    <xsl:if test="count($MIFExtract/*)=0">
      <xsl:message terminate="yes" select="'Unable to find MIF Export file'"/>
    </xsl:if>
    <xsl:for-each select="$XMIExtract/class">
      <xsl:if test="count($MIFExtract/class[@name=current()/@name])=0">
        <xsl:choose>
          <xsl:when test="count($MIFExtract/*[@className=current()/@name])=0">
            <xsl:value-of select="concat('Error: No mapping found for class: ', @name, '&#x0A;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('Warning: Mapping found for class elements, but not the class itself: ', @name, '&#x0A;')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$MIFExtract/class">
      <xsl:if test="count($XMIExtract/class[@name=current()/@name])=0">
        <xsl:value-of select="concat('Error: Mapping found for non-existant class: ', @name, '&#x0A;')"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$XMIExtract/attribute">
      <xsl:choose>
        <xsl:when test="count($MIFExtract/attribute[@className=current()/@className and @name=current()/@name])=0">
          <xsl:value-of select="concat('Error: No mapping found for attribute: ', @className, '.', @name, '&#x0A;')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="mifType" select="$MIFExtract/attribute[@className=current()/@className and @name=current()/@name][1]/@type"/>
          <xsl:variable name="umlType">
            <xsl:choose>
              <xsl:when test="contains(@type, 'EN.')">
                <xsl:value-of select="concat(substring-before(@type, 'EN.'),substring-after(@type, 'EN.'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@type"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="count($MIFExtract/attribute[@className=current()/@className and @name=current()/@name])&gt;1">
              <xsl:value-of select="concat('Warning: Attribute ', @className, '.', @name, ' exists in the MIF with multiple datatypes: ')"/>
              <xsl:for-each select="$MIFExtract/attribute[@className=current()/@className and @name=current()/@name]">
                <xsl:if test="position()&gt;1">, </xsl:if>
                <xsl:value-of select="@type"/>
              </xsl:for-each>
              <xsl:text>&#x0A;</xsl:text>
            </xsl:when>
            <xsl:when test="$umlType!=$mifType and not($umlType='CD' and ($mifType='CS' or $mifType='HXIT&lt;CS&gt;')) and not($umlType='INT' and $mifType='INT.NONNEG')">
              <xsl:variable name="qualifier" select="$MIFExtract/attribute[@className=current()/@className and @name=current()/@name]/@mappingQualifier"/>
              <xsl:choose>
                <xsl:when test="$qualifier!=''">
                  <xsl:value-of select="concat('Warning: Type differs for attribute ', @className, '.', @name, '.  UML:', @type, ' MIF:', $mifType, ' (Qualifier: ', $qualifier, ')&#x0A;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('Error: Type differs for attribute and no qualifier specified ', @className, '.', @name, '.  UML:', @type, ' MIF:', $mifType, '&#x0A;')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="$MIFExtract/attribute">
      <xsl:if test="count($XMIExtract/attribute[@className=current()/@className and @name=current()/@name])=0">
        <xsl:choose>
          <xsl:when test="count($XMIExtract/class[@name=current()/@className])=0">
            <xsl:value-of select="concat('Error: Mapping found for attribute with non-existing class: ', @className, '.', @name, '&#x0A;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('Error: Mapping found for non-existant attribute: ', @className, '.', @name, '&#x0A;')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$XMIExtract/associationEnd">
      <xsl:if test="count($MIFExtract/associationEnd[@className=current()/@className and @name=current()/@name and @targetClass=current()/@targetClass])=0">
        <xsl:value-of select="concat('Error: No mapping found for association end: ', @className, '.', @name, '[', @targetClass, ']&#x0A;')"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$MIFExtract/associationEnd">
      <xsl:if test="count($XMIExtract/associationEnd[@className=current()/@className and @name=current()/@name and @targetClass=current()/@targetClass])=0">
        <xsl:value-of select="concat('Error: Mapping found for non-existant association end: ', @className, '.', @name, '[', @targetClass, ']&#x0A;')"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
