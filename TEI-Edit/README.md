# svsal-teiedit

# The School of Salamanca Text Editing Pipeline.

## What is this?

The text editing workflow of the project [https://www.salamanca.school/de/index.html](https://www.salamanca.school/de/index.html)The School of Salamanca, which is based on sustainable and scalable methods and practices of text processing.
It contains all TEI-tite, TEI-All, and XSLT files used for text editing. 

This Digital Source Collection[https://www.salamanca.school/de/works.html](https://www.salamanca.school/de/works.html) comprises a relatively large mass of texts for a full-text digital edition project: 
in total, it will involve more than 108,000 printed pages from early modern prints in Latin and Spanish.

Sustainability in text processing, reusability of the tools and a long-term documentation and traceability of the development of the text data. 



See also: The School of Salamanca Text Workflow: From the early modern print to TEI-All.
https://blog.salamanca.school/de/2022/04/27/the-school-of-salamanca-text-workflow-from-the-early-modern-print-to-tei-all/

Our Edition Guidelines: https://www.salamanca.school/en/guidelines.html

## What is in the folders?

There are many dependencies in folders and files. See Details:

### teiedit/works/lib

Saxon processor.

### teiedit/works/build

Specific edtion of every work/volume in a separate folder.

See a specific example with: 

teiedit/works/build/W0076

Moreno, Reglas Ciertas, Y Precisamente Necessarias Para Ivezes, Y Ministros De Ivsticia de las Indias, y para sus Confessores (2022 [1637]), in: The School of Salamanca. A Digital Collection of Sources <https://id.salamanca.school/texts/W0076>

Folder W0076 contains:

1. build.xml file with all pipeline steps.   
2. config: Abbreviation list. Employed with ``<target name="xslt-010"xsl [...]>`` 
2. corrlist: correction lists. For instance ``corrlist\lists`` in combination with ``<target name="xslt-008"/>``
3. log: Pipeline logging
4. xml: Versions of the work in xml. From the original externally transcribed until the last corrected version published online.
5. xsl: Specific XSL-Transformationen employed to edit the work W0076.  

teiedit/works/build/W0030

Carrasco del Saz, Tractatus de casibus curiae. (2020 [1630]), in: The School of Salamanca. A Digital Collection of Sources <https://id.salamanca.school/texts/W0033> 

### teiedit/works/corr

Templates of XQuery programms to build correction lists for marginal and main area of the text.  

### teiedit/works/orig

Original transcriptions from external providers (Textloop/Grepect).

### teiedit/works/resources

#### Chars

List of special characters in XML. specialchars_2020-11-06.xml

#### Config

List of abbreviations and their respective expansions in XML. abbr-es.xml, abbr-la.xml

#### XSL-Templates

List of templates:

* TEI-tite to TEI-All Transformation (tl2sal_tite2tei_general.xsl, tl2sal_tite2tei_text.xsl)
* Cross-references (summaries to milestones, annotateRefMilestones.xsl)
* Hyphen Annotation (TL_GP_AnnotateHyphenBreaks.xsl, annotateHyphenBreaksHiNote.xsl)
* Special Characters Annotation (annotateSpecialChars.xsl and teiedit/works/resources/chars/specialchars_2020-11-06.xml)
* xml:id(s) Annotation (Step 1: numberLines.xsl, Step 2:generateXmlId.xsl)
* Unmarked breaks annotation (annotateUnmarkedBreaks.xsl and a list with the canditates in html: e.g.: teiedit/works/build/W0076/corrlist/lists/W0076-es_supposed-hyphenations-from-text.html)
* Automatic Abbreviation Resolution:

    **With regex:** See: https://github.com/CindyRicoCarmona/Expand_abbreviations_with_regex, expandAbbreviations_LA_regex_TEItite.xsl, expandAbbreviations_ES_regex_TEItite.xsl

    **With XML-lists:** expandAbbreviations_12.12.2019.xsl and teiedit/works/resources/config[abbr-es.xml/abbr-la.xml]
* After manual corrections / Final corrections:

      fixOxygenWhitespaceBug.xsl
      postCorrFixes.xsl
      correctBreaks.xsl
      choiceBreakPairs.xsl
      replaceTeiHeader.xsl
      
* General template with logging for further possible transformations (general-template.xsl)      
        
#### Validation

Count signs from a text. Usually used to verify text deliveries from external providers: teiedit/works/resources/validation/py/sign_count.py

Schematron:

    Check general text structure: sal-tei.sch

    Check meta data/bibliographic information: teiHeader.sch
    
### teiedit/woerterbuecher

It contains latin and spanish dictionaries (teiedit/woerterbuecher/es/wordforms-es.txt, teiedit/woerterbuecher/lat/wordforms-lat-full.txt) to create corrections lists. See: teiedit/works/corr    




 




