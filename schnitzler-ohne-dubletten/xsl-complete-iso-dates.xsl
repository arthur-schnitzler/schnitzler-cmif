<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="https://www.oreilly.com/library/view/xslt-cookbook/0596003722/ch03s03.html"
    version="3.0"
    exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:template match="tei:correspAction/tei:date/@when[string-length(.) &lt; 8]">
        <xsl:choose>
            <xsl:when test="string-length(.)=4">
                <xsl:attribute name="notBefore">
                    <xsl:value-of select="concat(., '-01-01')"/>
                </xsl:attribute>
                <xsl:attribute name="notAfter">
                    <xsl:value-of select="concat(., '-12-31')"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="string-length(.)=7">
                <xsl:attribute name="notBefore">
                    <xsl:value-of select="concat(., '-01')"/>
                </xsl:attribute>
                <xsl:attribute name="notAfter">
                    <xsl:value-of select="concat(., '-', foo:last-day-of-month(fn:number(substring-before(.,'-')), fn:number(substring-after(.,'-'))))"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="fishy">
                <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template> 
  
    <xsl:function name="foo:last-day-of-month">
        <xsl:param name="year" as="xs:double"/>
        <xsl:param name="month" as="xs:double"/>
        <xsl:choose>
            <xsl:when test="$month = 2 and 
                not($year mod 4) and 
                ($year mod 100 or not($year mod 400))">
                <xsl:value-of select="29"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of 
                    select="substring('312831303130313130313031',
                    2 * $month - 1,2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
  
</xsl:stylesheet>
