<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="'WXXXX_VolXX_change_XXX'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added (la) abbreviations depending on word structure with regex.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status"/>
                <xsl:attribute name="xml:id" select="$changeId"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
<!-- 
     ##########
    | READ ME: |
     ##########
    
    See: https://github.com/CindyRicoCarmona/Expand_abbreviations_with_regex
    
    Expanding Latin abbreviations depending on their word structure. For example, a combination of a special characters and their sufixes or morphemes.
    
    REQUIREMENTS:
    
    * This program is only to be used in TEI-tite texts before the TEI-Transformation and special character annotation are done,
    otherwise it won't work.
    
    * Missing/innecesary white spaces may generate false positves, since some words are sometimes transcribed together with other words.
    
    * not(ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')]) was added, in case other languages appear e.g. in marginal notes, or front/back.
      When the text has a clear division from languages, for example, Main text spanish and marginal notes latin or viceversa, the templates should be adjusted.
      This ensures that one works with the right part of the text. 
      For main Text:
      text()[not(ancestor::tei:note or ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]
      For marginal text:
      text()[ancestor::tei:note and not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]
    
    * Abbreviations will be annotated as:
    
    <abbr rend="choice" resp="#auto"><abbr rend="abbr">...</abbr><abbr rend="expan" resp="#CR #auto">...</abbr></abbr>
    
    In the TEI-tite to TEI-All transformation, they will be later automatically converted into:
    
    <choice resp="#auto"><abbr>...</abbr><expan resp="#CR #auto">...</expan></choice>
    
    Special character tagging will be done in a further stage of the pipeline. 
    
    * Tilde and Macron characters are taken into account. It means every case has all possible ocurrencies e.g ẽ|ẽ|ē
    
    * Every template has a case and a mode:
    
    ##########
    | CASES: |
    ##########
    
    1) Final ũ|ū - um, legũ, appellatũ", mode="final-um"
    2) Final ā|ã - am, primā, verā, mode="final-am"
    3) ā + final di|dum|t|ti|tibus|tis|tur, mode="antur"
    4) Beginning pro (chara753), ꝓbari probari, mode="pro1"
    5) Final - us (chara770), legitimꝰ - legitimus, mode="final-us"
    6) õ + c|d|f|s|t ==> on, cōsensu consensu, mode="on-cdfst"
    7) õ + final e|es, petitiōe petitione, mode="ones"
    8) ũ + t|tur, deducũtur deducuntur, mode="untur"
    9) ẽ + da|dam|di|dis|dus|sis|t|te|tia|tiam|tias|tur, legẽdam legendam, mode="entur"
    10) ẽ + b|m|p, exẽplo exemplo, mode="em-pmb"
    11) ĩ  ==> in, only white spaces as boundaries. 
    12) đ ==> de, only white spaces boundaries, mode="de" 

    Names are tagged literal:

    13) Clemẽ - Clemen + \., mode="Clemen"
    14) Innocẽ - Innocen + \., mode="Innocen"
    15) Alexā - Alexan + \., mode="Alexan"
    16) Alexād - Alexand + \., mode="Alexand"
    17) Ioā - Ioan + \. , mode="Ioan"

    18) q + ´ + ; ==> que, leuisq́;, mode="qac"
    19) q3 + ´ (chare8bf0301) ==> que, Exemplum́, mode="q3accent"
    20) q3 (chare8bf), ==> que, mode="q3"
    21) ⁊ (char204a) ==> et. , mode="only-et"
    
    
    
    
    
    
    ATENTION!
        
    To avoid tagging only word parts separated by a "\n" e. g. "cõ\n<lb/>feſſarſe", white spaces should be written as literal white spaces " " instead of the regex "\s".  
    Consequently, "\n" and "\t" are not included in the pattern. 
    This also means, that words at the end of the lines are not tagged, eventhoug they might follow the pattern. e.g. "juramentauā\n" This is meant to avoid false positives.

     ########################          
    | Dangerous exceptions!  |
    | They are not included  |
     ########################
    
    1) Final ẽ|ē - because it might be expanded in em or en, and there is not a clear rule to identify which should be chosen.
        secularẽ  - secularem
        discrimẽ  - discrimen
        attamẽ  - attamen
        
        '(\s)([æœęaA-zZſç]+)(ē|ē|ẽ|ẽ)([, \?!\(\)\*\+✝]+)'
    
    2) õ + b|m|p ==> always om? it is not 100% verified, it might have exceptions.
    
        cōmemorat commemorat
        cōparatio comparatio
        excōmunicatum excommunicatum
        fideicōmissis fideicommissis
        
        (\s)([æœaA-zZſç]+)(õ|õ|ō|ō)(b|m|p)([æaA-zZſç]+)([, \?!\(\)\*\+✝]+)
        
 ########################          
