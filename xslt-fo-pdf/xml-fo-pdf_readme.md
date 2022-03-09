# The School of Salamanca - XML to PDF

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1186521.svg)](https://doi.org/10.5281/zenodo.1186521)

Text

## Header

Text

* **Text**: Text 
* **Citation Links for sections**: Text
* **Lemmatized fulltext search**: Text
* **Microservices architecture**: Text

## Header

Text

* text
* text
* text
* text

## Header

Text

* Text
* Text
* Text
* 
## Header

Text

We used a markup standard called XSL-FO for "Formatted Objects" 

- in Exist DB: using XSL-FO Xquery module  (The Apache FOP processor (free open source) https://en.wikibooks.org/wiki/XQuery/Installing_the_XSL-FO_module
- in Oxygen: using built-in Apache FOP

Not used: 

- CSS-based processors, such as Oxygen PDF Chemistry. 


The steps required to generate a PDF document are:

-    retrieve the base XML document
-    transform XML file to XSL-FO markup using XSL
-    transform the XSL-FO to PDF using the free Apache FOP 


The XSL file: 

- Fonts used: Junicode, Antinoou (for Greek characters), SBL Hebrew (for Hebrew)
- Structure: 
	First the layout is described: 
- Descriction of the layout (fo:layout-master-set), 4 types in total: 
	"Scmutztitel" page  (master-name="start")
	Title page (contains the title picture only, master-name="pics")
	Odd pages (master-name="chapsOdd", identical to even pages, but used for different header and footer) 
	Even pages (master-name="chapsEven", identical to even pages, but used for different header and footer)

repeatable-page-master-alternatives
                        <fo:conditional-page-master-reference master-reference="chapsEven" odd-or-even="even"/>
