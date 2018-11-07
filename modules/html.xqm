xquery version "3.1";

(:~ 
 : HTML XQuery-Module
 : This module contains functions for building html code.
 :
 : - header and footer generation
 : - header/title and header/link elements
 : 
 : For doc annotation format, see
 : - https://exist-db.org/exist/apps/doc/xqdoc
 :
 : For testing, see
 : - https://exist-db.org/exist/apps/doc/xqsuite
 : - https://en.wikibooks.org/wiki/XQuery/XUnit_Annotations
 :
 : @author Andreas Wagner
 : @author David Glück
 : @author Ingo Caesar
 : @version 1.0
 :
 :)

module namespace html               = "http://salamanca.school/ns/html";

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace sal               = "http://salamanca.school/ns/sal";
declare namespace session           = "http://exist-db.org/xquery/session";
declare namespace tei               = "http://www.tei-c.org/ns/1.0";
declare namespace transform         = "http://exist-db.org/xquery/transform";
declare namespace util              = "http://exist-db.org/xquery/util";
declare namespace xhtml             = "http://www.w3.org/1999/xhtml";
declare namespace xi                = "http://www.w3.org/2001/XInclude";
declare namespace xmldb             = "http://exist-db.org/xquery/xmldb";
import module namespace functx      = "http://www.functx.com";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace templates   = "http://exist-db.org/xquery/templates";
import module namespace config      = "http://salamanca.school/ns/config"               at "config.xqm";
import module namespace render      = "http://salamanca.school/ns/render"               at "render.xql";
import module namespace i18n        = "http://exist-db.org/xquery/i18n"                 at "i18n.xql";
import module namespace stool       = "http://salamanca.school/ns/stool"                at "stool.xql";


(: === Page Header Elements === :)

declare
    %templates:default("language", "en") 
