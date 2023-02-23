<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:xi="http://www.w3.org/2001/XInclude">
    
    <!-- This SCHEMATRON checks the teiHeader information before the text is ready for the web application. -->
    
    <ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
    
    <pattern id="editors">
        <rule context="tei:teiHeader//tei:titleStmt//tei:editor">
            <assert test="@role = ('#scholarly', '#technical', '#technical #scholarly', '#scholarly #technical','#additional')">
                Editors must have @role #scholarly, #technical, #additional and be sorted by importance/extent of processing.
            </assert>
        </rule>
    </pattern>
    <pattern id="editionStmt">
        <rule context="tei:editionStmt/tei:edition">
            <assert test="not(@n eq 'unpublished')">
                editionStmt should have a publication date. See e.g. in comments.
                <!--For main text z. B. W0001 multivolume "summaryDigitizedEd" when="YYYY" YYYY (SvsalVol.x-SvsalVol.x).
                For specific Vol.x z. B. W0001_Vol01 type="digitizedEd" when="YYYY-MM-DD">YYYY-MM-DD-->
            </assert>            
        </rule>
    </pattern>
    <pattern id="publicationStmt">
        <rule context="tei:publicationStmt/tei:date">
            <assert test="not(@n eq 'unpublished')">
                publicationStmt should have a publication date. See e.g. in comments.
                <!--main text z. B. W0001 multivolume date type="summaryDigitizedEd" when="YYYY">YYYY (SvsalVol.x).
                    For specific Vol.x z. B. W0001_Vol01 type="digitizedEd" when="YYYY-MM-DD">YYYY-MM-DD-->
            </assert>
        </rule>
        <rule context="tei:publicationStmt/tei:idno">
            <assert test="child::tei:idno">
                idno in publicationStmt should have several urls.
            </assert>
        </rule>
    </pattern>
    <pattern id="seriesStmt">
        <rule context="tei:seriesStmt/tei:biblScope">
            <assert test="not(@n eq 'unpublished')">
                seriesStmt should have "biblScope unit="volume" n="SvsalVolx" Volume xx.
            </assert>
        </rule>
    </pattern>
    <pattern id="encodingDesc">
        <rule context="tei:encodingDesc">
            <assert test="not(xi:include)">
                encodingDesc should have "xi:includes"s.
            </assert>
        </rule>
    </pattern>
    <pattern id="revisionDesc">
        <rule context="tei:revisionDesc">
            <assert test="not(@status eq 'a_raw')">
                revisionDesc should be updated to 'g_enriched_approved'.
            </assert>
        </rule>
    </pattern>
    
</schema>