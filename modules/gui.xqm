xquery version "3.1";


(: ####++++----

    Functions providing generic HTML components/functionality.

 ----++++#### :)


module namespace gui         = "http://www.salamanca.school/xquery/gui";
declare       namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace session       = "http://exist-db.org/xquery/session";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";
declare namespace templates     = "http://exist-db.org/xquery/templates";
declare namespace util          = "http://exist-db.org/xquery/util";
import module namespace xmldb       = "http://exist-db.org/xquery/xmldb";

declare namespace xhtml         = "http://www.w3.org/1999/xhtml";
declare namespace pack          = "http://expath.org/ns/pkg";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";
import module namespace i18n    = "http://exist-db.org/xquery/i18n"     at "i18n.xqm";
import module namespace sutil   = "http://www.salamanca.school/xquery/sutil" at "sutil.xqm";
import module namespace config  = "http://www.salamanca.school/xquery/config" at "config.xqm";
import module namespace net     = "http://www.salamanca.school/xquery/net" at "net.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace functx  = "http://www.functx.com";



(:i18n ============================================:)
(:language switching Startseite: für Seitentitel im Tabulator, Titel "Die Schule von Salamanca", das Menü und alle Bottons der Startseite:)

(:declare %templates:wrap function config:tabTitle($node as node(), $model as map(*)) as text() {
    let $output := <i18n:text key="tab">Die Schule von Salamanca</i18n:text>
    return 
        i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  :)

declare function gui:carousel($node as node(), $model as map(*)){
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
declare function gui:logo($node as node(), $model as map(*), $lang as xs:string) as element() {
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


(: 
    NOTE: many of the functions below can also be found in eXist's config module
    (http://exist-db.org/xquery/apps/config), but are "overwritten" here.
    Since most of these functions are really HTML-heavy and don't seem to have much to do with 
    the app context itself, perhaps it would be wise to outsource them into a dedicated module, 
    but I'm not sure if this would break something with eXist's default config/templating system. 
:)


(: Navigation:  create header menue and dropdown:)
declare function gui:header($node as node(), $model as map(*), $lang as xs:string, $aid as xs:string?, $lid as xs:string?, $nid as xs:string?, $wpid as xs:string?, $wid as xs:string?) as element()  {
    let $output :=
        <div class="collapse navbar-collapse navbar-menubuilder">
            <menu class="nav navbar-nav">
                <li class="{if (contains(request:get-url(), 'news')) then 'active' else ()}">
                    <a href="{$config:blogserver}/?lang={$lang}">
                    <span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;
                    <i18n:text key="news">Aktuelles</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'project')) or
                                 (contains(request:get-url(), 'guide')) or
                                 (contains(request:get-url(), 'editorial')) or
                                 (contains(request:get-url(), 'contact')) or
                                 (contains(request:get-url(), 'about'))         ) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/project.html'}">
                    <i class="fa fa-university" aria-hidden="true"></i>&#160;
                    <i18n:text key="project">Projekt</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'work.')) or
                                 (contains(request:get-url(), 'works.')) or
                                 (contains(request:get-url(), 'workDetails.'))  ) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/works.html'}">
                    <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;
                    <i18n:text key="works">Werke</i18n:text></a></li> 
                 
                    <li class="{if ( (contains(request:get-url(), 'dictionary')) or
                                 (contains(request:get-url(), 'lemma.'))        ) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/dictionary.html'}">
                    <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;
                    <i18n:text key="dictionary">Wörterbuch</i18n:text></a></li> 
                <li class="{if ( (contains(request:get-url(), 'author.')) or
                                 (contains(request:get-url(), 'authors.'))      ) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/authors.html'}">
                    <span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;
                    <i18n:text key="authors">Autoren</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'workingPaper.')) or
                                 (contains(request:get-url(), 'workingPapers.'))) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/workingPapers.html'}">
                    <i class="fas fa-pencil-alt" aria-hidden="true"></i>&#160;
                    <i18n:text key="workingPapers">Working Papers</i18n:text></a></li>
                <li class="{if ( (contains(request:get-url(), 'search.'))       ) then 'active' else ()}">
                    <a href="{$config:webserver || '/' || $lang || '/search.html'}">
                    <span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;
                    <i18n:text key="search">Suche</i18n:text></a></li>
                <!-- language-switch dropdown on not-so-large screens -->
                <li role="presentation" class="dropdown hidden-lg">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                        <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;<i18n:text key="language">Sprache</i18n:text> <span class="caret"></span>
                    </a>
                    <menu class="dropdown-menu">
                        <li class="hidden-lg"><a href="{$config:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="de">Deutsch</i18n:text></a></li>                                               
                        <li class="hidden-lg"><a href="{$config:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="en">Englisch</i18n:text></a></li>
                        <li class="hidden-lg"><a href="{$config:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">
                            <span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#160;
                            <i18n:text key="es">Spanisch</i18n:text></a></li>
                    </menu>
                </li> 
            </menu>
            <!-- language-switch buttons on large screens -->
            <menu class="nav navbar-nav">
                <li class="nav navbar-nav navbar-right hidden-xs hidden-sm hidden-md">
                   <div class="btn-group" role="group" aria-label="...">
                     <a  class="btn navbar-btn {if ($lang='de') then 'btn-info' else 'btn-default'}" href="{$config:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>
                     <a  class="btn navbar-btn {if ($lang='en') then 'btn-info' else 'btn-default'}" href="{$config:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>
                     <a  class="btn navbar-btn {if ($lang='es') then 'btn-info' else 'btn-default'}" href="{$config:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>
                    </div> 
                </li>
            </menu>
        </div>
     return
           i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) 
};

