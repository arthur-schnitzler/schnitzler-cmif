<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="whatever"
    version="3.0"
    exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!--  -->
    
    <xsl:template match="tei:placeName/@ref">
        <xsl:attribute name="ref">
        <xsl:variable name="string-ohne-html" as="xs:string">
            <xsl:choose>
                <xsl:when test="ends-with(.,'.html')">
                    <xsl:value-of select="tokenize(., '/')[last() -1]"/>
                </xsl:when>
                <xsl:when test="ends-with(.,'/')">
                    <xsl:value-of select="tokenize(., '/')[last() -1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize(., '/')[last()]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>    
            <xsl:value-of select="concat('https://sws.geonames.org/', $string-ohne-html, '/')"/>
        </xsl:attribute>
        <xsl:attribute name="old">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    
</xsl:stylesheet>
