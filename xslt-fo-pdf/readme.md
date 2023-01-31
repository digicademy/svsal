# XSL-FO Template description (generic_template.xsl)

## 1. General info

    Repository location: https://github.com/digicademy/svsal/tree/master/xslt-fo-pdf
    Contents: 
                folder "Fonts": fonts for Greek, Hebrew and Arab characters
                folder "PDF_Output": PDF output files
                XML files: released XML files are taken from "Salamanca SVN/svsal-tei/works"
                XSL template: "generic_template.xsl" 

“Generic_template.xsl” is an XSL stylesheet containing processing
instructions for the Saxon engine (used by Oxygen XML Editor), which
transforms the source XML to XML-FO file. This file is picked up by the
Apache FO processor (freely available and also integrated in Oxygen) and
converted to PDF:

-   Source XML \>\>\> Saxon transformer \>\>\>
    -   XML-FO \>\>\> Apache FOP \>\>\>
        -   PDF

“Generic_template.xsl” is tailored to Salamanca TEI XML and should
seamlessly transform the released XML files to PDF format. It can
therefore be used as a QA tool to check the consistency of the encoding.
The following article provides a detailed description of the
stylesheet’s constituitive elements:

-   The attributes of the <xsl:stylesheet> proper
-   The <xsl:output> method
-   The <xsl:variable>s
-   The <xsl:key>s
-   The <xsl:template>s
-   An additonal element <img:images> containing references to the
    source images of the title pages.

------------------------------------------------------------------------

## 2. The attributes of xsl:stylesheet element and xsl:output method.

The FO namespace should be defined in the root element <xsl:stylesheet>,
along with TEI, XS (XML Schema), RX (RenderX XEP) as well as a custom
“img” namespace referring to the element `<img:images>` within the same
stylesheet.

    <xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:rx="http://www.renderx.com/XSL/Extensions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:img="img:img">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>

------------------------------------------------------------------------

## 3. The variables and keys.

There are four variables:

        <xsl:variable name="images" select="document('')/*/img:images"/>            
        <xsl:variable name="guidelines" select="document('http://files.salamanca.school/works-general.xml') "/>
        <xsl:variable name="specialchars" select="document('http://files.salamanca.school/specialchars.xml') "/>
        <xsl:variable name="work_id" select="tei:TEI/@xml:id"/>

`$Images` refers to the section `<img:images>` within the XSL stylesheet
itselt, which lists the URLs of the source files for the title pages
along with the proposed citation. **Each time a new work is published
this section should be extended with the work’s information.**

    <image xml:id='W0001_Vol01' citation="Avendaño, Thesaurus Indicus, Vol. 1 (2019 [1668])">
       <source>https://facs.salamanca.school/W0001/A/W0001-A-0006.jpg</source>
    </image>

Variables `$guidelines` and `$specialchars` refer to the external
documents containing encoding guidelines and special characters.  
`$Guidelines` deliver metadata information, `$specialchars` deliver the
standartized version of the special characters which should be expanded.

keys…

------------------------------------------------------------------------

## 4. XSL templates

The document contains a set of instructions for the transformer
formulated in a series of template “matches”
`<xsl:template match="tei:element">`, triggered when a certain XML
element is encountered. The higher the location of an XML element in the
hierarchy, the more specific is the instruction; the lower it is
located, the more general is the prescribed action. For example, a
low-level `<xsl:template match="tei:imprimatur">` contains a generic
`<xsl:apply-templates/>` prescrition, while a high-level
`<xsl:template match="/">` proceeds along a set of steps, outlined
below.

In the following the description of the most important templates will be
given, organized thematically in sections:

-   (§5) Template matching the root of XML document
    (<xsl:template match="/">).
-   (§6) Templates matching different types of “tei:p” element.
-   (§7) Templates matching “tei:front”, “tei:body” and “tei:back”
    elements.
-   (§8) Templates expanding “tei:abbr”, “tei:orig” and “tei:sic”
    elements.
-   (§9) Templates expanding special characters.
-   (§10) Templates dealing with page, column and line breaks.
-   (§11) Templates dealing with marginal notes.
-   (§12) Templates dealing with tables.

------------------------------------------------------------------------

## 5. Template matching the root of XML document (<xsl:template match="/">)

`<xsl:template match="/">` creates the `<fo:root>` element with the
following attributes:

    * xmlns:fo=”http://www.w3.org/1999/XSL/Format”
    * font-selection-strategy="character-by-character"
    * font-family="Junicode, Antinoou, SBL Hebrew" 
    * xmlns:rx="http://www.renderx.com/XSL/Extensions"

