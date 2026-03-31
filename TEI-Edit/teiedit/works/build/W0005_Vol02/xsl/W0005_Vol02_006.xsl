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
    <xsl:param name="editingDate" as="xs:string" select="'2025-09-11'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0005_Vol02_change_013'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Added (es) abbreviations depending on word structure with regex.'"/>
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
        
        Updated 28.08.2025 by CR
        If you want the last version before abbr with breaks were added see:
        [SVN]/trunk/teiedit/works/resources/templates/xsl/deprecated/expandAbbreviations_ES_regex_TEItite_27.03.25.xsl
        
        See: https://github.com/CindyRicoCarmona/Expand_abbreviations_with_regex

        Expanding spanish abbreviations depending on their word structure. For example, a combination of a special characters and their endings or morphemes.
        
        REQUIREMENTS:
        
        * This program is only to be used in TEI-tite texts before the TEI-Transformation and special character annotation are done,
         otherwise it won't work.
         
        * Missing/innecesary white spaces may generate false positves.
        They are to be checked in the input/output text in context of the following words:
        "y, el, de, la, lo, las, los, en, o, u, etc." are sometimes transcribed together with other words.
        
        * not(ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')]) was added, in case other languages appear e.g. in marginal notes, or front/back.  
        
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
        
        1) "endo - pudiẽdo", mode="endo"
        2) "ando - dudãdo", mode="ando"
        3) "ente|tes - gẽte", mode="ente"
        4) "ende - entiẽde", mode="ende"
        Exception for W0035 "ſctõ" mode="ſcto"
        5) "on - Purificaciõ", mode="cion"
        6) "ento - mandamiẽto", mode="ento"
        7) "encia|cias - differẽcia", mode="encia" 
        8) "ancia - ignorãcia", mode="ancia"
        9) "ẽ and er - entẽder", mode="ener"
        10) "ẽ and ar - encomẽdar", mode="enar"
        11) "ã and ar" - mãdar, mode="anar"
        Exception Itẽ mode="Item"
        12) "ẽ - en - puedẽ, quiẽ, deuẽ", mode="final-en"
        Exception W0053 eſpũ ſanto, should not be expanded as final-un
        Exception W0035 Words ending with (ũ|ũ|ū|ū - un). e.g. segũ, algũ mode="final-un"
        Exception for W0035 "ſctã" mode="ſctan"
        13) "ā - an - haziā, siruā, podrā", mode="final-an"
        14) "ũ - un - pregũtar, renũciar", mode="unar" 
        15) "ũ - before (b|p) costũbre, cũplido", mode="umbp"
        16) "õ - before (b|p) hōbres, Cōprar", mode="ombp"
        17) "ō and dad|dades, bōdad, cōformidad", mode="ondad"
        18) "õ and dido|dida|didas|didos, cōcedido, cōcedida" mode="ondido"
        19) "ā and dad|dades, trāquilidad, Hermādad" mode="andad"
        20) "ā and ça|ças, ordenāça, templāça", mode="ança"
        21) "ẽ  and ça|çan|ças, verguẽça, comiẽçan" mode="ença"
        22) "đ at the beginning + \w, đspues,đllas (no further special characters like "ā|ẽ|õ|ũ")" mode="dewords"
        23) "ꝓ q with tilde inside a word, flaq̃za, riq̃zas (flaqueza, riquezas)" mode="wquew"
        Exeption ꝓxio projimo
        24) "ꝓ pro at the beginning + \w, ꝓhibir, ꝓcesso (prohibir, processo)" mode="prow"
          
        Depending on the text and the mixture between latin and spanish, check W0005_Vol01_005.xsl for cases:
        
        25) "final ũ", algũ - algun mode="final-un"
        26) "q̃" - que,  mode="only-que"
        27) "ẽ - en", mode="only-en"
        28) "ꝓ q with tilde at the end of a word, porq̃  - porque" mode="wque"
        29) "đ| (char0111|charf159)- de" mode="only-de"
        
        To be used in all spanish texts:
        30) ⁊ (char204a) ==> y , mode="only-y"
        31) ↄ abbreviation + p|b = com  ↄplida -> complida mode="abbr-com"
        32) ↄ abbreviation con = ↄuiene -> conuiene mode="abbr-con"
        
            
                
        ATENTION!
        
        To avoid tagging only word parts separated by a "\n" e. g. "cõ\n<lb/>feſſarſe", white spaces should be written as literal white spaces " " instead of the regex "\s".  
        Consequently, "\n" and "\t" are not included in the pattern. 
        This also means, that words at the end of the lines are not tagged, eventhoug they might follow the pattern. e.g. "juramentauā\n" This is meant to avoid false positives.

       ########################          
      | Dangerous exceptions!  |
      | They are not included  |
       ########################
      
      1)  "m" before "p" and "b" it means scenarios like:
          "cõprar" should be expanded in "comprar" instead of "conprar" 
          "cũplido" should be expanded in cumplido instead of "cunplido"
          
          The following expressions do not take into account "p|b" exceptions:
          
         Words with ō + ar
          (\s)([aA-zZſç]+)(õ|õ|ō|ō)([aA-zZſç]+)(ar)([ \.,;\(\)]) ==>  
          (\s)([aA-zZſç]+)(õ|õ|ō|ō)([aA-zZſç]?)(ar)([ \.,;\(\)]) ==> 
          
         Words with ō + er 
          (\s)([aA-zZſç]+)(õ|õ|ō|ō)([aA-zZſç]?)(er)([ \.,;\(\)])
          (\s)([aA-zZſç]+)(õ|õ|ō|ō)([aA-zZſç]+)(er)([ \.,;\(\)])
        
         In both
         regex-group 4 whit (+) selects all characters including exceptions with pb e.g.
         regex-group 4 whit (?) works for few cases, but is not 100% reliable
         
         That is why, only cases 15 and 16 are allowed until now. 
        
      2) "cõ - con" might have exceptions because it might be the begining of another word and missing white spaces.
          e.g. "cõla", should be "cõ" white space "la".
          
      3) Final ũ, as in "algũ".
         When whites spaces are missplaced or @xml:lang 'la' is not tagged, it can lead to false positives as "aũ que", which should be "aũque".

         ONLY used in W0005_Vol02_006.xsl.
               
         (\s)([aA-zZſç]+)(ũ|ũ|ū|ū)([ \.,;\(\)])
          
      * Not found, which might appear in future works?
        
            - Words with ĩ and ar, er, ir 
            - Words with ã and er, ir
            - Words with õ + ir
            - Words with ũ + er 
            - Words with ũ + ir
      * Few cases of "ꝓ" inside a word. e.g. "aꝓuechar" (aprouechar)
          (\s)([aA-zZñſç]+)(ꝓ)([aA-zZñſç]+)([ \.,;\(\)])
        If more similar cases are found, it can be added as a new case.
        
        
     ########################          
    | How to add new cases:  |
     ########################     
     
     1) Test the new pattern in spanisch texts in version 001 (W0005_Vol01, W0017, W0061, W0083 etc.)
        Words found should neither yield exceptions, ambiguities nor show conflicts with other cases in this program.
        
     2) Write the pattern with examples in the list "cases" above and assign a new mode. It should be different from all modes used before.
     
     3) Between the last template and before ... see "ALWAYS AS LAST STEPS", write a new variable. Its name is usually the same name as the new mode. 
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
            
     5) Write a template that matches only text in spanisch, which is not tagged as expansion yet and add the new mode:
          
          <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ExampleNew">
          
          Regex-groups must be placed in () and distributed in the new elements. See the templates below.
    
    6) update the new variable name "$ExampleNew" as the input for the "ALWAYS AS LAST STEPS" => variable "Put-LBHyphen-back"
    
    See the variable "Put-LBHyphen-back":
    
    <xsl:variable name="Put-LBHyphen-back">
        <xsl:apply-templates select="[HIER SHOULD GO THE NEW VARIABLE]" mode="Put-LBHyphen-back"/>
    </xsl:variable>
    
    so it looks like...
    
    <xsl:variable name="Put-LBHyphen-back">
        <xsl:apply-templates select="$ExampleNew" mode="Put-LBHyphen-back"/>
    </xsl:variable>
   
