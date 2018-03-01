# The School of Salamanca - The Web Application

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1186521.svg)](https://doi.org/10.5281/zenodo.1186521)

This software package provides a XML/TEI-based digital edition environment. It has been developed as the central element of the web presence of the project of the project "[The School of Salamanca. A digital collection of sources and a dictionary of its juridical-political language](https://www.salamanca.school)" of the [Academy of Sciences and of Literature at Mainz](https://www.adwmainz.de/), Germany. It is meant to be deployed as an application package within [eXist-db](https://exist-db.org/) and it draws upon a series of further services described in more detail below. The data files as well as other parts of the infrastructure will be published separately.


## Features

Some of the particular features of this software are the following:

* **Segmentation** of html files: Since the works in our edition are in some cases rather large, for the reading view we can not render them on-the-fly, but we do so in advance, and in the process we split them into a series of html segments that are dynamically loaded as one scrolls down ("infinite scrolling"). This makes things such as linking and cross-referencing somewhat more complicated and we have spent some effort to compensate for that. (The level at which the segmentation is done is configurable for each work individually via XML processing instructions. In this way, editors some measure of control over the size of the resulting chunks of text.)

* **Citation Links for sections**: At all levels of text above and beginning with paragraphs, context menus are provided (indicated with a "pointing hand" icon) that offer canonical links to the respective passage. These links are subject to a content negotiation mechanism delivering a plaintext, html or rdf (or, if applicable, image) representation of the passage, depending on the requesting client's capacities. (Pdf and other formats are on the roadmap.)

* **Lemmatized fulltext search**: The "Salamanca" web application provides a search function that, when searching for "lex" also delivers results containing "leges", "legum", "legibus" etc. We have achieved this with outsourcing search from eXist-db to a [Sphincsearch](http://sphinxsearch.com/) server that lemmatizes texts based on a ditionary (which we are continuously imrproving).

* **Microservices architecture**: Some of the application's functions are implemented as clients requesting data from dedicated services. Navigation between passages (in part) relies on the id service described above, search relies on an [OpenSearch](http://www.opensearch.org/)-compatible search service, image viewing relies on an [iiif](http://iiif.io/)-conforming image and manifest service etc. For the environment that this application expects, see below.


## Environment

Configuration is concentrated in a single file modules/config.xqm. This file is one of the things you will want to customize when you intend to launch the software yourself. However, at (https://www.salamanca.school), the application is also integrated with the following other servers:

* an iiif-conformant image server (iiif image and presentation APIs)
* a any23 service rendering rdf information in a desired serialisation
* a sphinxsearch search server, accessed via an opensearch-compatible php interface
* a wordpress blog


## Caveats/provisos

While we consider some aspects of the software sufficiently consolidated and tests to offer them for public review, criticism and re-use, we are well aware that some other areas urgently need to be taken care of. This concerns, among others:

* Improve documentation - inline documentation (code comments) as well as separate description of the app's workings need improvement
* Clean up code - a lot of obsolete code has not been commented out, let alone removed. This also concerns files (i.e. obsolete javascript libraries or xslt stylesheets). Also, not all occurrences of hardcoded, salamanca-specific information has been moved to the one single modules/config.xqm or the localisation files at data/i18n, where such things should reside.
* Performance - when we are satisfied with everything, we want to minify js and css code. But we also have to revise the application more generally in terms of performance. In some cases, caching routines can certainly help (in the case of the rdf lifting service, we have started working on this, but it's not working properly right now.)
* Error handling can certainly be done in a more orderly way...


## License

This software is published under the MIT license:

Copyright 2018 Ingo Caesar, David Glück, Andreas Wagner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