The font families listed here are responsible for rendering the Greek,
Hebrew and Arab characters and should be installed in the system.

The `<fo:root>` element contains two types of information:

-   It defines the page layouts and their sequences. For this the
    element `<fo:layout-master-set>` is responsible.
-   It assigns the page layouts and their sequences to book components.
    For this a set of `<fo:page-sequence master-reference="xxx">`
    elements are responsible.

------------------------------------------------------------------------

### 5.1. Page and sequence masters (<fo:layout-master-set>)

The first element in `<fo:root>` is `<fo:layout-master-set>` describing
the so-called “masters” — page layouts of the print edition and their
sequences:

-   `<fo:simple-page-master master-name="body_matter_even">` — defines
    page layouts.
-   `<fo:page-sequence-master master-name="body_matter">` — defines the
    sequences of the layouts.

We do not follow the canons of Western book page design, which places
the center of the page area above the center of the page and where the
gutter margin is traditionally narrower than the fore-edge margin. This
is because the publication is supposed to be printed or viewed as A4
pages (page-height=“29.7cm” page-width=“21cm”) on a regular printer or
monitor.

##### 5.1.1. Page masters

There are four simple page masters in total:

-   `<fo:simple-page-master master-name="front_matter">`.
-   `<fo:simple-page-master master-name="frontispiece">`.
-   `<fo:simple-page-master master-name="body_matter_odd">`.
-   `<fo:simple-page-master master-name="body_matter_even">`.

We define separate layouts for the odd and even pages, because they
contain different information in the header and the footer. Odd pages
contain the author name centered in the header and page number in the
footer flush-right. Even pages contain the short title of the book
centered in the header and page number in the footer flush-left.

Each of the above page masters contains the following properties:

-   The page and its **margins** , which are not printed: margin-top,
    margin-bottom, margin-left, and margin-right. These are defined as
    attributes of each `<fo:simple-page-master>` element.
-   Five **regions** of the print area: the region-body, the regions
    above (fo:region-before), below (fo:region-after), on the left
    (fo:region-start), on the right (fo:region-end). Regions are defined
    as separate elements containing attributes “region-name” and
    “extent”.
-   The region-body can have the **margins** of its own, which are free
    from printing: margin-top, margin-bottom, margin-left, margin-right.
    These are defined as attributes of `<fo:region-body>` element.

The text is thus “wrapped” by three margins on each side, two of which
are not printed on and one containing header and footer.

The layout the three page-master types – **front_matter** ,
**body_matter_odd** , and **body_matter_even** – is identical:

-   Page margins:
    -   margin-top=“1.8cm”
    -   margin-bottom=“1.8cm”
    -   margin-left=“1.5cm”
    -   margin-right=“1.5cm”
-   Regions of the print area:
    -   <fo:region-before extent="1.8cm"/>
    -   <fo:region-after extent="0.5cm"/>
    -   <fo:region-start extent="0cm"/>
    -   <fo:region-end extent="0cm"/>
-   Margins of the region-body:
    -   margin-top=“1.5cm”
    -   margin-bottom=“1.3cm”
    -   margin-left=“1.5cm”
    -   margin-right=“1.5cm”

We thus have the top margin of 5,1 cm (1.8cm + 1.8cm + 1.5cm) in which
the header is placed; at the bottom we have a margin of 3,6 cm (1.8cm +
0.5cm + 1.3cm) in which the page numbers are situated; on the left and
right there are margins of 3 cm each (1.5cm + 0cm + 1.5cm).

The layout of frontspiece is different in that it only has page margins
of 1 cm on each side:

-   Page margins:
    -   margin-top=“1cm”
    -   margin-bottom=“1cm”
    -   margin-left=“1cm”
    -   margin-right=“1cm”

##### 5.1.2. Page sequence masters

Page sequence masters bundle together page masters **body_matter_odd**
and **body_matter_even** , applying them to odd and even pages
respectively.

    <fo:page-sequence-master master-name=" body_matter">
    <fo:repeatable-page-master-alternatives>
    <fo:conditional-page-master-reference master-reference="body_matter_odd" odd-or-even="odd"/>
    <fo:conditional-page-master-reference master-reference="body_matter_even" odd-or even="even"/>
    </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

------------------------------------------------------------------------