-->
    
<!--

1 Replace '-<lb type="nb"/>' and '<lb type="nb"/> with '€' and '€' throughout the entire work.

2 XSLT regex as usual, but using '-€' in the characters e.g.: regex="{'(\s)([æœęaA-zZſç-€]+)(ũ|ũ|ū|ū)([, \?!\(\)\*\+✝]+)'}".

3 At the very end of the style scheet => Replace '-€' back with '-<lb type="nb"/>'.-->

    <xsl:variable name="borrarLB">
        <xsl:apply-templates select="/" mode="borrarLB"/>
    </xsl:variable>
        
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="borrarLB">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="borrarLB"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:lb[@type='nb']" mode="borrarLB">
        <xsl:text>€</xsl:text>
        <xsl:apply-templates mode="borrarLB"/>
    </xsl:template>
    
    
<!--
###################################################################################################################################################        
                                         TEMPLATES FOR EACH CASE  
###################################################################################################################################################    
-->
<!-- 1) ẽ + "do" e.g. "pudiẽdo"-->
    
    <xsl:variable name="endo">
        <xsl:apply-templates select="$borrarLB" mode="endo"/>
    </xsl:variable>
        
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="endo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="endo"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="endo">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ẽ|ẽ|ē)(do)([ .,;\(\)])'}">
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

    <!-- 2) ã + "do" e.g. dudãdo -->
    
    <xsl:variable name="ando">
        <xsl:apply-templates select="$endo" mode="ando"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ando">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ando"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ando">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ã|ã|ā)(do)([ \.,:;\(\)])'}">
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
    
