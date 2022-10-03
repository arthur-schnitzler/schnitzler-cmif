<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="hwatever"
    version="3.0"
    exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
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
        <xsl:variable name="aufenthaltsort-am-sendedatum" as="xs:string?">
            <xsl:choose>
                <xsl:when test="key('place-lookup', string($sendedatum), $places)//tei:place/tei:idno[@type='pmb' and .='https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail']">
                    <xsl:text>50</xsl:text><!-- Wien -->
                </xsl:when>
                <xsl:when test="key('place-lookup', string($sendedatum), $places)//tei:place/tei:idno[@type='pmb']">
                    <xsl:value-of select="substring-before(substring-after(.,'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/'), '/detail')"/>
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
                    <xsl:variable name="eintrag1" select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P1D')), $places)//tei:listPlace[1]" as="node()"/>
                    <xsl:variable name="eintrag2" select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P2D')), $places)//tei:listPlace[1]" as="node()"/>
                    <xsl:variable name="eintrag3" select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P3D')), $places)//tei:listPlace[1]" as="node()"/>
                    <xsl:variable name="eintrag4" select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P4D')), $places)//tei:listPlace[1]" as="node()"/>
                    <xsl:for-each select="$eintrag/tei:place[tei:idno[@type='geonames']!= '' and tei:idno[@type='geonames']]/tei:idno[@type='pmb']">
                        <xsl:if test=". = $eintrag1/tei:place/tei:idno[@type='pmb'] and . = $eintrag2/tei:place/tei:idno[@type='pmb'] and . = $eintrag3/tei:place/tei:idno[@type='pmb'] and . = $eintrag4/tei:place/tei:idno[@type='pmb']">
                            <xsl:variable name="aktuell" select="." as="xs:string"/>
                            <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="evidence">
                                    <xsl:text>conjecture</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="ref">
                                    <xsl:value-of select="$eintrag/tei:place[tei:idno[@type='pmb'] = $aktuell]/tei:idno[@type='geonames']"/>
                                </xsl:attribute>
                                <xsl:if test="$eintrag/tei:place[tei:idno =$aktuell]/tei:placeName != 'Wien'"><xsl:attribute name="check"/></xsl:if><xsl:value-of select="$eintrag/tei:place[tei:idno =$aktuell]/tei:placeName"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