### 5.2. Page sequences (<fo:page-sequence>)

The second type of information contained in <fo:root> is the assignment
of the previosely defined page and page sequence masters to the
components of a print edition. This is done with a set of
<fo:page-sequence> elements. We have nine components in total using four
page masters:

|     |                                |                                                    |                                                                                                                |
|-----|--------------------------------|----------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| N   | Print edition component        | Master used                                        | Description                                                                                                    |
| 1   | “Half title” or “Schmutztitel” | <fo:page-sequence master-reference="front_matter"> | The cover page of the print edition, containing the short title of the work and the name of its author.        |
| 2   | “Frontispiece”                 | <fo:page-sequence master-reference="frontispiece"> | Frontispiece shows the scan of the title page of the original.                                                 |
| 3   | “Title page of print edition”  | <fo:page-sequence master-reference="front_matter"> | A custom title page of the print edition (usually two pages).                                                  |
| 4   | “Edition notice”               | <fo:page-sequence master-reference="front_matter"> | Edition notice stating that pdf edition does not render the layout of the original print.                      |
| 5   | “Title page of the original”   | <fo:page-sequence master-reference="front_matter"> | Title page of the original rendered from <tei:titlePage> element of <tei:front>.                               |
| 6   | “Introduction section”         | <fo:page-sequence master-reference=" body_matter"> | Introduction section rendered from the <tei:div> elements of <tei:front>. At this point the pagination starts. |
| 7   | “Main content section”         | <fo:page-sequence master-reference=" body_matter"> | Main content section rendered from <tei:body>.                                                                 |
| 8   | “Concluding section”           | <fo:page-sequence master-reference="body_matter">  | Concluding section rendered from <tei:back>.                                                                   |
| 9   | “End notes section”            | <fo:page-sequence master-reference=" body_matter"> | Endnotes section rendering the marginal notes.                                                                 |

As we see, the page masters **front_matter** and **frontispiece** are
addressed directly, while **body_matter_odd** or **body_matter_even**
are addressed through sequence master **body_matter**. XSL allows to
wrap the `<fo:page-sequence>` within the `<xsl:template match="...">`
instruction. In this case the page sequence will be implemented whenever
a certail XML element is matched. W0037_Vol01, for example, contains two
title pages - one for the volume series and one for a single volume
(https://projekte.adwmainz.net/issues/6515). Thus the component 5 of the
print edition (“Title page”) should be repeated:

     
    <xsl:apply-templates select="//tei:titlePage"/> ....
    <xsl:template match="//tei:titlePage">
        <fo:page-sequence master-reference="front_matter">
            <fo:flow flow-name="xsl-region-body">       
                <fo:block text-align="center" font-size="30pt" font-weight="bold" space-before="10mm">
                    <xsl:apply-templates/>
                </fo:block>         
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

In contrast, one or more components can be missing. For example, in
W0013_Vol02 “Introduction” section is absent (`<tei:front>` contains
only the title page, but no text, i.e. no `<tei:div>` ). This affects
the pagination, which should start from `<tei:body>`. Therefore the
sequences rendering components 6 (Intro) and 7 (body) depend on the
condition:

     
    <xsl:choose>
    <xsl:when test="//tei:text/tei:front/tei:div">
    <fo:page-sequence master-reference="body_matter" initial-page-number="1">...
    <xsl:otherwise>
    <fo:page-sequence master-reference="body_matter" initial-page-number="1">...

In a similar vein the presence or absence of the components 8
(“Concluding section”) and 9 (“End Notes section”) is caught up by the
conditions:

     
    <xsl:if test="//tei:text/tei:back">
    <fo:page-sequence master-reference="body_matter">...
    <xsl:if test="//tei:text//tei:note">
    <fo:page-sequence master-reference="body_matter">

------------------------------------------------------------------------

## 6. Templates matching different types of “tei:p” element.

------------------------------------------------------------------------

## 7. Templates matching “tei:front”, “tei:body” and “tei:back” elements.

------------------------------------------------------------------------

## 8. Templates expanding “tei:abbr”, “tei:orig” and “tei:sic” elements.

------------------------------------------------------------------------

## 9. Templates expanding special characters.

------------------------------------------------------------------------

## 10. Templates dealing with page, column and line breaks.

------------------------------------------------------------------------

## 11. Templates dealing with marginal notes.

------------------------------------------------------------------------

## 12. Templates dealing with tables.

------------------------------------------------------------------------
