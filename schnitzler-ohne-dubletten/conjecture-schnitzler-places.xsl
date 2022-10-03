<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="hwatever"
    version="3.0"
    exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:param name="places"
        select="document('/Users/oldfiche/Documents/git/schnitzler-orte/editions/schnitzler_places.xml')"/>
    <xsl:key name="place-lookup" match="tei:event" use="@when"/>
    
    
    <xsl:template match="tei:correspAction[@type='received' and tei:persName/@ref='https://d-nb.info/gnd/118609807' and not(tei:placeName)]">
        <xsl:variable name="sendedatum" as="xs:date?">
            <xsl:variable name="treffer" select="parent::tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when"/>
            <xsl:choose>
                <xsl:when test="xs:date($treffer) = $treffer">
                    <xsl:value-of select="$treffer"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:text>received</xsl:text>
            </xsl:attribute>
            <xsl:copy-of select="tei:persName"/>
            <xsl:choose>
                <xsl:when test="empty($sendedatum)"/><!-- wenn nur ungenaues sendedatum ist der erhaltsort nicht zu bestimmen -->
                <xsl:when test="key('place-lookup', string($sendedatum), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                    <xsl:variable name="eintrag" select="key('place-lookup', string($sendedatum), $places)//tei:listPlace[1]" as="node()"/>
                    <xsl:if test="key('place-lookup', string($sendedatum  + xs:dayTimeDuration('P1D')), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                        <xsl:if test="key('place-lookup', string($sendedatum  + xs:dayTimeDuration('P2D')), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                            <xsl:if test="key('place-lookup', string($sendedatum  + xs:dayTimeDuration('P3D')), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                                <xsl:if test="key('place-lookup', string($sendedatum  + xs:dayTimeDuration('P4D')), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                                    <xsl:if test="key('place-lookup', string($sendedatum  + xs:dayTimeDuration('P5D')), $places)//tei:place[1]/tei:idno[@type='pmb'][1]='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                                        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="evidence">
                                                <xsl:text>connijure</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="ref">
                                                <xsl:value-of select="$eintrag//tei:place[tei:idno ='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail']/tei:idno[@type='geonames']"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$eintrag//tei:place[tei:idno ='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail']/tei:placeName"/>
                                        </xsl:element>
                                    </xsl:if></xsl:if></xsl:if></xsl:if>
                    </xsl:if>
                    
                </xsl:when>
            </xsl:choose>
            
        </xsl:element>
        
        
    </xsl:template>
    
    <xsl:function name="foo:ortlookup" as="xs:boolean">
        <xsl:param name="pmb-ort" as="xs:string"/>
        <xsl:param name="datum" as="xs:date"/>
        <xsl:choose>
            <xsl:when test="key('place-lookup', $datum + xs:dayTimeDuration('P1D'), $places)/descendant::tei:idno[@type='pmb'] = concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/',$pmb-ort, '/detail')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:fuenfmal" as="xs:string?">
        <xsl:param name="pmb-ort" as="xs:string"/>
        <xsl:param name="datum" as="xs:date"/>
        <xsl:param name="fuenf-tage-weiter-datum" as="xs:date"/>
        <xsl:choose>
            <xsl:when test="key('place-lookup', $datum + xs:dayTimeDuration('P1D'), $places)/descendant::tei:idno[@type='pmb'] = $pmb-ort">
                <xsl:text>SEX</xsl:text>
                <xsl:if test="key('place-lookup', $datum + xs:dayTimeDuration('P2D'), $places)/descendant::tei:idno[@type='pmb'] = $pmb-ort">
                    <xsl:text>S2X</xsl:text>
                    <xsl:if test="key('place-lookup', $datum + xs:dayTimeDuration('P3D'), $places)/descendant::tei:idno[@type='pmb'] = $pmb-ort">
                        <xsl:text>S3X</xsl:text>
                        <xsl:if test="key('place-lookup', $datum + xs:dayTimeDuration('P4D'), $places)/descendant::tei:idno[@type='pmb'] = $pmb-ort">
                            <xsl:text>S4X</xsl:text>
                            <xsl:value-of select="$pmb-ort"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
                <xsl:value-of select="$pmb-ort"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
        
        <!--<xsl:choose>
            <xsl:when test="$datum = $fuenf-tage-weiter-datum">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="key('place-lookup', $datum + xs:dayTimeDuration('P1D'), $places)/descendant::tei:idno[@type='pmb'] = concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/',$pmb-ort, '/detail')">
                <xsl:value-of select="foo:fuenfmal($pmb-ort, $datum + xs:dayTimeDuration('P1D'), $fuenf-tage-weiter-datum)"/>
            
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:function>
</xsl:stylesheet>
