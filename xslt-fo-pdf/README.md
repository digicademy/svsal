# XSL-FO Template description

## 1. General info

    Repository location: https://github.com/digicademy/svsal/tree/master/xslt-fo-pdf
    Contents: 
        ./Fonts: fonts for Greek, Hebrew and Arab characters
        ./PDF_Output: PDF output files
        "WORK.xml": released XML files taken from "Salamanca SVN/svsal-tei/works"
        "specialchars.xml" and "works-general.xml": copies of the files located at http://files.salamanca.school/works-general.xml and http://files.salamanca.school/specialchars.xml             
        XSL template: "generic_template.xsl" 

“Generic_template.xsl” is an XSL stylesheet containing processing
instructions for the Saxon engine (used by Oxygen XML Editor), which
transforms a source XML file to a XML-FO format. This file is picked up
by the Apache FO processor (freely available and also integrated in
Oxygen) and converted to PDF:

-   Source XML \>\>\> Saxon transformer \>\>\> XML-FO \>\>\> Apache FOP
    \>\>\> PDF Output

“Generic_template.xsl” is tailored to Salamanca TEI XML and is based on
the encoding conventions outlined in the [edition
guidelines](https://www.salamanca.school/en/guidelines.html). PDF
creation is integrated in Salamanca’s QA and is used as quality control
tool, checking the consistency of XML encoding across different works
and volumes. The results of these tests are documented on a separate
[wiki-page](https://projekte.adwmainz.net/projects/04-39/wiki/PDF-Ausgabe).

The following article provides a detailed description of the XSL
stylesheet’s constitutive elements:

-   Attributes of `<xsl:stylesheet>` and `<xsl:output>` method
-   `<xsl:variables>` and `<xsl:keys>`
-   `<xsl:templates>`

------------------------------------------------------------------------

## 2. Attributes of `<xsl:stylesheet>` element and `<xsl:output>` method.

The attributes of the root element `<xsl:stylesheet>` define the
namespaces used: FO (Formatting Objects), TEI, XS (XML Schema), RX
(RenderX XEP), plus a custom IMG namespace referring to the element
`<img:images>` within the same stylesheet. The value of attribute
“indent” in `<xsl:stylesheet>` is set to “no” as Apache FOP transformer
had problems with the indented files.

    <xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:rx="http://www.renderx.com/XSL/Extensions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:img="img:img">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>

------------------------------------------------------------------------

## 3. Variables and keys.

Four `<xsl:variables>` are defined:

        <xsl:variable name="images" select="document('')/*/img:images"/>            
        <xsl:variable name="guidelines" select="document('http://files.salamanca.school/works-general.xml') "/>
        <xsl:variable name="specialchars" select="document('http://files.salamanca.school/specialchars.xml') "/>
        <xsl:variable name="work_id" select="tei:TEI/@xml:id"/>

`$Images` refers to the section `<img:images>` within the XSL stylesheet
itselt, which lists the URLs of the source images of the title pages
along with the proposed citation. Each time a new work is published this
section should be extended with the work’s information, e.g.:

    <image xml:id='W0001_Vol01' citation="Avendaño, Thesaurus Indicus, Vol. 1 (2019 [1668])">
       <source>https://facs.salamanca.school/W0001/A/W0001-A-0006.jpg</source>
    </image>

Variables `$guidelines` and `$specialchars` refer to the external
documents containing encoding guidelines and special characters.
`$Guidelines` deliver metadata information, `$specialchars` contain the
standardized version of the special characters to be expanded. If
Salamanca’s production server is down, the copies of these files located
in the current
[repository](https://github.com/digicademy/svsal/tree/master/xslt-fo-pdf)
can be used. The paths of `$guidelines` and `$specialchars` should be
adopted accordingly. `$work_id` contains the ID of the volume to be
transformed.

`<xsl:keys>` are used to store the key-value pairs of image paths and
special characters, where @`name` is the name of the key list containing
entries with @`xml:ids` as keys with corresponding values delivered by
@`match="//tei:char"` and @`match="//image"`.

        <xsl:key name="title_image" match="//image" use="@xml:id"/>
        <xsl:key name="chars" match="//tei:char" use="@xml:id"/>

The values are retrieved by addressing the name of the key list
(“title_image” or “chars”) and @`xml:id` of the entry:

    <xsl:value-of select="$images/key('title_image', $work_id)/source/text()" />

------------------------------------------------------------------------

## 4. XSL templates

The document contains the instructions for the transformer formulated in
a series of templates `<xsl:template match="tei:element">`, triggered
when a certain XML element is matched. Active templates contain
`<xsl:apply-templates/>` instruction, while deactivated templates (i.e.
referring to the XML elements to be ignored) are empty (e.g.
`<xsl:template match="tei:teiHeader"/>`).

In the following the description of the most important templates will be
given, organized thematically in sections:

-   (§5.) Template matching the root of the XML document
    (`<xsl:template match="/">`).
    -   (§5.1.) Page and sequence masters (`<fo:layout-master-set>`).
    -   (§5.2.) Page sequences (`<fo:page-sequence>`).
    -   (§5.3.) Components of page sequences.
-   (§6.) Templates dealing with text mark-up.
-   (§7.) Templates expanding special characters.
-   (§8.) Templates dealing with line and page breaks.
-   (§9.) Templates dealing with marginal notes and cross-references.
-   (§10.) A complete list of the templates.

------------------------------------------------------------------------

## 5. Template matching the root of XML document (`<xsl:template match="/">`)

`<xsl:template match="/">` creates the `<fo:root>` with the following
attributes:

-   @`xmlns:fo="http://www.w3.org/1999/XSL/Format"`
-   @`font-selection-strategy="character-by-character"`
-   @`font-family="Junicode, Antinoou, SBL Hebrew"`
-   @`xmlns:rx="http://www.renderx.com/XSL/Extensions"`

Font families listed here are responsible for rendering the Greek,
Hebrew and Arab characters and should be installed in the system.

`<fo:root>` element contains two types of information:

-   It defines different page layouts and their sequences through
    “master sets” (`<fo:layout-master-set>`).
-   It assigns the page layouts and their sequences to print edition
    components through “master references”
    `<fo:page-sequence master-reference="xxx">`.

------------------------------------------------------------------------

### 5.1. Page and sequence masters (`<fo:layout-master-set>`)

The first element in `<fo:root>` is `<fo:layout-master-set>` describing
the so-called “masters” — page layouts of the print edition and their
sequences:

-   `<fo:simple-page-master master-name="body_matter_even">` — defines
    page layouts.
-   `<fo:page-sequence-master master-name="body_matter">` — defines the
    sequences of the layouts.

The canons of Western book page design place the center of the page area
above the center of the page, in addition the gutter (internal) margin
is traditionally narrower than the fore-edge (external) margin. As our
publication is supposed to be printed or viewed as A4 pages
(page-height=“29.7cm” page-width=“21cm”), we simplified this layout,
defining identical gutter and fore-edge margins.

------------------------------------------------------------------------

#### 5.1.1. Page masters

There are four page masters:

-   `<fo:simple-page-master master-name="front_matter">`.
-   `<fo:simple-page-master master-name="frontispiece">`.
-   `<fo:simple-page-master master-name="body_matter_odd">`.
-   `<fo:simple-page-master master-name="body_matter_even">`.

We define separate layouts for odd and even pages, because they contain
different information in the header and the footer. Odd pages contain
the author name centered in the header and page number in the footer
flush-right. Even pages contain the short title of the book centered in
the header and page number in the footer flush-left. Each of the above
page masters contains the following properties:

-   The page and its non-printable margins defined as attributes of
    `<fo:simple-page-master>`: *`margin-top_, _`margin-bottom*,
    *`margin-left_, and _`margin-right*.
-   Five regions of the print area defined as elements
    `<fo:region-body>`, `<fo:region-before>` (i.e. above),
    `<fo:region-after>` (i.e. below), `<fo:region-start>` (i.e. on the
    left), and `<fo:region-end>` (i.e. on the right), containing
    attributes @`region-name` and @`extent`.
-   Element `<fo:region-body>` can have its own non-printable margins
    set with attributes @`margin-top`, @`margin-bottom`, @`margin-left`,
    and @`margin-right`.

The text is thus “wrapped” with three margins on each side: two
non-printable and one containing header and footer.

The layout the three page-master types – *front_matter* ,
*body_matter_odd* , and *body_matter_even* – is identical:

-   Page margins:
    -   @`margin-top`=“1.8cm”
    -   @`margin-bottom`=“1.8cm”
    -   @`margin-left`=“1.5cm”
    -   @`margin-right`=“1.5cm”
-   Regions of the print area:
    -   `<fo:region-before extent="1.8cm"/>`
    -   `<fo:region-after extent="0.5cm"/>`
    -   `<fo:region-start extent="0cm"/>`
    -   `<fo:region-end extent="0cm"/>`
-   Margins of the region-body:
    -   @`margin-top`=“1.5cm”
    -   @`margin-bottom`=“1.3cm”
    -   @`margin-left`=“1.5cm”
    -   @`margin-right`=“1.5cm”

The top margin thus sums up to 5,1 cm (1.8cm + 1.8cm + 1.5cm) in which
the header is placed; the bottom margin totals 3,6 cm (1.8cm + 0.5cm +
1.3cm) in which the page numbers are situated; on the left and right
there are margins of 3 cm each (1.5cm + 0cm + 1.5cm).

The layout of the page-master type *frontispiece* is different in that
it only has page margins of 1 cm on each side:

-   Page margins:
    -   @`margin-top`=“1cm”
    -   @`margin-bottom`=“1cm”
    -   @`margin-left`=“1cm”
    -   @`margin-right`=“1cm”

------------------------------------------------------------------------

#### 5.1.2. Page sequence masters

Page sequence masters bundle together page masters for odd
(*body_matter_odd*) and even (*body_matter_even*) pages.

    <fo:page-sequence-master master-name="body_matter">
    <fo:repeatable-page-master-alternatives>
    <fo:conditional-page-master-reference master-reference="body_matter_odd" odd-or-even="odd"/>
    <fo:conditional-page-master-reference master-reference="body_matter_even" odd-or-even="even"/>
    </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

------------------------------------------------------------------------

### 5.2. Page sequences (`<fo:page-sequence>`)

The second type of information contained in `<fo:root>` is the
assignment of the defined page and page sequence masters to the
components of a print edition. This is done with a set of
`<fo:page-sequence>` elements. Salamanca’s print edition consists of
nine components using four page masters:

|     |                                |                                                      |                                                                                                                     |
|-----|--------------------------------|------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| N   | Component of a print edition   | Master used                                          | Description                                                                                                         |
| 1   | “Half title” or “Schmutztitel” | `<fo:page-sequence master-reference="front_matter">` | Cover page of the print edition, containing the short title of the work and the name of its author.                 |
| 2   | “Frontispiece”                 | `<fo:page-sequence master-reference="frontispiece">` | Frontispiece shows the scan of the title page of the original.                                                      |
| 3   | “Title page of print edition”  | `<fo:page-sequence master-reference="front_matter">` | A custom title page of the print edition (usually two pages).                                                       |
| 4   | “Edition notice”               | `<fo:page-sequence master-reference="front_matter">` | Edition notice stating that PDF edition does not render the layout of the original.                                 |
| 5   | “Title page of the original”   | `<fo:page-sequence master-reference="front_matter">` | Title page of the original rendered from `<tei:titlePage>` element of `<tei:front>`.                                |
| 6   | “Introduction section”         | `<fo:page-sequence master-reference=" body_matter">` | Introduction section, rendered from the `<tei:div>` elements of `<tei:front>`. At this point the pagination starts. |
| 7   | “Main content section”         | `<fo:page-sequence master-reference=" body_matter">` | Main content section rendered from `<tei:body>`.                                                                    |
| 8   | “Concluding section”           | `<fo:page-sequence master-reference="body_matter">`  | Concluding section rendered from `<tei:back>`.                                                                      |
| 9   | “End notes section”            | `<fo:page-sequence master-reference=" body_matter">` | Endnotes section rendering the marginal notes.                                                                      |

Thus, page masters *front_matter* and *frontispiece* are addressed
directly, while *body_matter_odd* and *body_matter_even* are addressed
through sequence master *body_matter* described in §5.1.2. Placing
`<fo:page-sequence>` within the `<xsl:template match="...">` instruction
allows implementing it whenever a certain XML element is matched. This
is the case with W0037_Vol01, which contains two title pages - one for
the volume series and one for a single volume.

Alternatively, one or more components can be missing. For example, in
W0013_Vol02 “Introduction” section is absent (`<tei:front>` contains
only the title page, but no `<tei:div>`, i.e. no text). This affects the
pagination, which should start from `<tei:body>`. Therefore the
sequences rendering components 6 (Intro) and 7 (body) depend on the
condition:

     
    <xsl:choose>
        <xsl:when test="//tei:text/tei:front/tei:div">
            <fo:page-sequence master-reference="body_matter" initial-page-number="1">
                <xsl:apply-templates select="//tei:front"/>...
        <xsl:otherwise>
            <fo:page-sequence master-reference="body_matter" initial-page-number="1">
                <xsl:apply-templates select="//tei:body"/>...
    </xsl:choose>

In a similar vein the presence or absence of the components 8
(“Concluding section”) and 9 (“End Notes section”) is caught up by the
conditions:

     
    <xsl:if test="//tei:text/tei:back">
        <fo:page-sequence master-reference="body_matter">
            <xsl:apply-templates select="//tei:back"/>...
    <xsl:if test="//tei:text//tei:note">
        <fo:page-sequence master-reference="body_matter">
            <xsl:apply-templates select="//tei:text" mode="make-endnotes"/>...

------------------------------------------------------------------------

### 5.3. The components of page sequences

Each `<fo:page-sequence>` contains elements generating static and
dynamic content: `<fo:static-content>` and `<fo:flow>`. While the former
can be missing, the latter is obligatory. `<fo:static-content>`
populates headers and footers, while `<fo:flow>` fills the text area.
The components of print edition 1, 2, 3, 5, which do not need headers
are footers, contain `<fo:flow flow-name="xsl-region-body">` only.
Components with headers and footers (4, 6, 7, 8, 9) employ
`<fo:static-content>`, which deliver different contents for odd and even
pages. Note that `<fo:static-content>` has to be defined before
`<fo:flow>`, even if it refers the bottom part of the page (footers):

    <fo:page-sequence master-reference="body_matter">
    <fo:static-content flow-name="body_matter_odd-region-before"> ...
    <fo:static-content flow-name="body_matter_even-region-before"> ...
    <fo:static-content flow-name="body_matter_odd-region-after"> ...
    <fo:static-content flow-name="body_matter_even-region-after"> ...
    <fo:flow flow-name="xsl-region-body">

`<fo:flow>` generates the text area, drawing it as a one-column table
where each `<fo:div>` element constitutes two rows:

1.  The first row contains `<div n="...">` (chapter number).
2.  The second row delivers the contents of
    `<xsl:template match="tei:div">`.

The cell dimensions are provided by the upper row:

    <fo:flow flow-name="xsl-region-body">
        <fo:block>
            <fo:table>
                <fo:table-body>
                    <xsl:apply-templates select="//tei:front"/>...
    <xsl:template match="tei:front | tei:body | tei:back">
        <xsl:call-template name="process_div"/>
    <xsl:template name="process_div">
        <xsl:for-each select="./tei:div">
            <xsl:variable name="div_id" select="@xml:id"/>
            <fo:table-row border-style="solid" border-width="0.1mm">

Originally the table design was intended to render the marginal notes:
the main text was placed in the left column, marginal notes in the right
column. After having decided to print marginal notes as end notes, we
have just one column for the main text. Its borders are deactivated but
can be activated to control the margins.

------------------------------------------------------------------------

## 6. Templates dealing with text mark-up.

There are three templates dealing with `<p>` element, whose design
depends on its ancestors:

-   Generic `<xsl:template match="tei:p">`
-   `<xsl:template match="//tei:argument//tei:p">`
-   `<xsl:template match="//tei:note//tei:p">`

Abbreviations, printing errors and special characters are encoded within
`<choice>` element. Their treatment also depends on their ancestors:

    <xsl:template match="tei:choice">
        <xsl:choose>
            <xsl:when test="(ancestor::tei:head) or (ancestor::tei:titlePart)">
                <xsl:choose>
            <xsl:when test="(ancestor::tei:note)">
                <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" />
            </xsl:when>
                <xsl:otherwise>
                <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" mode="bold"/>
            </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" />
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

There are four templates dealing with different types of highlighting:

-   `<xsl:template match="tei:hi[`rendition eq ‘#initCaps’\]“>@
-   `<xsl:template match="tei:hi[`rendition=‘#r-center’ and
    not(ancestor::tei:head)\]“>@
-   `<xsl:template match="tei:hi[`rendition eq ‘#sup’\]“>@
-   `<xsl:template match="tei:hi[`rendition eq ‘#it’\]“>@

## 7. Templates expanding special characters.

Template `<xsl:template match="tei:g">` is responsible for expanding
special characters. Currently only two special characters are treated:

    <char xml:id="char017f">
        <desc>LATIN SMALL LETTER LONG S</desc>
        <charProp>
            <unicodeName>entity</unicodeName>
            <value>slong</value>
        </charProp>
        <mapping type="precomposed">ſ</mapping>
        <mapping type="standardized">s</mapping>
    </char>

    <char xml:id="char204a">
        <desc>LATIN ABBREVIATION SIGN SMALL ET</desc>
        <charProp>
            <unicodeName>entity</unicodeName>
            <value>et</value>
        </charProp>
        <mapping type="precomposed">⁊</mapping>
        <mapping type="standardized">et</mapping>
    </char>

The template checks for characters with @`xml:id="char017f"` and
@`xml:id="char204a"`, gets their standardized variants from the
`specialchars.xml` file and exchanges the current value with the
standardized one in the text-flow. If the ancestors of `<g>` are
`<head>` or `<titlePart>` the characters are marked bold.

------------------------------------------------------------------------

## 8. Templates dealing with line and page breaks.

Line and page breaks in the original do not correspond to line and page
breaks in the PDF edition. Their correct rendering depends on whether
they coincide with word breaks, and if yes, whether this is expressed
with a hyphen in the original. The element `<lb>` thus has two
attributes: @`rendition="#hyphen/#noHyphen"` and @`break="yes/no"`. We
established the following rules for XSLT:

|                                                                |                                                                                               |                                                                                                                                     |
|----------------------------------------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `<lb>`                                                         | XML example                                                                                   | XSLT                                                                                                                                |
| @`break="no"`: word continues, original with or without hyphen | `le<lb break="no" rendition="#hyphen"/>gum` or `Mo<lb break="no" rendition="#noHyphen"/>lina` | These `<lb>` are ignored, they contain no white spaces, and no newlines                                                             |
| @`break="yes"`: new word comes after `<lb>`                    | `/n<lb/>testimonias` or `/n<lb break="yes"/>pro`                                              | These <lb> are also ignored, because the formatter renders `/n` “newline” with a white space anyway                                 |
| @`break="yes"`: new word comes after `<lb>`                    | `um<lb break="yes"/>ff. deo`                                                                  | When `<lb>` is a part of `<note>` there is usually no `/n` “newline” and no white space in XML. We insert white space in this case: |

    <xsl:template match="tei:lb[not(@break eq 'no')]">
        <fo:inline>
            <xsl:text xml:space="preserve"> </xsl:text>
        </fo:inline>
    </xsl:template>

Page break is always followed by a line break, and carries attributes
@`n=...` @`facs="facs:..."`, referring to the page number and a
corresponding facsimile. The former is rendered in PDF and inserted in
the text flow in squared brackets. In addition `<pb>` may also have
attributes @`rendition="#hyphen/#noHyphen"` and @`break="yes/no"`, in
which case the former should not be encoded in `<lb>`:

\> Hyphens occurring at the end of lines are not retained in the text,
but encoded by means of an attribute `rendition="#hyphen"` within the
respective `lb` element. In the event of several immediately consecutive
breaks (e.g., `pb` + `cb` + `lb`) this attribute is only set within the
first such break (element).
(https://www.salamanca.school/en/guidelines.html#hyphenation)

Another attribute `<pb `sameAs>@ signals that page break occurs in the
marginal note and should be ignored. Considering the fact that white
space treatment is taken over by `<lb>`, `<pb>` considers only one case
@`break="no"`, in which case we insert a hyphen:

|                                                                |                                                                                                                                |                                |
|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| `<pb>`                                                         | XML example                                                                                                                    | XSLT                           |
| @`break="no"`: word continues, original with or without hyphen | `man<pb break="no" rendition="#hyphen"/><lb break="no" />do` or `teni<pb break="no" rendition="#noHyphen"/><lb break="no"/>do` | We insert hyphen in this case: |

    <xsl:template match="tei:pb[@n and not(@sameAs)]">
        <xsl:variable name="pb_id" select="@xml:id"/>
        <fo:inline font-style="normal" id="{$pb_id}">
            <xsl:choose>
            <xsl:when test="@rendition">-</xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </fo:inline>
        <fo:inline role="{@xml:id}" font-style="normal" font-weight="bold" font-size="12pt">
            <xsl:choose>
            <xsl:when test="@n">[<xsl:value-of select="@n"/>]</xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

------------------------------------------------------------------------

## 9. Templates dealing with marginal notes and cross-references.

Marginal notes in the original edition usually contain two elements:

-   The note proper on the page margin, encoded in XML with `<note>`
    element:
    `<note place="margin" n="d" anchored="true" xml:lang="la" xml:id="W0002-00-0019-nm-03ec">`
-   An anchor in text, marking the passage to which the note is related,
    encoded in XML with `<ref>` element, e.g.
    `<ref type="note-anchor" n="d" target="#W0002-00-0019-nm-03ec">`.
    Anchors can be represented by Latin numbers, letters or other
    characters. Sometimes anchor is missing and note is “floating” next
    to the paragraph it refers to.

Due to the fact that Apache FOP does not support “float” function, which
would allow the alignment between the text passage and the note on the
margin, we render all marginal notes as end notes. In addition, we
eliminate the distinction between anchored and non-anchored notes - all
anchors are sequentially enumerated with Arab numbers.

`<xsl:template match="//tei:note">` is responsible for setting the
anchor in text, while
`<xsl:template match="//tei:text" mode="make-endnotes">...<xsl:for-each select=".//tei:note">`
is rendering the endnotes. To guarantee the cross-referencing between
the anchor and the note, both elements are assigned an id and a link.
The id of the anchor is `# + xml:id` of the note, while note-id is just
the @`xml:id`.

While `<ref>` constituting a part of a marginal note is not interpreted,
`<ref>s` which are parts of lists (table of contents etc.) are rendered
and get a link, referencing the element in text they are related to:

    <xsl:template match="//tei:list//tei:ref[@target]">
        <xsl:variable name="input" select="translate(@target, '#', '')"/>
        <fo:inline space-before="0.2cm" space-after="0.2cm">
            <fo:basic-link internal-destination="{$input}" color="#0a0c75">
            <xsl:apply-templates/>
            </fo:basic-link>
            <xsl:text> </xsl:text>          
        </fo:inline>
    </xsl:template>

------------------------------------------------------------------------

## 10. A complete list of the templates.

The rest of the templates are self-explanatory. What follows is a
complete list of the templates of the XSL tranformation template:


    <xsl:template match="/">
    <xsl:template match="tei:sourceDesc">
    <xsl:template match="tei:orgName">
    <xsl:template match="tei:titleStmt/tei:editor">
    <xsl:template match="tei:sourceDesc//tei:msIdentifier">
    <xsl:template match="tei:repository">
    <xsl:template match="tei:idno">
    <xsl:template match="tei:titlePage">
    <xsl:template match="tei:titlePart">
    <xsl:template match="tei:byline">
    <xsl:template match="tei:argument">
    <xsl:template match="tei:docEdition">
    <xsl:template match="tei:docImprint">
    <xsl:template match="tei:imprimatur">
    <xsl:template match="tei:docDate">
    <xsl:template match="tei:front | tei:body | tei:back">
    <xsl:template match="tei:div">
    <xsl:template match="tei:head">
    <xsl:template match="tei:item">
    <xsl:template match="tei:list">
    <xsl:template match="tei:figure">
    <xsl:template match="tei:persName">
    <xsl:template match="tei:unclear">
    <xsl:template match="tei:placeName">
    <xsl:template match="//tei:text//tei:date">
    <xsl:template match="tei:milestone">
    <xsl:template match="tei:signed">
    <xsl:template match="tei:quote">
    <xsl:template match="tei:lg">
    <xsl:template match="tei:l">
    <xsl:template match="//tei:docDate">
    <xsl:template match="tei:figure">
    <xsl:template match="tei:p">
    <xsl:template match="//tei:argument//tei:p">
    <xsl:template match="//tei:note//tei:p">
    <xsl:template match="tei:hi[@rendition eq '#initCaps']">
    <xsl:template match="tei:hi[@rendition='#r-center' and not(ancestor::tei:head)]">
    <xsl:template match="tei:hi[@rendition eq '#sup']">
    <xsl:template match="tei:hi[@rendition eq '#it']">
    <xsl:template match="tei:choice">
    <xsl:template match="tei:expan | tei:reg | tei:corr" mode="bold">
    <xsl:template match="tei:expan | tei:reg | tei:corr">
    <xsl:template match="tei:g">
    <xsl:template match="//tei:list//tei:ref[@target]">
    <xsl:template match="tei:lb[not(@break eq 'no')]">
    <xsl:template match="tei:pb[@n and not(@sameAs)]">
    <xsl:template match="tei:cb">
    <xsl:template match="tei:space">
    <xsl:template match="//tei:note">
    <xsl:template match="//tei:text" mode="make-endnotes">
    <xsl:template match="tei:table">
    <xsl:template match="//tei:ref[@type='note-anchor']"/>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:fileDesc"/>
    <xsl:template match="tei:figure"/>
    <xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:note"/>
    <xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:extent"/>
    <xsl:template match="tei:titleStmt/tei:title[@type = 'main']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = 'main']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = '245a']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = 'short']"/>
    <xsl:template match="tei:notesStmt"/>
    <xsl:template match="tei:revisionDesc"/>
    <xsl:template match="tei:titleStmt"/>