(:create main links on landing page:)
declare %templates:wrap
    function gui:langWorks($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="works.html">
            <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;<i18n:text key="works">Werke</i18n:text>
        </a>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function gui:langDictionary($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="dictionary.html">
            <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;<i18n:text key="dictionary">Wörterbuch</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function gui:langAuthors($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="authors.html">
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;<i18n:text key="authors">Autoren</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function gui:langSearch($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="search.html">
            <span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;<i18n:text key="search">Suche</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  
        
declare %templates:wrap
    function gui:langWorkingPapers($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="workingPapers.html">
            <i class="fas fa-pencil-alt" aria-hidden="true"></i>&#160;<i18n:text key="workingPapers">Working Papers</i18n:text>
        </a>
    return i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  
 
declare %templates:wrap
    function gui:langPrDesc($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="project.html">
           <i class="fa fa-university" aria-hidden="true"></i>&#160;<i18n:text key="about">Projekt</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};
        
declare %templates:wrap
    function gui:langProjectTeam($node as node(), $model as map(*), $lang as xs:string) as element()  {
        let $output :=
            <a href="participants.html">
               <i class="fa fa-users" aria-hidden="true"></i>&#160;<i18n:text key="participantsTitle">Project Participants</i18n:text>
            </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))        
};

declare %templates:wrap
    function gui:langEdGuidelines($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="guidelines.html">
           <i class="fa fa-cogs" aria-hidden="true"></i>&#160;<i18n:text key="guidelines">Editionsrichtlinien</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};


declare %templates:wrap
    function gui:langWPcreation($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="editorialWorkingPapers.html">
           <span class="glyphicon glyphicon-edit" aria-hidden="true"></span>&#160;<i18n:text key="getInvolved">Beitragen</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};
        
declare %templates:wrap
    function gui:langLegal($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="legal.html">
           <span class="fa fa-balance-scale" aria-hidden="true"></span>&#160;<i18n:text key="legal">Datenschutz &amp; Impressum</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};
        
declare %templates:wrap
    function gui:langContact($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="contact.html">
            <i class="far fa-envelope" aria-hidden="true"></i>&#160;<i18n:text key="contact">Kontakt</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};       

declare %templates:wrap
    function gui:langSourceCode($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output :=
            <a target="blank" href="https://github.com/digicademy/svsal">
               <i class="glyphicon glyphicon-console" aria-hidden="true"></i>&#160;<i18n:text key="sourceCode">Quellcode</i18n:text>
            </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

declare %templates:wrap
    function gui:langSources($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output :=
            <a target="blank" href="sources.html">
               <i class="fas fa-th-list" aria-hidden="true"></i>&#160;<i18n:text key="worksListOverview">List of Sources in the Digital Collection</i18n:text>
            </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};

 
declare %templates:default("language", "en") 
    function gui:metaTitle($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $q as xs:string?, $id as xs:string?) as element() {  
    let $reqResource := '/' || tokenize(request:get-uri(), '/')[last()]
    let $output := 
        switch($reqResource)
            case '/author.html' return
                <title>{sutil:formatName($model("currentAuthor")//tei:person//tei:persName)} - <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
            case '/authors.html' return
                <title><i18n:text key="authors">Autoren</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/work.html'
            case '/workDetails.html' return
                <title>
                    {string-join(doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') || ': ' ||
                     doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")//tei:sourceDesc//tei:monogr/tei:title[@type = 'short']/string()} -
                     <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    (:                    else if (request:get-parameter('wid', '')) then
                <title>
                    {replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($config:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname/string())||': '||
                     replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($config:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string())} -
                     <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    :)
            (:case '/workDetails.html' return
                <title>
                    {string-join($model("currentWorkHeader")//tei:sourceDesc//tei:author/tei:persName/tei:surname, '/') || ", " ||
                     $model("currentWorkHeader")//tei:sourceDesc//tei:monogr/tei:title[@type = 'short']/string()} (<i18n:text key='detailsHeader'>Details</i18n:text>) -
                     <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>:)
            case '/works.html' return
                <title><i18n:text key="works">Werke</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/lemma.html' return
                <title>{$model("currentLemma")//tei:titleStmt//tei:title[@type = 'short']/string()} - <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
            case '/dictionary.html' return
                <title><i18n:text key="dictionary">Wörterbuch</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/workingPaper.html' return
                <title>Working Paper: {$model("currentWp")//tei:titleStmt/tei:title[@type = 'short']/string()} - <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
            case '/project.html' return
                <title><i18n:text key="project">Projekt</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/workingPapers.html' return
                <title><i18n:text key="workingPapers">Working Papers</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/editorialWorkingPapers.html' return
                <title><i18n:text key="WpAbout">Über die WP Reihe</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/search.html' return
                <title>{if ($q) then $q else <i18n:text key="search">Suche</i18n:text>} - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/guidelines.html' return
                <title><i18n:text key="guidelines">Editionsrichtlinien</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/admin.html' return
                <title><i18n:text key="administration">Administration</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/render.html' return
                <title><i18n:text key="rendering">Rendering</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/stats.html' return
                <title><i18n:text key="stats">Statistiken</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/index.html' return
                <title><i18n:text key="start">Home</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/contact.html' return
                <title><i18n:text key="contact">Kontakt</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case '/participants.html' return
                <title>{gui:participantsTitle($node, $model, $lang, $id)} - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
            case "/" return
                <title><i18n:text key="start">Home</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title> 
            default return
                <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
        let $debug := if ($config:debug = "trace") then console:log("Meta title: " || $output) else ()
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
};   

declare %templates:wrap function gui:participantsTitle($node as node(), $model as map(*), $lang as xs:string?, $id as xs:string?) {
    let $id := if ($id) then lower-case($id) else if (request:get-parameter('id', '')) then lower-case(request:get-parameter('id', '')) else ()
    let $teiPath := $config:tei-meta-root || '/projectteam.xml'
    let $title :=
        switch($id)
            case 'directors' return
                <i18n:text key="projectDirectors">Directors</i18n:text>
            case 'team' return
                <i18n:text key="projectTeam">Team</i18n:text>
            case 'advisoryboard' return
                <i18n:text key="projectAdvBoard">Scientific Advisory Board</i18n:text>
            case 'cooperators' return
                <i18n:text key="projectCooperators">Project Cooperators</i18n:text>
            case 'former' return
                <i18n:text key="projectFormer">Former Team Members</i18n:text>
            default return 
                if (doc-available($teiPath) and doc($teiPath)//tei:person[@xml:id eq upper-case($id)]) then
                    let $name := doc($teiPath)//tei:person[@xml:id eq upper-case($id)]/tei:persName/tei:name
                    return string($name)
                else 
                    <i18n:text key="projectTeamConsultants">Project Team and Consultants</i18n:text>
    return 
        if ($title instance of element(i18n:text)) then i18n:process($title, $lang, $config:i18n-root, 'en')
        else $title
};

declare %templates:default("lang", "en") 
    function gui:canonicalUrl($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element() {
        let $url :=  
             if (request:get-attribute('$exist:resource') = 
                ("authors.html",
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
                    concat($config:webserver, '/', $lang, '/', request:get-attribute('$exist:resource'))
             else
                let $reqResource := '/' || tokenize(request:get-uri(), '/')[last()]
                return
                    switch($reqResource)
                        case '/author.html' return
                           concat($config:webserver, '/', $lang, '/author.html?',       string-join(net:inject-requestParameter('',''), '&amp;'))
                        case '/work.html' return
                           concat($config:webserver, '/', $lang, '/work.html?',         string-join(net:inject-requestParameter('',''), '&amp;'))
                        case '/lemma.html' return
                           concat($config:webserver, '/', $lang, '/lemma.html?',        string-join(net:inject-requestParameter('',''), '&amp;'))
                        case '/workingPaper.html' return
                           concat($config:webserver, '/', $lang, '/workingPaper.html?', string-join(net:inject-requestParameter('',''), '&amp;'))
                        case '/participants.html' return
                           concat($config:webserver, '/', $lang, '/participants.html?',        string-join(net:inject-requestParameter('',''), '&amp;'))
                        default return
                               $config:webserver
        return
            <link rel="canonical" href="{$url}"/>
};



declare %templates:default("lang", "en") 
    function gui:hreflangUrl($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element()* {
        for $language in ('de', 'en', 'es')
            let $url := 
                concat(
                    $config:webserver, '/', $language, '/', request:get-attribute('$exist:resource'),
                    if (count(net:inject-requestParameter('','')) gt 0) then
                        concat('?', string-join(net:inject-requestParameter('',''), '&amp;'))
                    else ()
                )
            return
                <link rel="alternate" hreflang="{$language}" href="{$url}"/>
};

declare 
    function gui:rdfUrl($node as node(), $model as map(*), $wid as xs:string*, $aid as xs:string*, $lid as xs:string*) as element()? {
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
                                                             "search.html",
                                                             "workingPaper.html"
                                                            )) then
                ()
         else if (ends-with(request:get-uri(), "/author.html")) then
                <link rel="meta" type="application/rdf+xml" href="{concat($config:dataserver, '/', $aid, '.rdf')}"/>
         else if (ends-with(request:get-uri(), "/work.html")) then
                <link rel="meta" type="application/rdf+xml" href="{concat($config:dataserver, '/', $wid, '.rdf')}"/>
         else if (ends-with(request:get-uri(), "/lemma.html")) then
                <link rel="meta" type="application/rdf+xml" href="{concat($config:dataserver, '/', $lid, '.rdf')}"/>
         else
                ()
};

declare function gui:iiifUrl($node as node(), $model as map(*), $wid as xs:string*) as element() {
    <link rel="meta" type="application/ld+json;profile='http://iiif.io/api/presentation/2/context.json'" href="{concat('iiif-out.xql?wid=', $wid)}"/>
};

declare %templates:default("lang", "en") 
    function gui:description($node as node(), $model as map(*), $lang as xs:string) as xs:string {
        let $document   := functx:substring-after-last(request:get-url(), '/')
        let $id         := for $par in request:get-parameter-names()
                                return if (matches($par, ".{1,2}id")) then request:get-parameter($par, '') else ()
        let $template   := 
            switch (substring-before($document, '.html'))
                case 'author'                   return <i18n:text key="metaAuthor">Biobibliographische Informationen über</i18n:text>
                case 'lemma'                    return <i18n:text key="metaLemma">Sachartikel zu</i18n:text>
                case 'workingPaper'             return <i18n:text key="metaWP">SvSal Working Paper</i18n:text>
                case 'work'                     return <i18n:text key="metaWork">Leseansicht von</i18n:text>
                case 'workDetails'              return <i18n:text key="metaWorkDetails">Bibliographische Daten zu</i18n:text>
                case 'index'                    return <i18n:text key="metaIndex">Eine Sammlung digitaler Quellen und ein Wörterbuch der juridisch-politischen Diskurse von iberischen Theologen, Juristen und Philosophen der Frühen Neuzeit.</i18n:text>
                case 'search'                   return <i18n:text key="metaSearch">Suche in Texten der Salmanticenser Autoren, in Wörterbuch- und biographischen Artikeln sowie in Working Papers über die Schule von Salamanca.</i18n:text>
                case 'contact'                  return <i18n:text key="metaContact">Möglichkeiten, das Projekt "Die Schule von Salamanca" zu kontaktieren und über Neuigkeiten auf dem Laufenden zu bleiben.</i18n:text>
                case 'editorialWorkingPapers'   return <i18n:text key="metaEditorial">Richtlinien und Vorgaben für die Einreichung von Vorschlägen für die Working Paper Reihe des Projekts "Die Schule von Salamanca".</i18n:text>
                case 'guidelines'               return <i18n:text key="metaGuidelines">Editionsrichtlinien der Erstellung der digitalen Quellenedition des Projekts "Die Schule von Salamanca".</i18n:text>
                case 'project'                  return <i18n:text key="metaProject">Allgemeine Informationen über das Projekt "Die Schule von Salamanca. Eine digitale Quellenedition und ein Wörterbuch ihrer juridisch-politischen Sprache".</i18n:text>
                case 'news'                     return <i18n:text key="metaNews">Neuigkeiten, Ankündigungen und kurze Blog-Texte des Projekts "Die Schule von Salamanca" über Theorie, Methodologie, Technik und Weiteres.</i18n:text>
                case 'works'                    return <i18n:text key="metaWorks">Überblick über die Quellen, die im Rahmen der digitalen Quellenedition in Text und Bild verfügbar sind. Filter- und Sortierbar.</i18n:text>
                case 'authors'                  return <i18n:text key="metaAuthors">Überblick über die Autoren, deren Texte in der Quellenedition und die weiterhin durch biographische Artikel beschrieben sind.</i18n:text>
                case 'dictionary'               return <i18n:text key="metaDictionary">Überblick über die im Projekt erarbeiteten Sachartikel des Wörterbuchs der juridisch-politischen Sprache der Schule von Salamanca</i18n:text>
                case 'workingPapers'            return <i18n:text key="metaWPs">Überblick über die Working Papers zur Schule von Salamanca, die im Rahmen der vom Projekt veranstalteten Reihe erschienen sind.</i18n:text>
                case 'participants'             return <i18n:text key="metaParticipants"/>
                default return ()
        let $templateLocalized  := i18n:process($template, $lang, "/db/apps/salamanca/data/i18n", "de")
        let $return             := concat($templateLocalized, if (exists($id)) then ' ' || gui:docSubjectname($id) else ())  
        let $debug              := if ($config:debug = "trace") then console:log("Meta description: " || $return) else ()
        return $return 
};

declare %templates:default("lang", "en") 
    function gui:metaDescription($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element() {
        <meta name="description" content="{gui:description($node, $model, $lang)}"/>
};

declare %private function gui:docSubjectname($id as xs:string) as xs:string? {
    let $resourceId := sutil:normalizeId($id)
    return
        switch (substring($resourceId, 1, 2))
            case 'A0'
              return if (doc-available($config:tei-authors-root || '/' || $resourceId || '.xml')) then 
                  sutil:formatName(doc($config:tei-authors-root || '/' || $resourceId || '.xml')//tei:listPerson/tei:person[1]/tei:persName)
              else ()
            case 'W0'
              return if (doc-available($config:tei-works-root || '/' || $resourceId || '.xml')) then
                  string-join(doc($config:tei-works-root || "/" || $resourceId || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') ||
                                 ': ' || doc($config:tei-works-root || "/" || $resourceId || ".xml")//tei:sourceDesc//tei:monogr/tei:title[@type = 'short']/string()
              else ()
            case 'L0'
              return if (doc-available($config:tei-lemmata-root || '/' || $resourceId || '.xml')) then
                  doc($config:tei-lemmata-root || '/' || $resourceId || '.xml')//tei:titleStmt//tei:title[@type = 'short']/string()
              else ()
            case 'WP'
              return if (doc-available($config:tei-workingpapers-root || '/' || $resourceId || '.xml')) then
                  doc($config:tei-workingpapers-root || '/' || $resourceId || '.xml')//tei:titleStmt/tei:title[@type = 'short']/string()
              else ()
            default return ()
};

declare function gui:firstLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWorkId")
    return 
        if (not (xmldb:collection-available($config:html-root || "/" || $workId))) then ()
        else
            let $targetFragment := substring(functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1], 1, string-length(functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1]) - 5)
            let $url := "work.html?wid=" || $workId || "&amp;frag=" || $targetFragment
            let $debug := if ($config:debug = "trace") then console:log("Firstlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
            return if ($url) then
                        <link rel="first" href="{$url}"/>
                    else ()
};

declare function gui:prevLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then sutil:normalizeId($wid) else $model("currentWorkId")
    let $htmlPath       := $config:html-root || "/" || $workId
    return  
        if (not (xmldb:collection-available($htmlPath))) then ()
        else
            let $targetFragment := 
                if ($frag || ".html" = xmldb:get-child-resources($htmlPath)) then
                    $frag || ".html"
                else functx:sort(xmldb:get-child-resources($htmlPath))[1]
            let $url := doc($config:html-root || '/' || sutil:normalizeId($wid) || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="previous"]/@href/string()
            let $debug := if ($config:debug = "trace") then console:log("Prevlink: " || $url || " ($wid: " || sutil:normalizeId($wid) || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
            return 
                if ($url) then
                    <link rel="prev" href="{$url}"/>
                else ()
};

declare function gui:nextLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then sutil:normalizeId($wid) else $model("currentWorkId")
    let $htmlPath       := $config:html-root || "/" || $workId
    return  
        if (not(xmldb:collection-available($htmlPath))) then ()
        else
            let $targetFragment :=
                if ($frag || ".html" = xmldb:get-child-resources($htmlPath)) then
                    $frag || ".html"
                else
                    functx:sort(xmldb:get-child-resources($htmlPath))[1]
            let $url := doc($config:html-root || '/' || sutil:normalizeId($wid) || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="next"]/@href/string()
            let $debug := if ($config:debug = "trace") then console:log("Nextlink: " || string-join($url, " ; ") || " ($wid: " || sutil:normalizeId($wid) || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
            return if ($url) then
                        <link rel="next" href="{$url}"/>
                    else ()
};

declare function gui:footer($node as node(), $model as map(*), $lang as xs:string) {
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
                    <a href="contact.html"><i class="far fa-envelope"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a> 
                    | <a  href="legal.html"><i class="fa fa-balance-scale"></i>&#32;&#32;<i18n:text key='legal'>Datenschutz &amp; Impressum</i18n:text></a> 
                    </p>
                        <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="far fa-copyright"></i>&#32;&#32;<span title="{$username}"><i18n:text key="projectName"/> 2015-2019</span>
                    </p>
                </div>
            </div>
            <div class="col-sm-12 hidden-lg hidden-md" style="text-align: center">
                <p>
                <a href="contact.html"><i class="far fa-envelope"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a>
                    | <a  href="legal.html"><i class="fa fa-balance-scale"></i>&#32;&#32;<i18n:text key='legal'>Datenschutz &amp; Impressum</i18n:text></a>            </p>
                    <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="fa fa-copyright"></i>&#32;&#32;<span title="{$username}"><i18n:text key="projectName"></i18n:text> 2015-2018</span>
                </p>
            </div>
            <!-- CC BY -->        
            <div class="row">   
                <div class="col-md-12" style="text-align: center">
               <!--<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />-->
               <i18n:text key="licenceDesc"/>{$config:nbsp}<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><i18n:text key="licenceCC40">Creative Commons Namensnennung 4.0 International Lizenz</i18n:text><span class="glyphicon glyphicon-new-window" style="padding-left:0.3em;"></span></a>.
               </div>
           </div>
        </span>
     return i18n:process($footer, $lang, "/db/apps/salamanca/data/i18n", "de")
};    