function html:meta-title($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $q as xs:string?) as element() {  
    let $output := 
                    if (ends-with(request:get-uri(), "/author.html")) then
                        <title>
                            {html:formatName($model("currentAuthor")//tei:person//tei:persName)} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/authors.html")) then
                        <title><i18n:text key="authors">Autoren</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if ($wid) then
                        <title>
                            {string-join(doc($html:tei-works-root || "/" || $wid || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') || ': ' ||
                             doc($html:tei-works-root || "/" || $wid || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string()} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    (:                else if (request:get-parameter('wid', '')) then
                        <title>
                            {replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($html:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname/string())||': '||
                             replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($html:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string())} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    :)
                    else if (ends-with(request:get-uri(), "/workDetails.html")) then
                        <title>
                            {string-join($model("currentWork")//tei:sourceDesc//tei:author/tei:persName/tei:surname, '/') || ", " ||
                             $model("currentWork")//tei:sourceDesc//tei:title[@type = 'short']/string()} (<i18n:text key='detailsHeader'>Details</i18n:text>) -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/works.html")) then
                        <title><i18n:text key="works">Werke</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if (ends-with(request:get-uri(), "/lemma.html")) then
                        <title>
                            {$model("currentLemma")//tei:titleStmt//tei:title[@type = 'short']/string()} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/dictionary.html")) then
                        <title><i18n:text key="dictionary">Wörterbuch</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if (ends-with(request:get-uri(), "/newsEntry.html")) then
                        <title>
                            {        if ($lang eq 'de') then $model('currentNews')//tei:title[@type='main'][@xml:lang='de']/string()
                                else if ($lang eq 'en') then $model('currentNews')//tei:title[@type='main'][@xml:lang='en']/string()
                                else if ($lang eq 'es') then $model('currentNews')//tei:title[@type='main'][@xml:lang='es']/string()
                                else()} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text>
                        </title>
                    else if (ends-with(request:get-uri(), "/news.html")) then
                        <title><i18n:text key="news">Aktuelles</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if (ends-with(request:get-uri(), "/workingPaper.html")) then
                        <title>Working Paper:
                            {
                             $model("currentWp")//tei:titleStmt/tei:title[@type = 'short']/string()} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/project.html")) then
                        <title><i18n:text key="project">Projekt</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                   else if (ends-with(request:get-uri(), "/workingPapers.html")) then
                        <title><i18n:text key="workingPapers">Working Papers</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/editorialWorkingPapers.html")) then
                        <title><i18n:text key="WpAbout">Über die WP Reihe</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/search.html")) then
                        <title>{if ($q) then $q else <i18n:text key="search">Suche</i18n:text>} - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if (ends-with(request:get-uri(), "/guidelines.html")) then
                        <title><i18n:text key="guidelines">Editionsrichtlinien</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if (ends-with(request:get-uri(), "/admin.html")) then
                        <title><i18n:text key="administration">Administration</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/render.html")) then
                        <title><i18n:text key="rendering">Rendering</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/stats.html")) then
                        <title><i18n:text key="stats">Statistiken</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/index.html")) then
                        <title><i18n:text key="start">Home</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/contact.html")) then
                        <title><i18n:text key="contact">Kontakt</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/")) then
                        <title><i18n:text key="start">Home</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title> else
                        <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
};

declare
    %templates:default("lang", "en") 
function html:canonical-url-link($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element() {
        let $url :=  
                     if (request:get-attribute('$exist:resource') = ("authors.html",
                                                                     "works.html",
                                                                     "dictionary.html",
                                                                     "index.html",
                                                                     "project.html",
                                                                     "contact.html",
                                                                     "guidelines.html",
                                                                     "editorialWorkingPapers.html",
                                                                     "projektbeteiligte.html",
                                                                     "workingPapers.html",
                                                                     "search.html"
                                                                    )) then
                            concat($html:webserver, '/', $lang, '/', request:get-attribute('$exist:resource'))
                     else if (ends-with(request:get-uri(), "/author.html")) then
                            concat($html:webserver, '/', $lang, '/author.html?',       string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/work.html")) then
                            concat($html:webserver, '/', $lang, '/work.html?',         string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/lemma.html")) then
                            concat($html:webserver, '/', $lang, '/lemma.html?',        string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/workingPaper.html")) then
                            concat($html:webserver, '/', $lang, '/workingPaper.html?', string-join(net:inject-requestParameter('',''), '&amp;'))
                     else
                            $html:webserver
        return
            <link rel="canonical" href="{$url}"/>
};

declare
function html:first-link($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return if (not (xmldb:collection-available($html:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := substring(functx:sort(xmldb:get-child-resources($html:html-root || "/" || $workId))[1], 1, string-length(functx:sort(xmldb:get-child-resources($html:html-root || "/" || $workId))[1]) - 5)
                let $url := "work.html?wid=" || $workId || "&amp;frag=" || $targetFragment
                let $debug := if ($html:debug = "trace") then console:log("Firstlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="first" href="{$url}"/>
                        else ()
};

declare
function html:prev-link($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return  if (not (xmldb:collection-available($html:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := if ($frag and $frag || ".html" = xmldb:get-child-resources($html:html-root || "/" || $workId)) then
                                            $frag || ".html"
                                        else
                                            functx:sort(xmldb:get-child-resources($html:html-root || "/" || $workId))[1]
                let $url := doc($html:html-root || '/' || $wid || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="previous"]/@href/string()
                let $debug := if ($html:debug = "trace") then console:log("Prevlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="prev" href="{$url}"/>
                        else ()
};

declare
function html:next-link($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return  if (not (xmldb:collection-available($html:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := if ($frag and $frag || ".html" = xmldb:get-child-resources($html:html-root || "/" || $workId)) then
                                            $frag || ".html"
                                        else
                                            functx:sort(xmldb:get-child-resources($html:html-root || "/" || $workId))[1]
                let $url := doc($html:html-root || '/' || $wid || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="next"]/@href/string()
                let $debug := if ($html:debug = "trace") then console:log("Nextlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="next" href="{$url}"/>
                        else ()
};


(: === Page Body Elements === :)

declare
function html:carousel ($node as node(), $model as map(*)){
    <div id="carousel" class="carousel slide" data-ride="carousel">
        <!-- Indicators -->
        <ol class="carousel-indicators">
            <li data-target="#carousel-example-generic" data-slide-to="0" class="active"/>
            <li data-target="#carousel-example-generic" data-slide-to="1"/>
            <li data-target="#carousel-example-generic" data-slide-to="2"/>
            <li data-target="#carousel-example-generic" data-slide-to="3"/>
            <li data-target="#carousel-example-generic" data-slide-to="4"/>
            <li data-target="#carousel-example-generic" data-slide-to="5"/>
            <li data-target="#carousel-example-generic" data-slide-to="6"/>
        </ol>
        <!-- Wrapper for slides -->
        <div class="carousel-inner">
            <div class="item active">
                <img src="resources/img/slider/slide01a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide02a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide03a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide04a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide05a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide06a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
            <div class="item">
                <img src="resources/img/slider/slide07a.jpg" class="img-responsive" alt="Responsive image"/>
            </div>
        </div>
        <!-- Controls -->
        <a class="left carousel-control" href="#carousel" data-slide="prev">
            <span class="glyphicon glyphicon-chevron-left"/>
        </a>
        <a class="carousel-control right" href="#carousel" data-slide="next">
            <span class="glyphicon glyphicon-chevron-right"/>
        </a>
    </div>
};

(:Title of APP "Die Schule von Salamanca":)
declare
function html:logo($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <div class="navbar-header">
            <button type="button" class="navbar-toggle pull-left" data-toggle="collapse"  data-target=".navbar-menubuilder">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
             <a class="navbar-brand hidden-xs" href="index.html">
                <i18n:text key="home">Die Schule von Salamanca</i18n:text>
             </a>
             <a class="navbar-brand hidden-lg hidden-md hidden-sm smallNav" href="index.html">
                <i18n:text key="home">Die Schule von Salamanca</i18n:text>
            </a>   
        </div>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};  

(: Navigation: create header menu and dropdown:)
declare
function html:app-header($node as node(), $model as map(*), $lang as xs:string, $aid as xs:string?, $lid as xs:string?, $nid as xs:string?, $wpid as xs:string?, $wid as xs:string?) as element()  {
    let $output :=
        <div class="collapse navbar-collapse navbar-menubuilder">
            <menu class="nav navbar-nav">
                <!--{(:
                if(contains(request:get-url(), 'news')) then <li class="active"><a href="news.html?lang={$lang}"><span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text></a></li>
                else <li><a href="news.html?lang={$lang}"><span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text></a></li>
                :)} -->
                <li class="{if (contains(request:get-url(), 'news')) then 'active' else ()}">
                    <a href="{$html:blogserver}/?lang={$lang}">
                    <span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;
                    <i18n:text key="news">Aktuelles</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'project')) or
                                 (contains(request:get-url(), 'guide')) or
                                 (contains(request:get-url(), 'editorial')) or
                                 (contains(request:get-url(), 'contact')) or
                                 (contains(request:get-url(), 'about'))         ) then 'active' else ()}">
                    <a href="project.html">
                    <i class="fa fa-university" aria-hidden="true"></i>&#160;
                    <i18n:text key="project">Projekt</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'work.')) or
                                 (contains(request:get-url(), 'works.')) or
                                 (contains(request:get-url(), 'workDetails.'))  ) then 'active' else ()}">
                    <a href="works.html">
                    <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;
                    <i18n:text key="works">Werke</i18n:text></a></li> 
                 
                    <li class="{if ( (contains(request:get-url(), 'dictionary')) or
                                 (contains(request:get-url(), 'lemma.'))        ) then 'active' else ()}">
                    <a href="dictionary.html">
                    <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;
                    <i18n:text key="dictionary">Wörterbuch</i18n:text></a></li> 
                <li class="{if ( (contains(request:get-url(), 'author.')) or
                                 (contains(request:get-url(), 'authors.'))      ) then 'active' else ()}">
                    <a href="authors.html">
                    <span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;
                    <i18n:text key="authors">Autoren</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'workingPaper.')) or
                                 (contains(request:get-url(), 'workingPapers.'))) then 'active' else ()}">
                    <a href="workingPapers.html">
                    <i class="fa fa-pencil" aria-hidden="true"></i>&#160;
                    <i18n:text key="workingPapers">Working Papers</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'search.'))       ) then 'active' else ()}">
                    <a href="search.html">
                    <span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;
                    <i18n:text key="search">Suche</i18n:text></a></li>
                <!-- language-switch dropdown on not-so-large screens -->
                <li role="presentation" class="dropdown hidden-lg">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                        <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;<i18n:text key="language">Sprache</i18n:text> <span class="caret"></span>
                    </a>
                    <menu class="dropdown-menu">
                        <li class="hidden-lg"><a href="{$html:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="de">Deutsch</i18n:text></a></li>                                               
                        <li class="hidden-lg"><a href="{$html:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="en">Englisch</i18n:text></a></li>
                        <li class="hidden-lg"><a href="{$html:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="es">Spanisch</i18n:text></a></li>
                    </menu>
                </li> 
            </menu>
            <!-- language-switch buttons on large screens -->
            <menu class="nav navbar-nav">
                <li class="nav navbar-nav navbar-right hidden-xs hidden-sm hidden-md">
                   <div class="btn-group" role="group" aria-label="...">
                     <a  class="btn navbar-btn {if ($lang='de') then 'btn-info' else 'btn-default'}" href="{$html:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>
                     <a  class="btn navbar-btn {if ($lang='en') then 'btn-info' else 'btn-default'}" href="{$html:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>
                     <a  class="btn navbar-btn {if ($lang='es') then 'btn-info' else 'btn-default'}" href="{$html:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>
                    </div> 
                </li>
            </menu>
        </div>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) 
};

(: Navigation create Mobile-header menue and dropdown in work.html:)
declare
function html:app-headerWork($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*) as element() {
    let $output :=
    <div class="collapse navbar-collapse navbar-menubuilder">
        <div class="row">
            <menu class="nav navbar-nav">
                <!-- For tablet/mobile view: hidden on displays smaller than 1024px -->
                <li class="hidden-lg"><a href="{$html:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="de">Deutsch</i18n:text></a></li>                                               
                <li class="hidden-lg"><a href="{$html:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="en">Englisch</i18n:text></a></li>
                <li class="hidden-lg"><a href="{$html:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="es">Spanisch</i18n:text></a></li>
                <li><a href="works.html"><span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;<i18n:text key="works">Werke</i18n:text></a></li>
                <li><a href="dictionary.html"><span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;<i18n:text key="dictionary">Wörterbuch</i18n:text></a></li>
                <li><a href="authors.html"><span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;<i18n:text key="authors">Autoren</i18n:text></a></li>
                <li><a href="search.html"><span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;<i18n:text key="search">Suche</i18n:text></a></li>
                <li><a href="workingPapers.html"><span class="glyphicon glyphicon-pushpin" aria-hidden="true"></span>&#160;<i18n:text key="workingPapers">Working Papers</i18n:text></a></li>
                <li><a href="news.html"><span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text></a></li>
                <li class="hidden-lg"><a href="project.html"><i18n:text key="about">Projektbeschreibung</i18n:text></a></li>
                <li class="hidden-lg"><a href="contact.html"><i18n:text key="contact">Kontakt</i18n:text></a></li>
                <li class="hidden-lg"><a href="guidelines.html"><i18n:text key="guidelines">Editionsrichtlinien</i18n:text></a></li>
                <li class="hidden-lg"><a href="editorialWorkingPapers.html"><i18n:text key="editorialWpHead">Editorial Working Papers</i18n:text></a></li>
                <li class="hidden-lg"><a href="guidelines.html"><i18n:text key="guidelines">Editionsrichtlinien</i18n:text></a></li>
                <li class="hidden-lg"><a href="editorialWorkingPapers.html"><i18n:text key="editorialWpHead">Editorial Working Papers</i18n:text></a></li>
            </menu>
            <menu class="nav navbar-nav navbar-right hidden-xs hidden-sm  hidden-md">
                <div class="btn-group" role="group" aria-label="...">
                 {if ($lang = 'de') then 
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$html:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$html:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>}
                  {if ($lang = 'en') then 
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$html:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$html:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>}
                  {if ($lang = 'es') then 
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$html:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$html:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>}
                </div> 
            </menu>
        </div>
    </div>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) 
};

(:create main links on landing page:)
declare
    %templates:wrap
function html:langWorks($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output :=
        <a  href="works.html">
            <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;<i18n:text key="works">Werke</i18n:text>
        </a>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langDictionary($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="dictionary.html">
            <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;<i18n:text key="dictionary">Wörterbuch</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langAuthors($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="authors.html">
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;<i18n:text key="authors">Autoren</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langSearch($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="search.html">
            <span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;<i18n:text key="search">Suche</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langWorkingPapers($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="workingPapers.html">
            <i class="fa fa-pencil" aria-hidden="true"></i>&#160;<i18n:text key="workingPapers">Working Papers</i18n:text>
        </a>
    return i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langNews($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="news.html">
            <span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langPrDesc($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="project.html">
           <i class="fa fa-university" aria-hidden="true"></i>&#160;<i18n:text key="about">Projekt</i18n:text>
        </a>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langProjektteam($node as node(), $model as map(*), $lang as xs:string) as element() {
        if ($lang = 'en') then
            <a target="blank" href="http://www.salamanca.adwmainz.de/en/project-team-and-consultants.html">
               <i class="fa fa-group" aria-hidden="true"></i>&#160;Project Team
            </a>
        else if ($lang = 'es') then
            <a target="blank" href="http://www.salamanca.adwmainz.de/es/el-equipo-de-proyecto-y-sus-consultores.html">
               <i class="fa fa-group" aria-hidden="true"></i>&#160;Equipo del Proyecto
            </a>
        else
            <a target="blank" href="http://www.salamanca.adwmainz.de/projektbeteiligte.html">
               <i class="fa fa-group" aria-hidden="true"></i>&#160;Projektteam
            </a>
};

declare
    %templates:wrap
function html:langEdGuidelines($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="guidelines.html">
           <i class="fa fa-cogs" aria-hidden="true"></i>&#160;<i18n:text key="guidelines">Editionsrichtlinien</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langWPcreation($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="editorialWorkingPapers.html">
           <span class="glyphicon glyphicon-edit" aria-hidden="true"></span>&#160;<i18n:text key="getInvolved">Beitragen</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langLegal($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="legal.html">
           <span class="fa fa-lock" aria-hidden="true"></span>&#160;<i18n:text key="legal">Datenschutz &amp; Impressum</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langContact($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="contact.html">
            <i class="fa fa-envelope-o" aria-hidden="true"></i>&#160;<i18n:text key="contact">Kontakt</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:langSourceCode($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output :=
            <a target="blank" href="https://github.com/digicademy/svsal">
               <i class="glyphicon glyphicon-console" aria-hidden="true"></i>&#160;<i18n:text key="sourceCode">Quellcode</i18n:text>
            </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
    %templates:wrap
function html:searchInfoDetails($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="searchDetails.html">
           <i18n:text key="moreSearchDetails">Weitere Suchmöglichkeiten</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};


(: === Page Footer Elements === :)

(:~
 : produce page footer with institutions, licence badge etc.
 : 
 :  @param $node     the list of persName elements to re-format
 :  @param $model   the state of the application
 :  @param $lang      the current language of the UI  
 :  @return a html span
~:)
declare
function html:footer ($node as node(), $model as map(*), $lang as xs:string) {
    (: The following is disabled for security reasons:
        Vers. {doc('/db/apps/salamanca/expath-pkg.xml')/pack:package/@version/string()}
    :)
    let $username := sm:id()//sm:username
    let $footer :=
    <span>
        <div class="row">
        <!-- the Academy -->
            <div class="col-md-3 hidden-sm hidden-xs">
                <a href="http://www.adwmainz.de/"><img class="img-responsive" style="margin-top: 10%" src="resources/img/logos_misc/logo_akademie.png"/></a>
            </div>
            <div class="hidden-lg hidden-md col-sm-4" style="text-align: center; margin-top: 1%">
                <a href="http://www.adwmainz.de/"><p><span class="glyphicon glyphicon-new-window" aria-hidden="true"></span> Akademie der Wissenschaften und der <br/>Literatur | Mainz</p></a>
            </div>
        <!-- the University -->   
            <div class="col-md-3 hidden-sm hidden-xs" >
                <a href="http://www2.uni-frankfurt.de"><img style="margin-top: 3%" class="img-responsive" src="resources/img/logos_misc/goethe-uni-logo.gif"/></a>
             </div>
            <div class="hidden-lg hidden-md col-sm-4" style="text-align: center; margin-top: 1%">
                <a href="http://www2.uni-frankfurt.de"><p><span class="glyphicon glyphicon-new-window" aria-hidden="true"></span> Goethe-Universität<br/>Frankfurt<br/>Institut für Philosphie</p></a>
            </div>
        <!-- the Institute -->    
            <div class="col-md-3 hidden-sm hidden-xs">
                <a href="http://www.rg.mpg.de"><img style="margin-top: 9%; float: right; height: 100%;" class="img-responsive" src="resources/img/logos_misc/mpier.svg"/></a>
            </div>
            <div class="hidden-lg hidden-md col-sm-4" style="text-align: center;margin-top: 1%">
                <a href="http://www.rg.mpg.de"><p><span class="glyphicon glyphicon-new-window" aria-hidden="true"></span> Max-Planck-Institut<br/>für<br/>europäische Rechtsgeschichte</p></a>
            </div>
        <!-- powered by eXist -->        
             <div class="col-md-3 hidden-sm hidden-xs">
             <a style="margin-top: 7%" id="poweredby" href="http://exist-db.org"></a>
             </div>
        </div>
        <br/>
        <!-- contact, information, privacy, version -->
        <div class="row">
            <div class="col-md-12 hidden-sm hidden-xs" style="text-align: center;">
            <br/>
                <p style="font-size:1.2em">
                <a href="contact.html"><i class="fa fa-envelope-o"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a> 
                | <a  href="legal.html"><i class="fa fa-lock"></i>&#32;&#32;<i18n:text key='legal'>Datenschutz &amp; Impressum</i18n:text></a> 
                </p>
                    <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="fa fa-copyright"></i>&#32;&#32;<span title="{$username}"><i18n:text key="projectName"></i18n:text> 2015-2018</span>
                </p>
            </div>
        </div>
        <div class="col-sm-12 hidden-lg hidden-md" style="text-align: center">
            <p>
            <a href="contact.html"><i class="fa fa-envelope-o"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a>
                | <a  href="legal.html"><i class="fa fa-lock"></i>&#32;&#32;<i18n:text key='legal'>Datenschutz &amp; Impressum</i18n:text></a>            </p>
                <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="fa fa-copyright"></i>&#32;&#32;<span title="{$username}"><i18n:text key="projectName"></i18n:text> 2015-2018</span>
            </p>
        </div>
        <!-- CC BY -->        
        <div class="row">   
            <div class="col-md-12" style="text-align: center">
           <!--<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />-->
           <i18n:text key="licenceDesc"/>{$html:nbsp}<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><i18n:text key="licenceCC40">Creative Commons Namensnennung 4.0 International Lizenz</i18n:text><span class="glyphicon glyphicon-new-window" style="padding-left:0.3em;"></span></a>.
           </div>
       </div>
    </span>
     return i18n:process($footer, $lang, "/db/apps/salamanca/data/i18n", "de")
};

(: === Other === :)

declare
function html:contactEMailHTML($node as node(), $model as map(*)) {
    <a href="mailto:{$config:contactEMail}">{$config:contactEMail}</a>
};

declare
    %templates:wrap
function html:AUTlist($node as node(), $model as map(*), $lang as xs:string) {
        <div class="col-md-6"> 
            <div class="panel panel-default">
                <div class="panel-body">
                    {html:AUTnameLink($node, $model, $lang), $config:nbsp}<a href="{session:encode-url(xs:anyURI('author.html?aid=' || $model('currentAuthor')/@xml:id/string()))}" title="get information about this author"></a><br/>
                    {html:AUTfromTo($node, $model)}<br/>
                    {html:AUTorder($node, $model, $lang)}<br/>
                    <br/>
                </div>
            </div>
        </div>
};

declare
    %private
function html:AUTnameLink($node as node(), $model as map(*), $lang as xs:string) {
    let $nameLink := 
        <a class="lead" href="{session:encode-url(xs:anyURI('author.html?aid=' || $model('currentAuthor')/@xml:id))}">
            <span class="glyphicon glyphicon-user"></span>
            &#xA0;{app:formatName($model('currentAuthor')/tei:persName[1])}
        </a>
    return $nameLink
};

declare
    %private
function html:AUTfromTo ($node as node(), $model as map(*)) {
    let $birth  :=  replace(xs:string(number(substring-before($model('currentAuthor')/tei:birth/tei:date[1]/@when, '-'))), 'NaN', '??')
    let $death  :=  replace(xs:string(number(substring-before($model('currentAuthor')/tei:death/tei:date[1]/@when, '-'))), 'NaN', '??')
    return 
        <span>{$birth||' - '||$death}</span>
};

declare
    %private
function html:AUTorder ($node as node(), $model as map(*), $lang) {
    let $relOrder  :=  $model('currentAuthor')//tei:affiliation/tei:orgName[1]/@key/string()
    return <span>{i18n:process(<i18n:text key="{$relOrder}">{$relOrder}</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en")}</span>
};

declare
    %private
function html:AUTdiscipline ($node as node(), $model as map(*), $lang as xs:string) {
    let $relOrder  :=  $model('currentAuthor')//tei:affiliation/tei:orgName[1]/@key/string()
};

declare
    %templates:wrap
function app:LEMlist($node as node(), $model as map(*), $lang as xs:string?) {
       <div class="col-md-6"> 
            <div class="panel panel-default">
                <div class="panel-body">
                   {html:LEMtitleShortLink($node, $model, $lang)}<br/>  
                   {html:LEMauthor($node, $model)}<br/>
               </div>
            </div>
        </div>
};

declare
    %private
function html:LEMtitleShortLink($node as node(), $model as map(*), $lang) {
    <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $model('currentLemma')/@xml:id))}">
            <span class="lead">
            <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#xA0;{$model('currentLemma')/tei:teiHeader//tei:titleStmt/tei:title[@type = 'short'] || $config:nbsp}
        </span>
    </a>   
};

declare
    %templates:wrap
function html:LEMauthor($node as node(), $model as map(*)) {
    let $names := for $author in $model('currentLemma')/tei:teiHeader//tei:author
                    return stool:rotateFormatName($author/tei:persName)
    return string-join($names, ', ')
};


declare
    %templates:wrap 
function html:WRKauthor($node as node(), $model as map(*)) {
    <span>{stool:formatName($model('currentWork')//tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)}</span>
};


(: --- Todo: Are these really needed? --- :)
declare
function html:switchYear ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="year">Jahr</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
function html:switchPrintingPlace ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="printingPlace">Druckort</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
function html:switchLanguage ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="lang">Sprache</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
function html:switchAuthor($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="author">Autor</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
function html:switchTitle($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="title">Titel</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare
function html:switchName ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="lemmata">Lemma</i18n:text>
    return 
        i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

(: --- /Todo: Are these really needed? --- :)
