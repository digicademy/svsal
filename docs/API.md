# The School of Salamanca - The Web Application, API Documentation

This is the technical documentation for the API of the web application "The School of Salamanca",
available at <https://github.com/digicademy/svsal> and online at <https://www.salamanca.school/>.
The general API is accessible at <https://api.salamanca.school/>.

<div style="font-style: italic; text-align: right">(Last edited: David Glück, 2018-12-03)</div>

## Endpoints

Under <https://api.salamanca.school/v1>, we currently provide the single **/texts** endpoint.<sup id="anchor1">[1](#fn1)</sup>
Later on, this will be complemented by `/authors`, maybe even by `/concepts` endpoints,
but for the moment, **/texts** is the only one that responds with data.

For the time being, it is meant to be used with the id of a (complete or a part of an)
individual work, like **/texts/w0004**.

## Parts of texts

For parts of works, the **/texts** endpoint uses the following scheme to identify what
part of the work will be exposed:

In general the identifier is `{textId}[:{location}]`, where the location can be specified
in more detail. It can be either a page number or id, preceded by a `p` (e.g. "p23",
"pFOL3R"), or a section identifier in a hierarchical manner, e.g. "frontmatter.1",
"5.1", "vol2.3.11" etc. In this scheme, volumes are prefixed with "vol", footnotes or
marginal notes are prefixed with "n", and all other sections such as chapters,
subchapters, paragraphs etc. are rendered with plain numbers.
Pages are outside of the chapter hierarchy, but below an eventual volume or front- and
backmatter identifier, giving locations as "p53" (for a page in the body of a
single-volume work) and "vol2.frontmatter.p1" (for a page in the frontmatter of the second
volume of a multi-volume work).

Here are some example identificators:

* <https://api.salamanca.school/texts/w0004:pFOL7V>
* <https://api.salamanca.school/texts/w0013:vol1.1.1.n1>
* <https://api.salamanca.school/texts/w0013:vol2.frontmatter.p1>

