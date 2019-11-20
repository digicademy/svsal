# The School of Salamanca - The Web Application, Technical Documentation

This is the core technical documentation for the web application "The School of Salamanca", available at <https://github.com/digicademy/svsal> and online at <https://www.salamanca.school/>.

## Parts and Services

The whole portal consists of several different services that are integrated in one UI:

1. An eXist-db database with xquery modules and xslt stylesheets
1. An eXist-db database with xml source files and derived rdf+xml and manifest files
1. A Wordpress instance for the blog (LAMP)
1. A Digilib image server for display of facsimile images
1. A Sphinxsearch search server, addressed via the open-sphinxsearch API (php)
1. For the time being a ftp webspace for other image downloads
1. A rdf4j triple store and SPARQL endpoint (which is momentarily down)
1. An any23 server used during extraction of rdf from TEI/xml (using [xtriples](https://github.com/digicademy/xtriples))

![Datastores and services](images/datastores.png)

The User interface itself is plain HTML, with jquery, bootstrap and a few javascript addons. It is normally loaded by the user's browser contacting the main exist-db server.

### Fileserver / Data Repositories

Let's start with the hosting of source and derivative files. Besides the application server described below, we have isolated our source files to a separate repository. (At the moment, this is hosted as an independent eXist-db application on the main applications' server, but ideally, we could make it possible that it be hosted even on a different machine.) The so-called "svsal-tei" package comprises the digital collection's and dictionary's source files, divided into the following subcollections:

* authors
* lemmata
* meta (holds files with general and technical information, partially being xincluded in the works xml files)
* workingpapers
* works

For ease of deployment, derivative data (such as rdf and iiif files) are stored in a separate "svsal-webdata" package, which currently contains the following subdirectories:

* corpus-zip (hosting all files of the collection's corpus in a specific format, such as txt or TEI xml, in compressed form)
* html
* iiif
* index (containing registers of nodes in the TEI files, which foremost are used internally for data processing and querying)
* rdf
* snippets (for Sphinxsearch)
* txt (plain text files for works)


In fact, throughout the application, these folders/collections are addressed via the following variables, defined in _modules/config.xql_:

* `$config:tei-root`
  * `$config:tei-authors-root`
  * `$config:tei-lemmata-root`
  * `$config:tei-workingpapers-root`
  * `$config:tei-works-root`

and

* `$config:webdata-root`
  * `$config:iiif-root`
  * `$config:rdf-root`
  * ...


### Main server application

(Almost all of the application's configuration happens at _modules/config.xqm_, however it will not be covered in one isolated place but rather in the respective context where settings play their roles.)

When a request arrives at the eXist-db service (more exactly, at the jetty service who is configured to forward it to the eXist-db applet), it is being handled by the central _controller.xql_ xquery file in the svsal app. The controller then routes the request, deciding which piece of code should handle it. This can happen based on a couple of factors: server or path components (like in <https://api.salamanca.school/codesharing/codesharing.html>), filename extensions (like in <https://www.salamanca.school/iiif-out.xql?wid=W0014>), full resource names (like in <https://www.salamanca.school/favicon.ico> or <https://www.salamanca.school/robots.txt>) or a content negotiation mechanism (like in <https://id.salamanca.school/works.W0015:p23>).

While most of the requests for *.html files are forwarded to _modules/view.xql_, we forward a couple of them to _modules/view-admin.xql_ which does the same rendering job of merging html with db requests and functions (see below) except it also sources _modules/admin.xql_ so that the functions in that file are accessible from the admin html files.

#### Preparing Sources

##### Rendering HTML

##### Rendering search snippets

##### Creating iiif manifest files

##### Creating rdf triples

#### Viewing

#### Searching

### Search server
