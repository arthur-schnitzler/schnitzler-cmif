<?xml version="1.0" encoding="utf-8"?>
<!--
    XSLT zur Extraktion von Schnitzler-Korrespondenz ohne Dubletten

    Zweck:
    Dieses Stylesheet durchsucht alle CMIF-XML-Dateien im Repository (Pattern: ????_*.xml)
    und extrahiert nur jene correspDesc-Einträge, die Schnitzler (GND: 118609807) als
    Sender oder Empfänger enthalten UND die nicht als Dublette markiert sind.

    Funktionsweise:
    1. Sammelt mit collection() alle XML-Dateien aus dem Parent-Verzeichnis
    2. Filtert nach Dateien, die Schnitzler-Referenzen enthalten
    3. Extrahiert nur correspDesc ohne @sameAs-Attribut (d.h. keine Dubletten)
    4. Sammelt alle zugehörigen Quellenbeschreibungen (bibl-Elemente)
    5. Erstellt eine konsolidierte TEI-Datei mit deduplizierter Korrespondenz

    Output:
    Eine TEI-Datei mit neuem teiHeader (Titel: "Publizierte Briefe von und an Arthur
    Schnitzler (ohne Dubletten)"), allen relevanten Quellenangaben in sourceDesc/listBibl
    und allen nicht-duplizierten correspDesc-Einträgen in profileDesc.

    Hinweis:
    Das @sameAs-Attribut wird in den Quelldateien verwendet, um mehrfache Editionen
    desselben Briefs zu kennzeichnen. Diese Transformation behält nur die primäre
    Version (ohne @sameAs).
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0" exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:template match="/">
        <xsl:apply-templates mode="rootcopy"/>
    </xsl:template>
    <xsl:template match="node()" mode="rootcopy">
        <xsl:variable name="folderURI" select="resolve-uri('.', base-uri())"/>
        <xsl:copy>
            <xsl:element name="teiHeader" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fileDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="titleStmt" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0"
                            >Publizierte Briefe von und an Arthur Schnitzler (ohne
                            Dubletten)</xsl:element>
                    </xsl:element>
                    <xsl:element name="publicationStmt" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="publisher" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="target">
                                    <xsl:text>https://schnitzler-briefe.acdh.oeaw.ac.at/</xsl:text>
                                </xsl:attribute>
                                <xsl:text>Martin Anton
                                Müller</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="availability" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="licence" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="target">
                                    <xsl:text>https://creativecommons.org/publicdomain/zero/1.0/</xsl:text>
                                </xsl:attribute>
                                <xsl:text>CC0</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="when">
                                <xsl:value-of select="fn:current-date()"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:text>url</xsl:text>
                            </xsl:attribute>
                            <xsl:text>https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-cmif/schnitzler-ohne-dubletten/schnitzler-ohne-dubletten.xml</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="sourceDesc" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                            
                            <xsl:for-each
                                select="collection(concat($folderURI, '../../?select=????_*.xml;recurse=yes'))/tei:TEI[descendant::tei:persName/@ref = 'https://d-nb.info/gnd/118609807']/tei:teiHeader[1]/tei:fileDesc[1]/tei:sourceDesc[1]/tei:bibl">
                                
                                <xsl:copy-of select="." copy-namespaces="no"/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="profileDesc">
                    <xsl:for-each
                        select="collection(concat($folderURI, '../?select=????_*.xml;recurse=yes'))/tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc[not(@sameAs) and descendant::tei:persName/@ref = 'https://d-nb.info/gnd/118609807']">
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0"> </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*">
        <xsl:element name="TEI">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="noNamespaceSchemaLocation"
                namespace="http://www.w3.org/2001/XMLSchema-instance">your-value</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
