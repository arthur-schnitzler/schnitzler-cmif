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
    
    <!-- Dieses XSLT ergänzt den jeweiligen Aufenthaltsort Schnitzlers zu correspAction -->
    
    <xsl:template match="tei:correspAction[tei:persName[@ref='https://d-nb.info/gnd/118609807' or @ref='#pmb2121'] and not(tei:placeName) and tei:date]">
        <xsl:variable name="sendedatum" as="xs:date?">
            <xsl:variable name="treffer" select="tei:date/@when"/>
            <xsl:choose>
                <xsl:when test="xs:date($treffer) = $treffer">
                    <xsl:value-of select="$treffer"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="aufenthaltsort-am-sendedatum" as="node()?">
            <xsl:choose>
                <xsl:when test="key('place-lookup', string($sendedatum), $places)/descendant::tei:listPlace">
                    <xsl:variable name="list-orte" select="key('place-lookup', string($sendedatum), $places)/descendant::tei:listPlace" as="node()"/>
                    <!-- Wenn er sich im Vortag und am Folgetag am selben Ort aufhält, ist das der Ort, den wir suchen -->
                    <xsl:variable name="list-orte-vortag" select="key('place-lookup', string($sendedatum - xs:dayTimeDuration('P1D')), $places)/descendant::tei:listPlace" as="node()"/>
                    <xsl:variable name="list-orte-folgetag" select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P1D')), $places)/descendant::tei:listPlace" as="node()"/>
                    <xsl:variable name="schnittmenge-vortag-folgetag" as="node()?">
                        <xsl:for-each select="$list-orte/tei:idno[@type='geonames']">
                            <xsl:if test=". = $list-orte-vortag//tei:idno[@type='geonames'] and . = $list-orte-folgetag//tei:idno[@type='geonames']">
                                <xsl:copy-of select="$list-orte[. = tei:idno[@type='geonames']]"></xsl:copy-of>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <!-- Wenn er sich in Wien aufhält, sind die anderen listPlace egal: -->
                        <xsl:when test="$list-orte/tei:place/tei:idno = 'https://sws.geonames.org/2761369/' or $list-orte/tei:place/tei:idno = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail'">
                            <xsl:copy-of select="$list-orte/tei:place[tei:idno = 'https://sws.geonames.org/2761369/' or tei:idno = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail']"></xsl:copy-of>
                        </xsl:when>
                        <!-- Nur ein Aufenthaltsort: passt auch -->
                        <xsl:when test="$list-orte/tei:place and not($list-orte/tei:place[2])">
                            <xsl:copy-of select="$list-orte/tei:place"></xsl:copy-of>
                        </xsl:when>
                        <!-- Wenn es Schnittmenge gibt -->
                        <xsl:when test="$schnittmenge-vortag-folgetag/child::*">
                            <xsl:copy-of select="$schnittmenge-vortag-folgetag"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:copy-of select="*"/>
            <xsl:choose>
                <xsl:when test="empty($sendedatum)"/><!-- wenn nur ungenaues sendedatum ist der erhaltsort nicht zu bestimmen -->
                <xsl:when test="$aufenthaltsort-am-sendedatum[tei:idno = 'https://sws.geonames.org/2761369/' or tei:idno = 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/50/detail']">
                    <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="evidence">
                            <xsl:text>conjecture</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="ref">
                            <xsl:choose><!-- sind's mehr als ein correspDesc, ist es eine CMIF-Datei, also geonames-Werte -->
                                <xsl:when test="ancestor::tei:profileDesc/tei:correspDesc[2]">
                                    <xsl:value-of select="$aufenthaltsort-am-sendedatum/tei:idno[@type='geonames']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="pmb-wert" select="substring-after(substring-before($aufenthaltsort-am-sendedatum/tei:idno[@type='pmb'][1],'/detail'), 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/')"/>
                                    <xsl:value-of select="concat('#pmb', $pmb-wert)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$aufenthaltsort-am-sendedatum/tei:placeName"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$aufenthaltsort-am-sendedatum/child::*">
                    <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="evidence">
                            <xsl:text>conjecture</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="ref">
                            <xsl:choose><!-- sind's mehr als ein correspDesc, ist es eine CMIF-Datei, also geonames-Werte -->
                                <xsl:when test="ancestor::tei:profileDesc/tei:correspDesc[2]">
                                    <xsl:value-of select="$aufenthaltsort-am-sendedatum/tei:idno[@type='geonames']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="pmb-wert" select="substring-after(substring-before($aufenthaltsort-am-sendedatum/tei:idno[@type='pmb'][1],'/detail'), 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/')"/>
                                    <xsl:value-of select="concat('#pmb', $pmb-wert)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$aufenthaltsort-am-sendedatum/tei:placeName"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose></xsl:element>
    </xsl:template>
    
    <!-- von Schnitzler, aber ohne datum: also ein Zeitraum von 5 Tagen ab Absendedatum -->
    <xsl:template match="tei:correspAction[tei:persName[@ref='https://d-nb.info/gnd/118609807' or @ref='#pmb2121'] and not(tei:placeName) and not(tei:date)]">
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
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:copy-of select="tei:persName"/>
            <xsl:choose>
                <xsl:when test="empty($sendedatum)"/><!-- wenn nur ungenaues sendedatum ist der erhaltsort nicht zu bestimmen -->
                <xsl:when test="key('place-lookup', string($sendedatum), $places)//tei:listPlace[1]">
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
                                    <xsl:choose><!-- sind's mehr als ein correspDesc, ist es eine CMIF-Datei, also geonames-Werte -->
                                        <xsl:when test="ancestor::tei:profileDesc/tei:correspDesc[2]">
                                            <xsl:value-of select="$eintrag/tei:place[tei:idno[@type='pmb'] = $aktuell]/tei:idno[@type='geonames']"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="pmb-wert" select="substring-after(substring-before($eintrag/tei:place/tei:idno[@type='pmb' and . = $aktuell][1],'/detail'), 'https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/')"/>
                                            <xsl:value-of select="concat('#pmb', $pmb-wert)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
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