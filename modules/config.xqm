xquery version "3.0";

module namespace config         = "http://salamanca/config";
declare namespace repo          = "http://exist-db.org/xquery/repo";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace session       = "http://exist-db.org/xquery/session";
declare namespace sm            = "http://exist-db.org/xquery/securitymanager";
declare namespace system        = "http://exist-db.org/xquery/system";
declare namespace templates     = "http://exist-db.org/xquery/templates";
declare namespace util          = "http://exist-db.org/xquery/util";

declare namespace xhtml         = "http://www.w3.org/1999/xhtml";
declare namespace expath        = "http://expath.org/ns/pkg";
declare namespace pack          = "http://expath.org/ns/pkg";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace app           = "http://salamanca/app";
import module namespace net     = "http://salamanca/net"                at "net.xql";
import module namespace i18n    = "http://exist-db.org/xquery/i18n"     at "i18n.xql";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace functx  = "http://www.functx.com";

(: ==================================================================================== :)
(: OOOooo... Configurable Section for the School of Salamanca Web-Application ...oooOOO :)
declare variable $config:debug        := "info"; (: possible values: trace, info, none :)
declare variable $config:instanceMode := "production"; (: possible values: staging, production :)
declare variable $config:contactEMail := "info.salamanca@adwmainz.de";

(: Configure Servers :)
declare variable $config:proto          := if (request:get-header('X-Forwarded-Proto') = "https") then "https" else request:get-scheme();
declare variable $config:subdomains     := ("www", "blog", "facs", "search", "data", "api", "tei", "id", "files", "ldf", "software");
declare variable $config:serverdomain := 
    if (substring-before(request:get-header('X-Forwarded-Host'), ".") = $config:subdomains)
        then substring-after(request:get-header('X-Forwarded-Host'), ".")
    else if(request:get-header('X-Forwarded-Host'))
        then request:get-header('X-Forwarded-Host')
    else if(substring-before(request:get-server-name(), ".") = $config:subdomains)
        then substring-after(request:get-server-name(), ".")
    else
        let $alert := if ($config:debug = "trace") then console:log("Warning! Dynamic $config:serverdomain is uncertain, using servername " || request:get-server-name() || ".") else ()
        return request:get-server-name()
    ;

declare variable $config:webserver      := $config:proto || "://www."    || $config:serverdomain;
declare variable $config:blogserver     := $config:proto || "://blog."   || $config:serverdomain;
declare variable $config:searchserver   := $config:proto || "://search." || $config:serverdomain;
declare variable $config:imageserver    := $config:proto || "://facs."   || $config:serverdomain;
declare variable $config:dataserver     := $config:proto || "://data."   || $config:serverdomain;
declare variable $config:apiserver      := $config:proto || "://api."    || $config:serverdomain;
declare variable $config:teiserver      := $config:proto || "://tei."    || $config:serverdomain;
declare variable $config:resolveserver  := $config:proto || "://"        || $config:serverdomain;
declare variable $config:idserver       := $config:proto || "://id."     || $config:serverdomain;
declare variable $config:softwareserver := $config:proto || "://files."  || $config:serverdomain;

(: TODO: This is not used anymore, but we have yet to remove references to this variable. :)
declare variable $config:svnserver := "";

(: the digilib image service :)
declare variable $config:digilibServerScaler := "https://c104-131.cloud.gwdg.de:8443/digilib/Scaler/IIIF/svsal!";
(: the digilib manifest service :)
declare variable $config:digilibServerManifester := "https://c104-131.cloud.gwdg.de:8443/digilib/Manifester/IIIF/svsal!";

declare variable $config:urnresolver    := 'http://nbn-resolving.de/urn/resolver.pl?';

(: Configure html rendering :)
declare variable $config:chars_summary  := 75;              (: When marginal notes, section headings etc. have to be shortened, at which point? :)
declare variable $config:fragmentationDepthDefault  := 4;   (: At which level should xml to html fragmentation occur by default? :)

(: Configure Search variables :)
declare variable $config:sphinxRESTURL          := $config:searchserver || "/lemmatized";    (: The search server running an opensearch interface :)
declare variable $config:snippetLength          := 1200;    (: How long are snippets with highlighted search results on the search page? :)
declare variable $config:searchMultiModeLimit   := 5;       (: How many entries of each category are displayed when doing a search in "everything" mode? :)