<!-- 3) ẽ + "te|tes" e.g. "mortalmẽte", "gẽte"-->
    
    <xsl:variable name="ente">
        <xsl:apply-templates select="$ando" mode="ente"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ente">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ente"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ente">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)(te|tes)([ \.,:;\(\)])'}">
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
    
<!-- 4) ẽ + "de" e.g. "entiẽde"-->
    <xsl:variable name="ende">
        <xsl:apply-templates select="$ente" mode="ende"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ende">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ende"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ende">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)(de)([ \.,:;\(\)])'}">
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

<!--Exception for W0035 "ſctõ" mode="ſcto".-->

    <xsl:variable name="Scto">
        <xsl:apply-templates select="$ende" mode="Scto"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Scto">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Scto"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="Scto">
        <xsl:analyze-string select="." regex="{'(\s)(Sct)(õ|õ|ō|ō)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="'Santo'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:variable name="ſcto">
        <xsl:apply-templates select="$Scto" mode="ſcto"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ſcto">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ſcto"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ſcto">
        <xsl:analyze-string select="." regex="{'(\s)(sct|ſct)(õ|õ|ō|ō)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="'santo'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--5) "õ-on" at the end e.g. "Purificaciõ"-->
    <xsl:variable name="cion">
        <xsl:apply-templates select="$ſcto" mode="cion"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="cion">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="cion"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="cion">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(õ|õ|ō|ō)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'on')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 6) ẽ + "to" e.g. "mandamiẽto"-->
    <xsl:variable name="ento">
        <xsl:apply-templates select="$cion" mode="ento"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ento">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ento"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ento">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)(to)([ \.,:;\(\)])'}">
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
    
<!--7) ẽ + "cia|cias" e.g. "differẽcia"-->
    <xsl:variable name="encia">
        <xsl:apply-templates select="$ento" mode="encia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="encia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="encia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="encia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)(cia|cias)([ \.,:;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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
    
<!--  8) ã + "ancia" e.g. "ignorãcia"-->
    <xsl:variable name="ancia">
        <xsl:apply-templates select="$encia" mode="ancia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ancia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ancia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ancia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ã|ã|ā)(cia)([ \.,:;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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

<!-- 9) ẽ + "er" e.g. "entẽder"-->
    <xsl:variable name="ener">
        <xsl:apply-templates select="$ancia" mode="ener"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ener">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ener"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ener">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)([aA-zZñſç]?)(er)([ \.,:;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 10) ẽ + "ar" e.g. "encomẽdar"-->
    <xsl:variable name="enar">
        <xsl:apply-templates select="$ener" mode="enar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="enar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="enar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="enar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ẽ|ẽ|ē)([aA-zZñſç]?)(ar)([ \.,:;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 11) ã + "ar" e.g. "mãdar"-->
    <xsl:variable name="anar">
        <xsl:apply-templates select="$enar" mode="anar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="anar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="anar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="anar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ã|ã|ā)([aA-zZñſç]?)(ar)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- Exception Itẽ  -->
    <xsl:variable name="Item">
        <xsl:apply-templates select="$anar" mode="Item"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Item">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Item"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="Item">
        <xsl:analyze-string select="." regex="{'(\s)(It)(ẽ|ẽ|ē)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'em')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- 12) Words ending with (ẽ-en). e.g. puedẽ, quiẽ, deuẽ-->
    
    <xsl:variable name="final-en">
        <xsl:apply-templates select="$Item" mode="final-en"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-en">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-en"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-en">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ẽ|ẽ|ē)([ \.,:;\(\)])'}">
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