| How to add new cases:  |
 ########################     
     
     1) Test the new pattern in new texts in latin, which are still in version 001.
        Words found should neither yield exceptions, ambiguities nor show conflicts with other cases in this program.
        
     2) Write the pattern with examples in the list "cases" above and assign a new mode. It should be different from all modes used before.
     
     3) Between the last template and "Logging", write a new variable. Its name is usually the same name as the new mode. 
        And in <xsl:apply-templates/> select the last variable name, and place the new mode: 
     
         <xsl:variable name="ExampleNew">
            <xsl:apply-templates select="$lastTemplateVariableName" mode="ExampleNew"/>
         </xsl:variable>
     
     4) Write a template with a template with the identity transforms using the new mode:
          
            <xsl:template match="@*|node()" mode="ExampleNew">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="ExampleNew"/>
                </xsl:copy>
            </xsl:template>
            
     5) Write a template that matches only text in latin, which is not tagged as expansion yet and add the new mode:
          
          <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="ExampleNew">
          
          Regex-groups must be placed in () and distributed in the new elements. See the templates below.
    
    6) For logging purpuses and for keeping track of the new expanssions added, look for the following locations (variable $out and variable $Expansions) 
       at the very end of the code in the "logging" section, and replace the new variable:
    
        <xsl:variable name="out">
            <xsl:copy-of select="$ExampleNew"/>
        </xsl:variable>
        
        Unwanted characters in expansions.
        
        <xsl:variable name="Abbr" as="node()*" select="$ExampleNew//tei:abbr[@rend eq 'abbr' and following-sibling::node()/self::tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]]"/>
        <xsl:variable name="WrongExpansions" as="node()*" select="$ExampleNew//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]"/>
        
        Abbr with no special character, check this out.
        ...(Here the last variable)//tei:abbr[@rend eq 'abbr' and not(matches(.,'[ãẽõũꝓq̃]+'))]
        replace by
        $ExampleNew//tei:abbr[@rend eq 'abbr' and not(matches(.,'[ãẽõũꝓq̃]+'))]
        
        Update last case variable
        <xsl:variable name="Expansions" as="xs:integer" select="count($ExampleNew//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>        
    -->
    
<!-- ###################################################################################################################################################        
                                         TEMPLATES FOR EACH CASE  
     ###################################################################################################################################################-->
    
<!-- 1) Final ũ|ū - um, legũ, appellatũ"-->
    
    <xsl:variable name="final-um">
        <xsl:apply-templates select="/" mode="final-um"/>
    </xsl:variable>
        
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-um">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-um"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="final-um">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ũ|ũ|ū|ū)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'um')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!-- 2) Final ā|ã - am, primā, verā"-->
    
    <xsl:variable name="final-am">
        <xsl:apply-templates select="$final-um" mode="final-am"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-am">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-am"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="final-am">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ã|ã|ā|ā)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'am')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
 