(This way of identifying parts of texts is inspired by the
[Canonical Text Services](http://cite-architecture.github.io/ctsurn/overview/) specification,
but it diverges in some points, such as `http` instead of `urn` scheme and the eschewal of
collections, ranges and subreferences.<sup id="anchor2">[2](#fn2)</sup> Depending on user
feedback, we may implement this later.)

Furthermore, the `all` identifier, applicable instead of a normal `{textId}`, stands for 
the collection of all texts and, along with a mandatory format parameter, leads 
to a single resource containing all (currently available) texts in the respective format. 
At the moment, the only available parameter in this regard is `tei` (see below).

## Parameters

To the resource endpoint, a list of parameters can be appended with a question mark `?`  and
separated among themselves by an ampersand `&amp;`.
Among the possible parameters of the **/texts** endpoint, there are e.g.
`format`, `q`, `lang` or `viewer` parameters, where not all combinations make sense.
The parameters are explained in the following.

## Formats

The most important parameter is the `format` parameter that may take the following values:

* `tei` for [TEI P5](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/index.html) xml (this is also being redirected to from <https://tei.salamanca.school/>)
* `txt` for plaintext
* `rdf` for linked data (in [rdf/xml](https://www.w3.org/TR/rdf11-primer/) (this is also being redirected to from <https://data.salamanca.school/>)
* `html` for web views (this is also being redirected to from <https://www.salamanca.school/>)
* `iiif` for iiif [manifests](https://iiif.io/api/presentation/2.1/) and [image information](https://iiif.io/api/image/2.1/), depending on the actual resource being requested
* (in the future: `pdf` and `ebook` for ebook views, `mods` for METS/MODS XML)
* (also in the future, (some of) the endpoints will be enhanced with versioning/[memento](http://mementoweb.org/guide/howto/) negotiation)

Alternative to the `format` parameter, the result format can be determined also by [content
negotiation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation) if
the client signals to expect (via the [HTTP request's accept header](https://www.w3.org/Protocols/HTTP/HTRQ_Headers.html#z3))
the following mime types:

* `application/tei+xml` (recommended), `application/xml` or `text/xml` for TEI P5 xml
* `text/plain` for plaintext
* `application/rdf+xml` for rdf/xml
* `application/xhtml+xml` (recommended) or `text/html` for web views
* `image/jpeg` for images
* `application/ld+json; profile=http://iiif.io/presentation/3/context.json` for iiif manifests

Note that the `format` parameter takes precedence content negotiation.

## `id` uris

Taken without parameters and outside of a http exchange, uris
beginning with <https://id.salamanca.school/> are used to represent the abstract entities
that scholarly works or discourse concepts are. When resolved, these uris are redirected
to the api endpoints described above.

## Format-specific information

### TEI

The `tei` format reflects the sources that form the basis of all our information offers.
However, whereas in our persistence layer the works are sometimes split into several parts
to reflect the structure of multi-volume works or for technical reasons, and while some
information in the header is maintained in an external file, the API resolves all of this
internal complexity and delivers one complete and integral TEI file. Since the extraction
of parts of a work can result in invalid TEI or even malformed xml, the tei format
at the moment cancels an eventual location identifier and always presents whole works.

### Plaintext

The `txt` format offers an on-the-fly plaintext rendering of our texts.
Generally, this allows for rendering texts in two modes: constituted (default) and original,
which can be requested explicitly either by appending an `.edit` or an `.orig` to the text
identifier or by adding `mode` parameter with an `edit` or `orig` value. (Again, setting
the mode parameter explicitly takes precedence over the text suffix in the resource path.)

In *both* modes, whitespace is normalized (linebreaks are suppressed), paragraphs are
separated by blank lines, marginal notes are wrapped in braces (and preceded by some
whitespace: "`   {}`"). List items are prefixed with hashes or dashes (`#`/`-`), depending
on the list type being numbered or unnumbered.

In `orig` mode, milestones such as article boundaries are represented by either daggers,
asterisks or asterisks in brackets (`†`, `*`, `[*]`), depending on the way they appear in
the sources, whereas in `edit` mode, they are wrapped in brackets and eventually represented
by their editorial label (e.g. "`[article 12]`"). Also, in `edit` mode, sections that have
editorial labels get these wrapped in square brackets and asterisks ("`[ *` ... `* ]`"). 
Furthermore, in `edit` mode, terms or names of persons that are treated in the dictionary
get their dictionary lemma appended in brackets and arrow (e.g.
"`Los mandamientos de la ley diuina [→lex divina]: son diez ...`"). The same also holds
for citations where this does not refer to dictionary entries but may serve to find and
consolidate references to specific works.

Finally and obviously, in cases where there are an original and an edited text variant,
which of those two is being rendered depends on the mode, too. This applies to editorial
corrections, expansions of abbreviations and to normalizations.


### RDF

Similar to the `tei` format, whatever the specific part of a work was that semantic
information was requested for, the `rdf` format always returns the information for the
full text, which then contains the requested information (semantic web clients should
be able to cope with this).

The information delivered includes **metadata** about the work (such as title, author,
publisher etc.) using the [SPAR ontologies](http://www.sparontologies.net/) (in particular,
the [fabio ontology](http://www.sparontologies.net/ontologies/fabio)). **Structural
information** about front- and backmatter, chapters, paragraphs etc. (the type of entities,
a label and sometimes information on what other entity they are contained in) is recorded
using SPAR's [document component ontology
(doco)](http://www.sparontologies.net/ontologies/doco). Information about **citations and
references** to persons, places or other works is recorded using SPAR's
[citation typing ontology (cito)](http://www.sparontologies.net/ontologies/cito) and using
[schema.org's "Book" vocabulary](https://schema.org/Book).

We use the [getty thesaurus of geographic
names](http://www.getty.edu/research/tools/vocabularies/tgn/index.html), the ["gemeinsame
Normdatei" of the German National
Library](http://www.dnb.de/DE/Standardisierung/GND/gnd_node.html) and the [thesaurus of
the Consortium of European Research Libraries](https://data.cerl.org/thesaurus/_search)
as authority data sources.

Finally, information **about the dataset** as a whole (like provenance, authorship etc.)
is provided using the [VoID Vocabulary](https://www.w3.org/TR/void/). This information is
available on its own at <http://data.salamanca.school/void.ttl> and is linked to from all
individual resources.

When you are requesting data in RDF format, the additional URL parameter `nocache` allows
you to invalidate rdf information that has been stored and cached on the server and
to re-generate the information from the TEI files.

### HTML

The `html` format enables the following url parameters as well:

* `viewer` with an url-encoded url of a iiif canvas contained in the present work
to open the facsimile viewer also (on the respective page)
* `q` with a search term to be highlighted in the html
* `lang` to control the language of the user interface
* `mode` with either "orig" or "edit" to select viewing mode

Since the projects' source files are very huge in some cases, it was necessary to split
them and load them incrementally in the background. This makes a translation from
text/passage identifiers to html anchors necessary, and the html endpoint redirects
to <https://www.salamanca.school/work.html>, where the actual resource is constructed
from the parameters mentioned above, from the translation process and eventually from
environment factors like the browser's language preference settings.
This way,
<https://id.salamanca.school/works/w0015:20.2.4.10?q=milagro&amp;viewer=https://facs.salamanca.school/iiif/presentation/W0015/canvas/p14>
might finally resolve to
<https://www.salamanca.school/en/work.html?wid=w0015&amp;frag=0005_W0015-00-0016-d1-03ed&amp;q=milagro#W0015-00-0022-d4-03f7>.

**NOTE: At the moment (2018-11-07), the html endpoint cannot handle the *version* identifier of the work component of the passage identifier. It would need to translate this to an explicit `mode` url parameter (which can be handled), but it doesn't. This will be fixed soon.**

### iiif endpoint

<https://facs.salamanca.school/iiif/presentation/W0015/manifest>

## Notes

<b id="fn1">1</b> In the context of RESTful APIs, these endpoints respond to GET requests only, in other words, the resources are read-only. [↩](#anchor1)

<b id="fn2">2</b> Cf. <https://blog.salamanca.school/de/2016/11/15/whats-in-a-uri-part-1/>, also mentioning more literature. [↩](#anchor2)

## Sources

* Constantin, A., Peroni, S., Pettifer, S., Shotton, D., Vitali, F. (2016). The Document Components Ontology (DoCO). In Semantic Web – Interoperability, Usability, Applicability, 7 (2): 167-181. Amsterdam, The Netherlands: IOS Press. <https://doi.org/10.3233/SW-150177>
* Blackwell, Chr., Smith, N. (2014). The Canonical Text Services URN specification, version 2.0.rc.1 <http://cite-architecture.github.io/ctsurn_spec/> (retrieved 2018-10-31).
* Smith, N., Blackwell, Chr. W. (2012). "Four URLs, Limitless Apps: Separation of Concerns in the Homer Multitext Architecture". In Donum Natalicium Digitaliter Confectum Gregorio Nagy Septuagenario a Discipulis Collegis Familiaribus Oblatum: A Virtual Birthday Gift Presented to Gregory Nagy on Turning Seventy by His Students, Colleagues, and Friends. Washington D.C.: Center for Hellenic Studies <https://chs.harvard.edu/CHS/article/display/4846> (retrieved 2018-11-07).
