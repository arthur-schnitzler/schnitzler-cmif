<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0"
    xmlns:mam="whatever">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das holt die GND-Nummer aus der PMB -->
    <!-- Parameter können von außen übergeben werden, Fallback auf Remote-URLs -->
    <xsl:param name="listperson" as="xs:string"
        select="'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listperson.xml'"/>
    <xsl:param name="listplace" as="xs:string"
        select="'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listplace.xml'"/>
    <xsl:param name="listevent" as="xs:string"
        select="'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listevent.xml'"/>
    <xsl:param name="listbibl" as="xs:string"
        select="'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listbibl.xml'"/>
    <xsl:param name="listorg" as="xs:string"
        select="'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listorg.xml'"/>
    <xsl:variable name="listperson-doc" select="document($listperson)"/>
    <xsl:variable name="listplace-doc" select="document($listplace)"/>
    <xsl:variable name="listorg-doc" select="document($listorg)"/>
    <xsl:variable name="listevent-doc" select="document($listevent)"/>
    <xsl:variable name="listbibl-doc" select="document($listbibl)"/>
    <xsl:key name="person-match" match="//tei:text[1]/tei:body[1]/tei:listPerson[1]/tei:person"
        use="@xml:id"/>
    <xsl:key name="place-match" match="//tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place"
        use="@xml:id"/>
    <xsl:key name="org-match" match="//tei:text[1]/tei:body[1]/tei:listOrg[1]/tei:org"
        use="@xml:id"/>
    <xsl:key name="event-match" match="//tei:text[1]/tei:body[1]/tei:listEvent[1]/tei:event"
        use="@xml:id"/>
    <xsl:key name="bibl-match" match="//tei:text[1]/tei:body[1]/tei:listBibl[1]/tei:bibl"
        use="@xml:id"/>
    <!-- Helper function: Extrahiert PMB-Nummer aus ref -->
    <xsl:function name="mam:extract-pmb-number" as="xs:string">
        <xsl:param name="ref" as="xs:string"/>
        <xsl:sequence select="replace(replace(replace($ref, '#', ''), 'pmb', ''), '/', '')"/>
    </xsl:function>

    <!-- Helper function: Sucht Normdaten in lokalen Listen oder PMB-API -->
    <xsl:function name="mam:resolve-authority" as="xs:string">
        <xsl:param name="nummeri" as="xs:string"/>
        <xsl:param name="entity-type" as="xs:string"/>
        <xsl:param name="key-name" as="xs:string"/>
        <xsl:param name="list-doc" as="document-node()?"/>
        <xsl:param name="preferred-idno-types" as="xs:string*"/>

        <xsl:variable name="pmb-key" select="concat('pmb', $nummeri)"/>
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/', $entity-type, '/', $nummeri))"
            as="xs:string"/>

        <xsl:choose>
            <!-- Prüfe lokale Liste auf bevorzugte Normdatentypen -->
            <xsl:when test="$list-doc">
                <xsl:variable name="match" select="key($key-name, $pmb-key, $list-doc)"/>
                <xsl:variable name="found-idno" select="
                    for $type in $preferred-idno-types
                    return $match/tei:idno[@type = $type or @subtype = $type][1]"/>
                <xsl:choose>
                    <xsl:when test="$found-idno[1]">
                        <xsl:sequence select="string($found-idno[1])"/>
                    </xsl:when>
                    <!-- Falls Lokal nicht gefunden, versuche PMB-API -->
                    <xsl:when test="doc-available($eintragi)">
                        <xsl:variable name="api-idno" select="
                            for $type in $preferred-idno-types
                            return document($eintragi)/descendant::*:idno[@subtype = $type][1]"/>
                        <xsl:choose>
                            <xsl:when test="$api-idno[1]">
                                <xsl:sequence select="string($api-idno[1])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Fallback ohne lokale Liste -->
            <xsl:when test="doc-available($eintragi)">
                <xsl:variable name="api-idno" select="
                    for $type in $preferred-idno-types
                    return document($eintragi)/descendant::*:idno[@subtype = $type][1]"/>
                <xsl:choose>
                    <xsl:when test="$api-idno[1]">
                        <xsl:sequence select="string($api-idno[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Personen: Holt GND oder Wikidata aus PMB -->
    <xsl:template
        match="tei:persName/@ref[contains(., 'pmb')] | tei:rs[@type = 'person']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="$nummeri = '2121'">
                    <xsl:text>https://d-nb.info/gnd/118609807</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="mam:resolve-authority($nummeri, 'person', 'person-match', $listperson-doc, ('gnd', 'wikidata'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- Orte: Holt Geonames, GND oder Wikidata aus PMB -->
    <xsl:template
        match="tei:placeName/@ref[contains(., 'pmb')] | tei:rs[@type = 'place']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="$nummeri = '50'">
                    <xsl:text>https://sws.geonames.org/2761369/</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="mam:resolve-authority($nummeri, 'place', 'place-match', $listplace-doc, ('geonames', 'gnd', 'wikidata'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- Events: Holt GND oder Wikidata aus PMB -->
    <xsl:template
        match="tei:eventName/@ref[contains(., 'pmb')] | tei:rs[@type = 'event']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:attribute name="ref">
            <xsl:value-of select="mam:resolve-authority($nummeri, 'event', 'event-match', $listevent-doc, ('gnd', 'wikidata'))"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Organisationen: Holt GND oder Wikidata aus PMB -->
    <xsl:template
        match="tei:orgName/@ref[contains(., 'pmb')] | tei:rs[@type = 'org']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:attribute name="ref">
            <xsl:value-of select="mam:resolve-authority($nummeri, 'org', 'org-match', $listorg-doc, ('gnd', 'wikidata'))"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Bibliografische Einträge: Holt GND oder Wikidata aus PMB -->
    <xsl:template
        match="tei:biblName/@ref[contains(., 'pmb')] | tei:rs[@type = 'work']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:attribute name="ref">
            <xsl:value-of select="mam:resolve-authority($nummeri, 'bibl', 'bibl-match', $listbibl-doc, ('gnd', 'wikidata'))"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Generisches Template für ref/@target basierend auf @type -->
    <xsl:template match="tei:ref/@target[contains(., 'pmb')]">
        <xsl:variable name="nummeri" select="mam:extract-pmb-number(.)"/>
        <xsl:variable name="type" select="parent::tei:ref/@type"/>

        <xsl:attribute name="target">
            <xsl:choose>
                <!-- mentionsPerson -->
                <xsl:when test="contains($type, 'mentionsPerson')">
                    <xsl:choose>
                        <xsl:when test="$nummeri = '2121'">
                            <xsl:text>https://d-nb.info/gnd/118609807</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mam:resolve-authority($nummeri, 'person', 'person-match', $listperson-doc, ('gnd', 'wikidata'))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

                <!-- mentionsPlace -->
                <xsl:when test="contains($type, 'mentionsPlace')">
                    <xsl:choose>
                        <xsl:when test="$nummeri = '50'">
                            <xsl:text>https://sws.geonames.org/2761369/</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mam:resolve-authority($nummeri, 'place', 'place-match', $listplace-doc, ('geonames', 'gnd', 'wikidata'))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

                <!-- mentionsBibl -->
                <xsl:when test="contains($type, 'mentionsBibl')">
                    <xsl:value-of select="mam:resolve-authority($nummeri, 'bibl', 'bibl-match', $listbibl-doc, ('gnd', 'wikidata'))"/>
                </xsl:when>

                <!-- mentionsOrg -->
                <xsl:when test="contains($type, 'mentionsOrg')">
                    <xsl:value-of select="mam:resolve-authority($nummeri, 'org', 'org-match', $listorg-doc, ('gnd', 'wikidata'))"/>
                </xsl:when>

                <!-- mentionsEvent -->
                <xsl:when test="contains($type, 'mentionsEvent')">
                    <xsl:value-of select="mam:resolve-authority($nummeri, 'event', 'event-match', $listevent-doc, ('gnd', 'wikidata'))"/>
                </xsl:when>

                <!-- Fallback: Ursprünglicher Wert -->
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:correspContext"/>
    
    <xsl:template match="@doppelter-tag"/>
</xsl:stylesheet>