<!--3)  ā + final di|dum|t|ti|tibus|tis|tur, an, mode="antur"-->
    
    <xsl:variable name="antur">
        <xsl:apply-templates select="$final-am" mode="antur"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="antur">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="antur"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="antur">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ã|ã|ā|ā)(di|dum|t|ti|tibus|tis|tur)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--4)  Beginning pro (chara753), ꝓbari probari, mode="pro1"-->
    
    <xsl:variable name="pro1">
        <xsl:apply-templates select="$antur" mode="pro1"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="pro1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="pro1"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="pro1">
        <xsl:analyze-string select="." regex="{'(\s)(ꝓ)([æœęaA-zZſç]+)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat('pro',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--5) Final - us (chara770), legitimꝰ - legitimus, mode="final-us"-->     
    
    <xsl:variable name="final-us">
        <xsl:apply-templates select="$pro1" mode="final-us"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-us">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-us"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="final-us">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ꝰ)([\n, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'us')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 6)  õ + c|d|f|s|t ==> on cōsensu consensu, mode="on-cdfst"-->
    
    <xsl:variable name="on-cdfst">
        <xsl:apply-templates select="$final-us" mode="on-cdfst"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="on-cdfst">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="on-cdfst"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="on-cdfst">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(õ|õ|ō|ō)(c|d|f|s|ſ|t)([æaA-zZſç]+)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'on',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 7) õ + final e|es, petitiōe petitione, mode="ones" -->
    
    <xsl:variable name="ones">
        <xsl:apply-templates select="$on-cdfst" mode="ones"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ones">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ones"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="ones">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(õ|õ|ō|ō)(e|es|eſ)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'on',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 8) ũ + t|tur, deducũtur deducuntur, mode="untur" -->  

    <xsl:variable name="untur">
        <xsl:apply-templates select="$ones" mode="untur"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="untur">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="untur"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="untur">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ũ|ũ|ū|ū)(t|tur)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'un',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 9) ẽ + da|dam|di|dis|dus|sis|t|te|tia|tiam|tias|tur, mode="entur"
        intelligẽda intelligenda
        legẽdam legendam
        repetẽdi repetendi
        exequẽdis exequendis
        remittẽdus remittendus
        expẽsis expensis
        solẽt solent
        tacẽte tacente
        differẽtia differentia
        differẽtiam diferentiam
        sentẽtias sententias
        tenẽtur tenentur-->
    
    <xsl:variable name="entur">
        <xsl:apply-templates select="$untur" mode="entur"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="entur">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="entur"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="entur">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ē|ē|ẽ|ẽ)(da|dam|di|dis|dus|sis|t|te|tia|tiam|tias|tur)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 10) ẽ + b|m|p, exẽplo exemplo, mode="em-pmb" -->
    
    <xsl:variable name="em-pmb">
        <xsl:apply-templates select="$entur" mode="em-pmb"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="em-pmb">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="em-pmb"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="em-pmb">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(ē|ē|ẽ|ẽ)(b|m|p)([æaA-zZſç]+)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'em',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 11) ĩ  ==> in, only white spaces boundaries, mode="in" -->
    
    <xsl:variable name="in">
        <xsl:apply-templates select="$em-pmb" mode="in"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="in">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="in"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="in">
        <xsl:analyze-string select="." regex="{'( )(ĩ)( )'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'in'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 12) đ ==> de, only white spaces boundaries, mode="de" -->
    
    <xsl:variable name="de">
        <xsl:apply-templates select="$in" mode="de"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="de">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="de"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="de">
        <xsl:analyze-string select="." regex="{'( )(đ)( )'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'de'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!-- 13) Clemẽ - Clemen + \. -->
    <xsl:variable name="Clemen">
        <xsl:apply-templates select="$de" mode="Clemen"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Clemen">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Clemen"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="Clemen">
        <xsl:analyze-string select="." regex="{'( )(Clem)(ē|ē|ẽ|ẽ)(\.)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 14) Innocẽ - Innocen + \. -->
    <xsl:variable name="Innocen">
        <xsl:apply-templates select="$Clemen" mode="Innocen"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Innocen">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Innocen"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="Innocen">
        <xsl:analyze-string select="." regex="{'( )(Innoc)(ē|ē|ẽ|ẽ)(\.)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--15) Alexā + \.-->
    
    <xsl:variable name="Alexan">
        <xsl:apply-templates select="$Innocen" mode="Alexan"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Alexan">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Alexan"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="Alexan">
        <xsl:analyze-string select="." regex="{'( )(Alex)(ã|ã|ā|ā)(\.)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--16) Alexād - Alexand + \.-->
    
    <xsl:variable name="Alexand">
        <xsl:apply-templates select="$Alexan" mode="Alexand"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Alexand">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Alexand"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="Alexand">
        <xsl:analyze-string select="." regex="{'( )(Alex)(ã|ã|ā|ā)(d)(\.)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 17) Ioā - Ioan + \. , mode="Ioan"-->    
    <xsl:variable name="Ioan">
        <xsl:apply-templates select="$Alexand" mode="Ioan"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Ioan">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Ioan"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="Ioan">
        <xsl:analyze-string select="." regex="{'( )(Io)(ã|ã|ā|ā)(\.)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
 