(: Configure miscalleneous settings :)
declare variable $config:stats-limit    := 15;             (: How many lemmata are evaluated on the stats page? :)
declare variable $config:repository-uri := xs:anyURI($config:svnserver || '/04-39/trunk/svsal-data');    (: The svn server holding our data :)
declare variable $config:lodFormat      := "rdf";
declare variable $config:defaultLang    := "en";            (: en, es, or de :)

(: Configure special character entities :)
declare variable $config:nl             := "&#x0A;";     (: Newline #x0a (NL), #x0d (LF), #2029 paragraph separator :)
declare variable $config:quote          := "&#34;";
declare variable $config:zwsp           := "&#8203;";    (: A zero-width space :)
declare variable $config:nbsp           := "&#160;";     (: A non-breaking space :)
declare variable $config:tribullet      := "&#8227;";
declare variable $config:triangle       := "&#x25BA;";

declare variable $config:languages           := ('en', 'de', 'es');
declare variable $config:standardEntries     := ('index',
                                                'search',
                                                'contact',
                                                'editorialWorkingPapers',
                                                'guidelines',
                                                'project',
                                                'news',
                                                'works',
                                                'authors',
                                                'dictionary',
                                                'workingPapers'
                                                );
declare variable $config:databaseEntries     := ('authors',
                                                'works',
                                                'workDetails',
                                                'lemmata',
                                                'workingPapers',
                                                'news'
                                                );

(: OOOooo...                    End configurable section                      ...oooOOO :)
(: ==================================================================================== :)


(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

(: Path to the research data repository :)
declare variable $config:salamanca-data-root := 
    let $modulePath := replace(system:get-module-load-path(), '^(xmldb:exist://)?(embedded-eXist-server)?(.+)$', '$3')
    return concat(substring-before($modulePath, "/salamanca/"), "/salamanca-data");

declare variable $config:temp           := concat($config:app-root, "/temp");
declare variable $config:toc-root       := concat($config:app-root, "/toc");

(: Paths to the TEI data repositories :)
declare variable $config:tei-root       := concat($config:salamanca-data-root, "/tei");
declare variable $config:tei-authors-root := concat($config:salamanca-data-root, "/tei/authors");
declare variable $config:tei-lemmata-root := concat($config:salamanca-data-root, "/tei/lemmata");
declare variable $config:tei-news-root := concat($config:salamanca-data-root, "/tei/news");
declare variable $config:tei-workingpapers-root := concat($config:salamanca-data-root, "/tei/workingpapers");
declare variable $config:tei-works-root := concat($config:salamanca-data-root, "/tei/works");
declare variable $config:tei-sub-roots := ($config:tei-authors-root, $config:tei-lemmata-root, $config:tei-news-root, $config:tei-workingpapers-root, $config:tei-works-root);

declare variable $config:resources-root := concat($config:app-root, "/resources");
declare variable $config:data-root      := concat($config:app-root, "/data");
declare variable $config:html-root      := concat($config:data-root, "/html");
declare variable $config:snippets-root  := concat($config:data-root, "/snippets");
declare variable $config:rdf-root       := concat($config:salamanca-data-root, "/rdf");
declare variable $config:iiif-root      := concat($config:salamanca-data-root, "/iiif");

(: declare variable $config:home-url   := replace(replace(replace(request:get-url(), substring-after(request:get-url(), '/salamanca'), ''),'/rest/', '/'), 'localhost', 'h2250286.stratoserver.net'); :)

declare variable $config:repo-descriptor    := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
declare variable $config:expath-descriptor  := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

(: deprecated?:
declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};
:)

(:i18n ============================================:)
(:language switching Startseite: für Seitentitel im Tabulator, Titel "Die Schule von Salamanca", das Menü und alle Bottons der Startseite:)

(:declare %templates:wrap function config:tabTitle($node as node(), $model as map(*)) as text() {
    let $output := <i18n:text key="tab">Die Schule von Salamanca</i18n:text>
    return 
        i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  :)

declare function config:carousel ($node as node(), $model as map(*)){
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
declare function config:logo($node as node(), $model as map(*), $lang as xs:string) as element() {
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
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

(: Navigation:  create header menue and dropdown:)
declare function config:app-header($node as node(), $model as map(*), $lang as xs:string, $aid as xs:string?, $lid as xs:string?, $nid as xs:string?, $wpid as xs:string?, $wid as xs:string?) as element()  {
    let $output :=
        <div class="collapse navbar-collapse navbar-menubuilder">
            <menu class="nav navbar-nav">
                <!--{(:
                if(contains(request:get-url(), 'news')) then <li class="active"><a href="news.html?lang={$lang}"><span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text></a></li>
                else <li><a href="news.html?lang={$lang}"><span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text></a></li>
                :)} -->
                <li class="{if (contains(request:get-url(), 'news')) then 'active' else ()}">
                    <a href="{$config:blogserver}/?lang={$lang}">
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
                <!-- 
                    <li class="{if ( (contains(request:get-url(), 'dictionary')) or
                                 (contains(request:get-url(), 'lemma.'))        ) then 'active' else ()}">
                    <a href="dictionary.html">
                    <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;
                    <i18n:text key="dictionary">Wörterbuch</i18n:text></a></li> 
                -->
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
            <menu>
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

(: Navigation create Mobile-header menue and dropdown in work.html:)
declare function config:app-headerWork($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*) as element()  {
    let $output :=
    <div class="collapse navbar-collapse navbar-menubuilder">
        <div class="row">
            <menu class="nav navbar-nav">
                <!-- For tablet/mobile view: hidden on displays smaller than 1024px -->
                <li class="hidden-lg"><a href="{$config:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="de">Deutsch</i18n:text></a></li>                                               
                <li class="hidden-lg"><a href="{$config:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="en">Englisch</i18n:text></a></li>
                <li class="hidden-lg"><a href="{$config:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}"><i18n:text key="es">Spanisch</i18n:text></a></li>
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
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$config:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$config:webserver}/de/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">de</a>}
                  {if ($lang = 'en') then 
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$config:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$config:webserver}/en/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">en</a>}
                  {if ($lang = 'es') then 
                       <a  class="btn btn-info    navbar-btn lang-switch" href="{$config:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>
                   else 
                       <a  class="btn btn-default navbar-btn lang-switch" href="{$config:webserver}/es/{concat(request:get-attribute('$exist:resource'), if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (), string-join(net:inject-requestParameter('', ''), '&amp;'))}">es</a>}
                </div> 
            </menu>
        </div>
    </div>
    return
           i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) 
};  

(:create main links on landing page:)
declare %templates:wrap
    function config:langWorks($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="works.html">
            <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&#160;<i18n:text key="works">Werke</i18n:text>
        </a>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function config:langDictionary($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="dictionary.html">
            <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#160;<i18n:text key="dictionary">Wörterbuch</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function config:langAuthors($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a href="authors.html">
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span>&#160;<i18n:text key="authors">Autoren</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function config:langSearch($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a href="search.html">
            <span class="glyphicon glyphicon-search" aria-hidden="true"></span>&#160;<i18n:text key="search">Suche</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  
        
declare %templates:wrap
    function config:langWorkingPapers($node as node(), $model as map(*), $lang as xs:string) as element() {
    let $output := 
        <a  href="workingPapers.html">
            <i class="fa fa-pencil" aria-hidden="true"></i>&#160;<i18n:text key="workingPapers">Working Papers</i18n:text>
        </a>
    return i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  

declare %templates:wrap
    function config:langNews($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="news.html">
            <span class="glyphicon glyphicon-hand-right" aria-hidden="true"></span>&#160;<i18n:text key="news">Aktuelles</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};  
        
declare %templates:wrap
    function config:langPrDesc($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="project.html">
           <i class="fa fa-university" aria-hidden="true"></i>&#160;<i18n:text key="about">Projekt</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};
        
declare %templates:wrap
    function config:langProjektteam($node as node(), $model as map(*), $lang as xs:string) as element()  {
        if ($lang = 'en') then
            <a target="blank" href="http://www.salamanca.adwmainz.de/en/project-team-and-consultants.html">
               Project Team&#160;<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
            </a>
        else if ($lang = 'es') then
            <a target="blank" href="http://www.salamanca.adwmainz.de/es/el-equipo-de-proyecto-y-sus-consultores.html">
               Equipo del Proyecto&#160;<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
            </a>
        else
            <a target="blank" href="http://www.salamanca.adwmainz.de/projektbeteiligte.html">
               Projektteam&#160;<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
            </a>
};

declare %templates:wrap
    function config:langEdGuidelines($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="guidelines.html">
           <i class="fa fa-cogs" aria-hidden="true"></i>&#160;<i18n:text key="guidelines">Editionsrichtlinien</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};


declare %templates:wrap
    function config:langWPcreation($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="editorialWorkingPapers.html">
           <span class="glyphicon glyphicon-edit" aria-hidden="true"></span>&#160;<i18n:text key="getInvolved">Beitragen</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};
        
declare %templates:wrap
    function config:langContact($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="contact.html">
            <i class="fa fa-envelope-o" aria-hidden="true"></i>&#160;<i18n:text key="contact">Kontakt</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};       

declare %templates:wrap
    function config:searchInfoDetails($node as node(), $model as map(*), $lang as xs:string) as element()  {
    let $output := 
        <a  href="searchDetails.html">
           <i18n:text key="moreSearchDetails">Weitere Suchmöglichkeiten</i18n:text>
        </a>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))};   
        
(:~
 : Returns Meta-info generated from the repo-descriptor.
 : deprecated?
 :)
(:
declare function config:meta-info($node as node(), $model as map(*)) as element()* {
    <meta name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta name="creator" content="{$author/text()}"/>
};  
:)
(:~
 : ========================================================================================================================
 : Title for Browser-Tab for SingleView Work, -Lemma, -Working Paper, -Authors, -News
 :)
 (:Name wird zusammengesetzt, Nachname, Vorname:)
declare function config:formatName($persName as element()*) as xs:string? {
    let $return-string := for $pers in $persName
                                return
                                        if ($pers/@key) then
                                            normalize-space(xs:string($pers/@key))
                                        else if ($pers/tei:surname and $pers/tei:forename) then
                                            normalize-space(concat($pers/tei:surname, ', ', $pers/tei:forename, ' ', $pers/tei:nameLink, if ($pers/tei:addName) then ('&amp;nbsp;(&amp;lt;' || $pers/tei:addName || '&amp;gt;)') else ()))
                                        else if ($pers) then
                                            normalize-space(xs:string($pers))
                                        else 
                                            normalize-space($pers/text())
    return (string-join($return-string, ' &amp; '))
};
 
declare %templates:default("language", "en") 
    function config:meta-title($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $q as xs:string?) as element() {  
    let $output := 
                         if (ends-with(request:get-uri(), "/author.html")) then
                        <title>
                            {config:formatName($model("currentAuthor")//tei:person//tei:persName)} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
                    else if (ends-with(request:get-uri(), "/authors.html")) then
                        <title><i18n:text key="authors">Autoren</i18n:text> - <i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>

                    else if ($wid) then
                        <title>
                            {string-join(doc($config:tei-works-root || "/" || $wid || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') || ': ' ||
                             doc($config:tei-works-root || "/" || $wid || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string()} -
                             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
(:                    else if (request:get-parameter('wid', '')) then
                        <title>
                            {replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($config:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname/string())||': '||
                             replace(request:get-parameter('wid', ''), request:get-parameter('wid', ''), doc($config:tei-works-root || "/" || request:get-parameter('wid', '') || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string())} -
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

declare %templates:default("lang", "en") 
    function config:canonical-url($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element() {
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
                            concat($config:webserver, '/', $lang, '/', request:get-attribute('$exist:resource'))
                     else if (ends-with(request:get-uri(), "/author.html")) then
                            concat($config:webserver, '/', $lang, '/author.html?',       string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/work.html")) then
                            concat($config:webserver, '/', $lang, '/work.html?',         string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/lemma.html")) then
                            concat($config:webserver, '/', $lang, '/lemma.html?',        string-join(net:inject-requestParameter('',''), '&amp;'))
                     else if (ends-with(request:get-uri(), "/workingPaper.html")) then
                            concat($config:webserver, '/', $lang, '/workingPaper.html?', string-join(net:inject-requestParameter('',''), '&amp;'))
                     else
                            $config:webserver
        return
            <link rel="canonical" href="{$url}"/>
};

declare %templates:default("lang", "en") 
    function config:hreflang-url($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element()* {
        for $language in ('de', 'en', 'es')
            let $url := concat($config:webserver, '/', $language, '/', request:get-attribute('$exist:resource'),
                                      if (count(net:inject-requestParameter('','')) gt 0) then
                                          concat('?', string-join(net:inject-requestParameter('',''), '&amp;'))
                                      else ()
                              )
            return
                <link rel="alternate" hreflang="{$language}" href="{$url}"/>
};

declare 
    function config:rdf-url($node as node(), $model as map(*), $wid as xs:string*, $aid as xs:string*, $lid as xs:string*) as element() {
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

declare function config:iiif-url($node as node(), $model as map(*), $wid as xs:string*) as element() {
    <link rel="meta" type="application/ld+json;profile='http://iiif.io/api/presentation/2/context.json'" href="{concat('iiif-out.xql?wid=', $wid)}"/>
};

declare %templates:default("lang", "en") 
    function config:description($node as node(), $model as map(*), $lang as xs:string) as xs:string {
        let $document   := functx:substring-after-last(request:get-url(), '/')
        let $id         := for $par in request:get-parameter-names()
                                return if (matches($par, ".{1,2}id")) then request:get-parameter($par, '') else ()
        let $template   := switch (substring-before($document, '.html'))
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
                            default return ()
        let $templateLocalized  := i18n:process($template, $lang, "/db/apps/salamanca/data/i18n", "de")
        let $return             := concat($templateLocalized, if (exists($id)) then ' ' || local:docSubjectname($id) else ())  
        let $debug              := if ($config:debug = "trace") then console:log("Meta description: " || $return) else ()
        return $return 
};

declare %templates:default("lang", "en") 
    function config:meta-description($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $aid as xs:string*, $q as xs:string?) as element() {
        <meta name="description" content="{config:description($node, $model, $lang)}"/>
};

declare function local:docSubjectname($id as xs:string) as xs:string? {
        switch (substring($id, 1, 2))
            case 'A0'
                return if (doc-available($config:tei-authors-root || '/' || $id || '.xml')) then 
                    config:formatName(doc($config:tei-authors-root || '/' || $id || '.xml')//tei:listPerson/tei:person[1]/tei:persName)
                else ()
            case 'W0'
                return if (doc-available($config:tei-works-root || '/' || $id || '.xml')) then
                    string-join(doc($config:tei-works-root || "/" || $id || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') ||
                                   ': ' || doc($config:tei-works-root || "/" || $id || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string()
                else ()
            case 'L0'
                return if (doc-available($config:tei-lemmata-root || '/' || $id || '.xml')) then
                    doc($config:tei-lemmata-root || '/' || $id || '.xml')//tei:titleStmt//tei:title[@type = 'short']/string()
                else ()
            case 'WP'
                return if (doc-available($config:tei-workingpapers-root || '/' || $id || '.xml')) then
                    doc($config:tei-workingpapers-root || '/' || $id || '.xml')//tei:titleStmt/tei:title[@type = 'short']/string()
                else ()
            default return ()
};

declare function config:firstLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return if (not (xmldb:collection-available($config:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := substring(functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1], 1, string-length(functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1]) - 5)
                let $url := "work.html?wid=" || $workId || "&amp;frag=" || $targetFragment
                let $debug := if ($config:debug = "trace") then console:log("Firstlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="first" href="{$url}"/>
                        else ()
};

declare function config:prevLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return  if (not (xmldb:collection-available($config:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := if ($frag and $frag || ".html" = xmldb:get-child-resources($config:html-root || "/" || $workId)) then
                                            $frag || ".html"
                                        else
                                            functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1]
                let $url := doc($config:html-root || '/' || $wid || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="previous"]/@href/string()
                let $debug := if ($config:debug = "trace") then console:log("Prevlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="prev" href="{$url}"/>
                        else ()
};

declare function config:nextLink($node as node(), $model as map(*), $wid as xs:string?, $frag as xs:string?) as element(link)? {
    let $workId         := if ($wid) then $wid else $model("currentWork")/@xml:id
    return  if (not (xmldb:collection-available($config:html-root || "/" || $workId))) then
                ()
            else
                let $targetFragment := if ($frag and $frag || ".html" = xmldb:get-child-resources($config:html-root || "/" || $workId)) then
                                            $frag || ".html"
                                        else
                                            functx:sort(xmldb:get-child-resources($config:html-root || "/" || $workId))[1]
                let $url := doc($config:html-root || '/' || $wid || '/' || $targetFragment)//div[@id="SvSalPagination"]/a[@class="next"]/@href/string()
                let $debug := if ($config:debug = "trace") then console:log("Nextlink: " || $url || " ($wid: " || $wid || ", $frag: " || $frag || ", $targetFragment: " || $targetFragment || ").") else ()
                return if ($url) then
                            <link rel="next" href="{$url}"/>
                        else ()
};

(:Show tab-titles Lemma:)
(:declare %templates:default("language", "de") 
    function config:meta-titleLem($node as node(), $model as map(*), $lang as xs:string, $lid as xs:string?) as element() {      
    let $output := if (ends-with(request:get-uri(), "/lemma.html")) then
        <title>
            {$model("currentLemma")/tei:teiHeader//tei:author/tei:persName/tei:surname/string() || ", " ||
             $model("currentLemma")/tei:teiHeader//tei:titleStmt/tei:title[@type = 'short']/string()} -
             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    else
        <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
}; :) 
(:Show tab-titles WorkingPaper:)
(:declare %templates:default("language", "de") 
    function config:meta-titleWP($node as node(), $model as map(*), $lang as xs:string, $wpid as xs:string?) as element() {      
    let $output := if (ends-with(request:get-uri(), "/workingPaper.html")) then
        <title>Working Paper:
            {
             $model("currentWp")/tei:teiHeader//tei:titleStmt/tei:title[@type = 'short']/string()} -
             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    else
        <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
};
(\:Show tab-titles Author:\)
declare %templates:default("language", "de") 
    function config:meta-titleAut($node as node(), $model as map(*), $lang as xs:string, $aid as xs:string?) as element() {      
    let $output := if (ends-with(request:get-uri(), "/author.html")) then
        <title>
            {$model("currentAuthor")/tei:teiHeader//tei:author/tei:persName/tei:surname/string() || ", " ||
             $model("currentAuthor")/tei:teiHeader//tei:author/tei:persName/tei:forename/string()} -
             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text></title>
    else
        <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
};  
(\:Show tab-titles News:\)            
declare %templates:default("language", "de") 
    function config:meta-titleNews($node as node(), $model as map(*), $lang as xs:string, $nid as xs:string?) as element() {      
    let $output := if (ends-with(request:get-uri(), "/newsEntry.html")) then
        <title>
            {   if ($lang eq 'de') then $model('currentNews')//tei:title[@type='main'][@xml:lang='de']/string()
                else if ($lang eq 'en') then $model('currentNews')//tei:title[@type='main'][@xml:lang='en']/string()
                else if ($lang eq 'es') then $model('currentNews')//tei:title[@type='main'][@xml:lang='es']/string()
                else()} -
             <i18n:text key='titleHeader'>Die Schule von Salamanca</i18n:text>
        </title>
    else
        <title><i18n:text key="titleHeader">Die Schule von Salamanca</i18n:text></title>
 return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")
}; :) 

declare function config:footer ($node as node(), $model as map(*), $lang as xs:string) {
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
                <a href="http://www.rg.mpg.de"><img style="margin-top: 9%; float: right" class="img-responsive" src="resources/img/logos_misc/mpier.svg"/></a>
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
        <!-- contact, information, version -->
        <div class="row">
            <div class="col-md-12 hidden-sm hidden-xs" style="text-align: center">
            <br/>
                <p><a href="contact.html"><i class="fa fa-envelope-o"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a> | <a  href="project.html"><i18n:text key='imprint'>Impressum</i18n:text></a></p>
                    <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="fa fa-copyright"></i>&#32;&#32;<span title="{$username}">SvSal 2015</span>
                </p>
            </div>
        </div>
        <div class="col-sm-12 hidden-lg hidden-md" style="text-align: center">
            <p><a href="contact.html"><i class="fa fa-envelope-o"></i>&#32;&#32;<i18n:text key='contact'>Kontakt</i18n:text></a> | <a  href="project.html"><i18n:text key='imprint'>Impressum</i18n:text></a></p>
                <p><span style="color:#92A4B1;"></span>&#xA0;&#xA0; <i class="fa fa-copyright"></i>&#32;&#32;<span title="{$username}">SvSal 2015</span>
            </p>
        </div>
        <!-- CC BY -->        
        <div class="row">   
            <div class="col-md-12" style="text-align: center">
           <!--<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />-->
           <i18n:text key="licenceDesc">Für die Daten des Projekts "Die Schule von Salamanca" gilt eine</i18n:text>{$config:nbsp}<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><i18n:text key="licenceCC40">Creative Commons Namensnennung 4.0 International Lizenz</i18n:text> <span class="glyphicon glyphicon-new-window"></span></a>.
           </div>
       </div>
    </span>
     return i18n:process($footer, $lang, "/db/apps/salamanca/data/i18n", "de")
};   