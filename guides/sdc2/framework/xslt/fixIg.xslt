<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Strip off schema declaration and unofficial extension
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsi xs f">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@xsi:schemaLocation|f:extension[@url=('http://hl7.org/fhir/tools-profile-spreadsheet')]"/>
  <xsl:template match="f:resource[f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-spreadsheet-profile' and f:valueBoolean/@value=true()]]"/>
  <xsl:template match="f:package">
    <xsl:if test="f:resource[not(f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-spreadsheet-profile' and f:valueBoolean/@value=true()])]">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="f:page[f:source/@value='artifacts.html']">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="f:name">name</xsl:when>
        <xsl:otherwise>title</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()[not(self::f:page)]"/>
      <xsl:if test="not(f:page[f:format/@value='generated'])">
        <xsl:copy-of select="f:page"/>
        <xsl:for-each select="ancestor::f:ImplementationGuide/f:package/f:resource">
          <page>
            <xsl:variable name="type" select="substring-before(f:sourceReference/f:reference/@value, '/')"/>
            <xsl:variable name="id" select="substring-after(f:sourceReference/f:reference/@value, '/')"/>
            <xsl:variable name="value">
              <xsl:choose>
                <xsl:when test="starts-with($id, 'ext-')">
                  <xsl:value-of select="concat('extension-', $id, '.html')"/>
                </xsl:when>
                <xsl:when test="$type='ValueSet' and not(f:example/@value='true' or f:purpose/@value='example')">
                  <xsl:value-of select="concat('valueset-', $id, '.html')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($id, '.html')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <source value="{$value}"/>
            <xsl:element name="{$name}" namespace="http://hl7.org/fhir">
              <xsl:attribute name="value">
                <xsl:value-of select="f:name/@value"/>
              </xsl:attribute>
            </xsl:element>
            <xsl:variable name="kind">
              <xsl:choose>
                <xsl:when test="$type='Conformance' or $type='SearchParameter' or contains($id, 'example')">example</xsl:when>
                <xsl:otherwise>resource</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <kind value="{$kind}"/>
            <xsl:choose>
              <xsl:when test="$type='Conformance' or $type='SearchParameter'">
                <format value="generated-resource"/>
              </xsl:when>
              <xsl:otherwise>
                <format value="generated"/>
              </xsl:otherwise>
            </xsl:choose>
          </page>
        </xsl:for-each>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  
</xsl:stylesheet>