<!-- 18) q + ´ + ; ==> que, leuisq́;, mode="qac"-->
    <xsl:variable name="qac">
        <xsl:apply-templates select="$Ioan" mode="qac"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="qac">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="qac"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="qac">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(q́;)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- 19) q3 + ´ (chare8bf0301) Exemplum́  mode="q3accent"-->
    <xsl:variable name="q3accent">
        <xsl:apply-templates select="$qac" mode="q3accent"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="q3accent">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="q3accent"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="q3accent">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)(́)([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 20) q3 (chare8bf), mode="q3"-->
    
    <xsl:variable name="q3">
        <xsl:apply-templates select="$q3accent" mode="q3"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="q3">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="q3"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])]" mode="q3">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſç]+)()([, \?!\(\)\*\+✝]+)'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--21) ⁊ (char204a) ==> et. , mode="only-et"-->

    <xsl:variable name="only-et">
        <xsl:apply-templates select="$q3" mode="only-et"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-et">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-et"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-et">
        <xsl:analyze-string select="." regex="{'(\s)(⁊)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'et'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$only-et"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb)"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($out//tei:pb)"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb)"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($out//tei:cb)"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb)"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb)"/>
        
        <!-- whitespace -->
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'ERROR: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- chars -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'INFO: amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        
        <!--
        Unwanted characters in expansions.        
        These characters should not be in an expansion, since they are also to be expandend.  ã ã ā ē ẽ ẽ ĩ õ õ ō ō ũ ũ ū ū đ ꝓ
        In these program are not taken into account words with multiple charaters to be expanded.
        e.g. (abbr: tãbiẽ => expan: tambien) is a complex case because it hast 2 characters to be expanded namely 'ã' in 'am' and 'ẽ' in 'en'.    
        -->
        <!-- Update last case variable in the following variables: Abbr and WrongExpansions-->
        <xsl:variable name="Abbr" as="node()*" select="$only-et//tei:abbr[@rend eq 'abbr' and following-sibling::node()/self::tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ́]+')]]"/>
        <xsl:variable name="WrongExpansions" as="node()*" select="$only-et//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ́]+')]"/>
        <xsl:choose>
            <xsl:when test="count($WrongExpansions) gt 1">
                <!--<xsl:for-each select="$WrongExpansions/text()">-->
                <xsl:message select="concat('Error: ', count($WrongExpansions),' unwanted special character(s) in tei:abbr[@rend=expan] detected. Words: abbr => '
                    ,string-join(distinct-values($Abbr),' | '), ' expan => '
                    ,string-join(distinct-values($WrongExpansions),' | '),' - Evaluate the regex patterns/cases and run the program again.')"/>
                <!--</xsl:for-each>-->
            <xsl:message terminate="no"/>
            </xsl:when>
            <xsl:when test="count($WrongExpansions) eq 1">
                <xsl:message select="concat('Error: unwanted special character in expan detected - ',$Abbr,' - ',$WrongExpansions,' - Evaluate the regex patterns/cases and run the program again.')"/>
                <xsl:message terminate="no"/>
            </xsl:when>
            <!--Abbr with no special character, check this out.-->
            <xsl:when test="$only-et//tei:abbr[@rend eq 'abbr' and not(matches(.,'[ẽãāāēẽõōũūꝓꝰ́q́]+'))]">
                <xsl:message select="concat('An abbr without special character detected: ',string-join(distinct-values(tei:abbr[@rend eq 'abbr' and not(matches(.,'[ẽãāāēẽõōũūꝓꝰ́q́]+'))]/text()),' | '))"/>
                <xsl:message terminate="no"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Update last case variable in the following variable: Expansions-->
                <xsl:variable name="Expansions" as="xs:integer" select="count($only-et//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>
                <xsl:message select="concat('INFO: added ', xs:string($Expansions), ' with regex-based (word structure) abbr. expansion.')"/>
                <xsl:message select="'INFO: quality check successfull.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

</xsl:stylesheet>