<!-- Exception W0053 eſpũ ſanto, should not be expanded as final-un -->
    <xsl:variable name="spiritu">
        <xsl:apply-templates select="$final-en" mode="spiritu"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="spiritu">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="spiritu"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="spiritu">
        <xsl:analyze-string select="." regex="{'(\s)(eſp)(ũ|ũ|ū|ū)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="'espiritu'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- Exception W0035 Words ending with (ũ|ũ|ū|ū - un). e.g. segũ, algũ-->
    
    <xsl:variable name="final-un">
        <xsl:apply-templates select="$spiritu" mode="final-un"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-un">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-un"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-un">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(ũ|ũ|ū|ū)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'un')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--Exception for W0035 "ſctã" mode="ſctan".-->   
 <xsl:variable name="ſctan">
        <xsl:apply-templates select="$final-un" mode="ſctan"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ſctan">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ſctan"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ſctan">
        <xsl:analyze-string select="." regex="{'(\s)(ſct)(ã|ã|ā|ā)([, :;\?!\)\.])'}">
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
                        <xsl:value-of select="'santa'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- 13) Words ending in (ā-an). e.g. haziā, siruā, podrā-->
    
    <xsl:variable name="final-an">
        <xsl:apply-templates select="$ſctan" mode="final-an"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-an">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-an"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-an">
        <xsl:analyze-string select="." regex="{'(\s)([æœęaA-zZſçñ€-]+)(ã|ã|ā|ā)([, :;\?!\)\.])'}">
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
   

   
<!-- 15) ũ before (b|p) e.g. cũplido, costũbre-->
    
    <xsl:variable name="umbp">
        <xsl:apply-templates select="$final-an" mode="umbp"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="umbp">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="umbp"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="umbp">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ũ|ũ|ū|ū)(b|p)([aA-zZñſç]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'um',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 14) ũ + ar e.g. pregũtar, renũciar-->
    
    <xsl:variable name="unar">
        <xsl:apply-templates select="$umbp" mode="unar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="unar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="unar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="unar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ũ|ũ|ū|ū)([aA-zZñſç]+)(ar)([ \.,:;\(\)])'}"><!--(\w+[^ãẽõũ])-->
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
                        <xsl:value-of select="concat(regex-group(2),'un',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--16) "õ - before (b|p) e.g. hōbres, Cōprar"-->
    <xsl:variable name="ombp">
        <xsl:apply-templates select="$unar" mode="ombp"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ombp">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ombp"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ombp">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(õ|õ|ō|ō)(b|p)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'om',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--17) "ō + dad|dades, bōdad, cōformidad", mode="ondad"-->
    <xsl:variable name="ondad">
        <xsl:apply-templates select="$ombp" mode="ondad"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ondad">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ondad"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ondad">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(õ|õ|ō|ō)([aA-zZñſç€-]*)(dad|dades)([ \.:,;\(\)])'}">
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
    
<!--18) "õ + dido|dida|didas|didos, cōcedido, cōcedida" mode="ondido"-->
    
    <xsl:variable name="ondido">
        <xsl:apply-templates select="$ondad" mode="ondido"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ondido">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ondido"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ondido">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(õ|õ|ō|ō)([aA-zZñſç€-]*)(dido|dida|didas|didos)([ \.,;\)])'}">
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
    
<!--19) "ā + dad|des, trāquilidad, Hermādad" mode="andad"-->
    
    <xsl:variable name="andad">
        <xsl:apply-templates select="$ondido" mode="andad"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="andad">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="andad"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="andad">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(āã)([aA-zZñſç€-]*)(dad|dades)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--20) "ā + ça|ças, ordenāça, templāça", mode="ança"-->
    <xsl:variable name="ança">
        <xsl:apply-templates select="$andad" mode="ança"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ança">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ança"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ança">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ã|ã|ā)([ças€-]+)([ \.,:;\(\)])'}">
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
    
<!--21) "ẽ  and ça|çan|ças, verguẽça, comiẽçan" mode="ença"-->
    <xsl:variable name="ença">
        <xsl:apply-templates select="$ança" mode="ença"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ença">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ença"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ença">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç€-]+)(ẽ|ẽ|ē)(ça|çan|ças+)([ \.,:;\(\)])'}">
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

<!--22) "đ at the beginning e.g. đspues, đllas (no further special characters like "ā|ẽ|õ|ũ")" mode="dewords"-->
    
    <xsl:variable name="dewords">
        <xsl:apply-templates select="$ença" mode="dewords"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="dewords">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="dewords"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="dewords">
        <xsl:analyze-string select="." regex="{'(\s)(đ)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat('de',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--23) "q̃ (q with tilde) inside a word, flaq̃za, riq̃zas (flaqueza, riquezas)" mode="wquew"-->
    <xsl:variable name="wquew">
        <xsl:apply-templates select="$dewords" mode="wquew"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="wquew">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="wquew"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="wquew">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ€-]+)(q̃)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat(regex-group(2),'que',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--Exeption ꝓxio projimo 26.08.25 CR-->

    <xsl:variable name="proximo">
        <xsl:apply-templates select="$wquew" mode="proximo"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="proximo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="proximo"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="proximo">
        <xsl:analyze-string select="." regex="{'(\s)(ꝓ)(xio)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="'projimo'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--24) "ꝓ (pro) at the beginning, ꝓhibir, ꝓcesso (prohibir, processo)" mode="prow-->
    
    <xsl:variable name="prow">
        <xsl:apply-templates select="$proximo" mode="prow"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="prow">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="prow"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="prow">
        <xsl:analyze-string select="." regex="{'(\s)(ꝓ)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
<!--Only del-->
    <xsl:variable name="only-del">
        <xsl:apply-templates select="$prow" mode="only-del"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-del">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-del"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-del">
        <xsl:analyze-string select="." regex="{'(\s)()(l|los|llos|las|llas)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat('de',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--   ==> de , mode="only-de"-->
    
    <xsl:variable name="only-de">
        <xsl:apply-templates select="$only-del" mode="only-de"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-de">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-de"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-de">
        <xsl:analyze-string select="." regex="{'(\s)()([ \.,:;\(\)])'}">
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

<!--30) ⁊ (char204a) ==> y , mode="only-y"-->
    
    <xsl:variable name="only-y">
        <xsl:apply-templates select="$only-de" mode="only-y"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-y">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-y"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-y">
        <xsl:analyze-string select="." regex="{'(\s)(⁊)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="'y'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>

    </xsl:template>

<!--31) ↄ abbreviation + p|b = com  ↄplida -> complida-->
<xsl:variable name="abbr-com">
        <xsl:apply-templates select="$only-y" mode="abbr-com"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="abbr-com">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="abbr-com"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="abbr-com">
        <xsl:analyze-string select="." regex="{'(\s)(ↄ)(b|p|m)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat('com',regex-group(3),regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--32) ↄ abbreviation con = ↄuiene -> conuiene-->
<xsl:variable name="abbr-con">
        <xsl:apply-templates select="$abbr-com" mode="abbr-con"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="abbr-con">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="abbr-con"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="abbr-con">
        <xsl:analyze-string select="." regex="{'(\s)(ↄ)([aA-zZñſç€-]+)([ \.,:;\(\)])'}">
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
                        <xsl:value-of select="concat('con',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--
ALWAYS AS LAST STEPS.



3 At the very end of the style scheet => Replace back '-<lb type="nb"/>'.

'-€' => '-<lb type="nb"/>' 
'€' => '<lb type="nb"/>'

in abbr lb with xml:id
in expan lb with sameAs
-->

<!--lb rendition hyphen-->
    <xsl:variable name="Put-LBHyphen-back">
        <xsl:apply-templates select="$abbr-con" mode="Put-LBHyphen-back"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Put-LBHyphen-back">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Put-LBHyphen-back"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()" mode="Put-LBHyphen-back">
        <xsl:analyze-string select="." regex="-€">            
            <xsl:matching-substring>
                <xsl:text>-</xsl:text>
                <xsl:element name="lb">
                    <xsl:attribute name="type" select="'nb'"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--lb rendition no hyphen-->
    <xsl:variable name="Put-LBNoHypen-back">
        <xsl:apply-templates select="$Put-LBHyphen-back" mode="Put-LBNoHypen-back"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="Put-LBNoHypen-back">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Put-LBNoHypen-back"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()" mode="Put-LBNoHypen-back">
        <xsl:analyze-string select="." regex="€">            
            <xsl:matching-substring>
                <xsl:element name="lb">
                    <xsl:attribute name="type" select="'nb'"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--Add xml:id(s)-->


    <xsl:variable name="IDS">
        <xsl:apply-templates select="$Put-LBNoHypen-back" mode="IDS"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="IDS">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="IDS"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:abbr[@rend eq 'abbr']/tei:lb" mode="IDS">
        <xsl:copy>        
        <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:apply-templates mode="IDS"/>
        </xsl:copy>
    </xsl:template>
    
<!--Add sameAs-->    
    <xsl:variable name="sameAs">
        <xsl:apply-templates select="$IDS" mode="sameAs"/>
    </xsl:variable>
    
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="sameAs">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="sameAs"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:abbr[@rend eq 'expan']/tei:lb" mode="sameAs">
        <xsl:variable name="abbr-ID" select="preceding::tei:abbr[@rend eq 'abbr' and ancestor::tei:abbr[@rend eq 'choice'] = current()/ancestor-or-self::tei:abbr[@rend eq 'choice']][1]/tei:lb[1]/@xml:id"/>
        <xsl:copy>        
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="sameAs" select="concat('#',$abbr-ID)"/>
            <xsl:apply-templates mode="sameAs"/>
        </xsl:copy>
    </xsl:template>
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$sameAs"/>
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
            <xsl:message select="'INFO: different amount of input and output pb/cb/lb - new lb(s) in abbr[@rend eq expan]: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        
        <!--
        Unwanted characters in expansions.        
        These characters should not be in an expansion, since they are also to be expandend.  ã ã ā ē ẽ ẽ ĩ õ õ ō ō ũ ũ ū ū đ ꝓ q̃  
        In these program are not taken into account words with multiple charaters to be expanded.
        e.g. (abbr: tãbiẽ => expan: tambien) is a complex case because it hast 2 characters to be expanded namely 'ã' in 'am' and 'ẽ' in 'en'.    
        -->
        <!-- Update last case variable in the following variables: Abbr and WrongExpansions-->
        <xsl:variable name="Abbr" as="node()*" select="$sameAs//tei:abbr[@rend eq 'abbr' and following-sibling::node()/self::tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]]"/>
        <xsl:variable name="WrongExpansions" as="node()*" select="$sameAs//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]"/>
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
            <xsl:when test="$sameAs//tei:abbr[@rend eq 'abbr' and not(matches(.,'[⁊ãẽõũꝓq̃]+'))]">
                <xsl:message select="concat('An abbr without special character detected: ',string-join(distinct-values(tei:abbr[@rend eq 'abbr' and not(matches(.,'[⁊ãẽõũꝓq̃]+'))]),' | '))"/>
                <xsl:message terminate="no"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Update last case variable in the following variable: Expansions-->
                <xsl:variable name="Expansions" as="xs:integer" select="count($sameAs//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>
                <xsl:message select="concat('INFO: added ', xs:string($Expansions), ' with regex-based (word structure) abbr. expansion.')"/>
                <xsl:message select="'INFO: quality check successfull.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>