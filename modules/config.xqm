xquery version "3.1";

(: ####++++----

    Configuration variables defining the application context, and helper functions 
    to access the application context from within a module/template.

 ----++++#### :)

module namespace config         = "https://www.salamanca.school/xquery/config";

declare namespace tei           = "http://www.tei-c.org/ns/1.0";

declare namespace exist         = "http://exist.sourceforge.net/NS/exist";
declare namespace expath        = "http://expath.org/ns/pkg";
declare namespace repo          = "http://exist-db.org/xquery/repo";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace system        = "http://exist-db.org/xquery/system";
declare namespace util          = "http://exist-db.org/xquery/util";
declare namespace xhtml         = "http://www.w3.org/1999/xhtml";

import module namespace console = "http://exist-db.org/xquery/console";

import module namespace i18n    = "http://exist-db.org/xquery/i18n"     at "i18n.xqm";


(: ==================================================================================== :)
(: OOOooo... Configurable Section for the School of Salamanca Web-Application ...oooOOO :)

declare variable $config:debug        := "info"; (: possible values: trace, info, none :)
declare variable $config:instanceMode := "prod"; (: possible values: testing, staging, production, fakeprod :)
declare variable $config:contactEMail := "info.salamanca@adwmainz.de";
declare variable $config:defaultProdserver := 'salamanca.school';
declare variable $config:defaultTestserver := 'salamanca.school';

(: Configure Servers :)
declare variable $config:proto          := "https"; (: if (request:get-header('X-Forwarded-Proto') = "https") then "https" else request:get-scheme(); :)
declare variable $config:subdomains     := ("www", "blog", "facs", "search", "data", "api", "tei", "id", "files", "ldf", "software");
declare variable $config:serverdomain := 
    if ($config:instanceMode = ("production", "fakeprod")) then
        let $debug := if ($config:debug = "trace") then console:log("Forcing $config:serverdomain to be " || $config:defaultProdserver || ".") else ()
        return $config:defaultProdserver
    else if (substring-before(request:get-header('X-Forwarded-Host'), ".") = $config:subdomains)
        then substring-after(request:get-header('X-Forwarded-Host'), ".")
    else if(request:get-header('X-Forwarded-Host'))
        then request:get-header('X-Forwarded-Host')
    else if(substring-before(request:get-server-name(), ".") = $config:subdomains)
        then substring-after(request:get-server-name(), ".")
    else
        let $fallbackDomain := $config:defaultTestserver (: request:get-server-name() :)
        let $alert := if ($config:debug = "trace") then console:log("Warning! Dynamic $config:serverdomain is uncertain, using servername " || $fallbackDomain || ".") else ()
        return $fallbackDomain
    ;
 
(: API :)

declare variable $config:currentApiVersion := 'v1';

declare variable $config:apiEndpoints   := 
    map  {
        "v1": ("texts", "search", "codesharing", "xtriples")
    };
(: valid API parameters and values, aligned with the respective 'format' parameter's values; if there is no explicite value 
    stated for a parameter (such as 'q'), the parameter may have any string value (sanitization happens elsewhere) :)
declare variable $config:apiFormats := 
    map {
        'html': ('mode=edit', 'mode=orig', 'mode=meta', 'q', 'lang=de', 'lang=en', 'lang=es', 'viewer', 'frag'),
        'iiif': ('canvas'),
        'jpg': (),
        'rdf': (),
        'tei': ('mode=meta', 'mode=full'),
        'txt': ('mode=edit', 'mode=orig')
    };
    
    
(: SERVER DOMAINS :)

declare variable $config:webserver      := $config:proto || "://www."    || $config:serverdomain;
declare variable $config:blogserver     := $config:proto || "://blog."   || $config:serverdomain;
declare variable $config:searchserver   := $config:proto || "://search." || $config:serverdomain;
(: declare variable $config:imageserver    := $config:proto || "://facs."   || $config:serverdomain;:)
declare variable $config:imageserver    := "https://facs.salamanca.school";
(:declare variable $config:imageserver    := "https://www.test.salamanca.school";:)
declare variable $config:dataserver     := $config:proto || "://data."   || $config:serverdomain;
declare variable $config:teiserver      := $config:proto || "://tei."    || $config:serverdomain;
declare variable $config:resolveserver  := $config:proto || "://"        || $config:serverdomain;
declare variable $config:idserver       := $config:proto || "://id."     || $config:serverdomain;
declare variable $config:softwareserver := $config:proto || "://files."  || $config:serverdomain;
declare variable $config:apiserver      := $config:proto || "://api."    || $config:serverdomain;
declare variable $config:apiserverTexts := $config:apiserver || '/v1/texts';
declare variable $config:lodServer      := $config:apiserver || '/v1/xtriples';
declare variable $config:caddyAPI       := "http://localhost:2019";
declare variable $config:caddyRoutes    := $config:caddyAPI || "/id/routing_map/mappings";


(: iiif-specific variables :)
declare variable $config:iiifImageServer        := $config:imageserver || "/iiif/image/";
declare variable $config:iiifPresentationServer := $config:imageserver || "/iiif/presentation/";

(: TODO: This is not used anymore, but we have yet to remove references to this variable. :)
declare variable $config:svnserver := "";

(: the digilib image service :)
(:declare variable $config:digilibServerScaler     := "https://c104-131.cloud.gwdg.de:8443/digilib/Scaler/IIIF/svsal!";:)
declare variable $config:digilibServerScaler     := "https://c099-013.cloud.gwdg.de/digilib/Scaler/IIIF/svsal!";
(: the digilib manifest service :)
(:declare variable $config:digilibServerManifester := "https://c104-131.cloud.gwdg.de:8443/digilib/Manifester/IIIF/svsal!";:)
declare variable $config:digilibServerManifester := "https://c099-013.cloud.gwdg.de/digilib/Manifester/IIIF/svsal!";

declare variable $config:urnresolver             := 'http://nbn-resolving.de/urn/resolver.pl?';

(: Configure html rendering :)
declare variable $config:chars_summary             := 60;  (: When marginal notes, section headings etc. have to be shortened, at which point? :)
declare variable $config:fragmentationDepthDefault := 4;   (: At which level should xml to html fragmentation occur by default? 3 should be right below front/body/back as of 20230606. :)

(: Configure Search variables :)
declare variable $config:sphinxRESTURL          := $config:searchserver || "/lemmatized";    (: The search server running an opensearch interface :)
declare variable $config:snippetLength          := 1200;    (: How long are snippets with highlighted search results on the search page? :)
declare variable $config:searchMultiModeLimit   := 5;       (: How many entries of each category are displayed when doing a search in "everything" mode? :)

(: Configure miscellaneous settings :)
declare variable $config:repository-uri := xs:anyURI($config:svnserver || '/04-39/trunk/svsal-data');    (: The svn server holding our data :)
declare variable $config:lodFormat      := "rdf";
declare variable $config:defaultLang    := "en";            (: en, es, or de :)
declare variable $config:stats-limit    := 15;              (: How many lemmata are evaluated on the stats page? :)
declare variable $config:export-folder  := "/exist/data/export/";

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
                                                'editorial-workingpapers',
                                                'guidelines',
                                                'project',
                                                'news',
                                                'works',
                                                'authors',
                                                'dictionary',
                                                'workingpapers'
                                                );
declare variable $config:databaseEntries     := ('authors',
                                                'works',
                                                'workdetails',
                                                'lemmata',
                                                'workingpapers',
                                                'news'
                                                );

(: Scholarly citation labels for structural units (div/@type, milestone/@unit, ...) :)
(: labels marked as 'isCiteRef': true() are used for building citation references; 
   (almost) all div labels are used for making TOC labels:)
declare variable $config:citationLabels :=
    map {
        (: div/@type and milestone/@unit (make sure that these labels are different from the element names defined below!): :)
        'additional': map {'full': 'addendum', 'abbr': 'add.', 'isCiteRef': true()},
        'administrative': map {'full': 'administratio', 'abbr': 'admin.', 'isCiteRef': true()},
        'article': map {'full': 'articulus', 'abbr': 'art.', 'isCiteRef': true()},
        'book': map {'full': 'liber', 'abbr': 'lib.', 'isCiteRef': true()},
        'chapter': map {'full': 'capitulum', 'abbr': 'cap.', 'isCiteRef': true()},
        'colophon': map {'full': 'colophon', 'abbr': 'coloph.', 'isCiteRef': true()},
        'commentary': map {'full': 'commentarius', 'abbr': 'comment.', 'isCiteRef': true()},
        'conclusion': map {'full': 'conclusio', 'abbr': 'concl.', 'isCiteRef': true()},
        'contained_work': (),
        'contents': map {'full': 'tabula', 'abbr': 'tab.', 'isCiteRef': true()},
        'corrigenda': map {'full': 'corrigenda', 'abbr': 'corr.', 'isCiteRef': true()},
        'dedication': map {'full': 'dedicatio', 'abbr': 'dedic.', 'isCiteRef': true()},
        'dict': map {'full': 'index verborum', 'abbr': 'ind.', 'isCiteRef': true()},
        'disputation': map {'full': 'disputatio', 'abbr': 'disp.', 'isCiteRef': true()},
        'doubt': map {'full': 'dubium', 'abbr': 'dub.', 'isCiteRef': true()},
        'entry': map {'full': 'item', 'abbr': 'item', 'isCiteRef': true()},
        'foreword': map {'full': 'prooemium', 'abbr': 'pr.', 'isCiteRef': true()},
        'gloss': map {'full': 'glossa', 'abbr': 'gl.', 'isCiteRef': true()},
        'index': map {'full': 'index', 'abbr': 'ind.', 'isCiteRef': true()},
        'law': map {'full': 'lex', 'abbr' :'l.', 'isCiteRef': true()},
        'lecture': map {'full': 'relectio', 'abbr': 'relect.', 'isCiteRef': true()},
        'partida': map {'full': 'partida', 'abbr': 'part.', 'isCiteRef': true()},
        'map': (),
        'number': map {'full': 'numerus', 'abbr': 'num.', 'isCiteRef': true()}, (: only in milestone :)
        'part': map {'full': 'pars', 'abbr': 'pars', 'isCiteRef': true()},
        'preface': map {'full': 'praefatio', 'abbr': 'praef.', 'isCiteRef': true()},
        'privileges': map {'full': 'privilegium', 'abbr': 'priv.', 'isCiteRef': true()},
        'question': map {'full': 'quaestio', 'abbr': 'q.', 'isCiteRef': true()},
        'section': map {'full': 'sectio', 'abbr': 'sect.', 'isCiteRef': true()},
        'segment': map {'full': 'sectio', 'abbr': 'sect.', 'isCiteRef': true()}, 
        'source': map {'full': 'fontes', 'abbr': 'fon.'},
        'title': map {'full': 'titulus', 'abbr': 'tit.', 'isCiteRef': true()},
        'unknown': (),
        'work_part': (),
        (: element names (must be different from the div/milestone types/units defined above): :)
        'argument': map { 'full': 'argumentum', 'abbr': 'arg.', 'isCiteRef': true()},
        'back': map {'full': 'appendix', 'abbr': 'append.', 'isCiteRef': true()},
        'front': map {'full': 'front', 'abbr': 'front.'},
        'titlePage': map {'full': 'titulus', 'abbr': 'tit.'},
        'pb': map {'full': 'pagina', 'abbr': 'pag.', 'isCiteRef': true()},
        'p': map {'full': 'paragraphus', 'abbr': 'paragr.', 'isCiteRef': true()},
        'note': map {'full': 'nota', 'abbr': 'not.', 'isCiteRef': true()}
    };
    (: TODO: page with isCiteRef = true()? which abbr. ('p.' is already taken)? :)



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
        else $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:temp           := concat($config:app-root, "/temp");
declare variable $config:toc-root       := concat($config:app-root, "/toc");

declare variable $config:data-root      := concat($config:app-root, "/data");
declare variable $config:i18n-root      := concat($config:data-root, "/i18n"); (: to be used in i18n:process() :)
declare variable $config:temp-root      := concat($config:data-root, "/temp");

declare variable $config:resources-root := concat($config:app-root, "/resources");
declare variable $config:files-root     := concat($config:resources-root, "/files");


(: Path to the research data repository :)
declare variable $config:webdata-root := "xmldb:exist:///db/apps/salamanca-webdata";
(:
    let $descriptor :=
        collection(repo:get-root())//expath:package[@name = "https://salamanca.school/salamanca-webdata"]
    return
        util:collection-name($descriptor);
:)


(:
declare variable $config:webdata-root := 
    let $modulePath := replace(system:get-module-load-path(), '^(xmldb:exist://)?(embedded-eXist-server)?(.+)$', '$3')
    return concat(substring-before($modulePath, "/salamanca/"), "/salamanca-webdata");
:)
declare variable $config:stats-root             := concat($config:webdata-root, "/stats");
declare variable $config:html-root              := concat($config:webdata-root, "/html");
declare variable $config:index-root             := concat($config:webdata-root, "/index");
declare variable $config:crumb-root             := concat($config:webdata-root, "/crumbtrails");
declare variable $config:pdf-root               := concat($config:webdata-root, "/pdf");
declare variable $config:txt-root               := concat($config:webdata-root, "/txt");
declare variable $config:nlp-root               := concat($config:webdata-root, "/nlp");
declare variable $config:snippets-root          := concat($config:webdata-root, "/snippets");
declare variable $config:iiif-root              := concat($config:webdata-root, "/iiif");
declare variable $config:routes-root            := concat($config:webdata-root, "/routes");
declare variable $config:corpus-zip-root        := concat($config:webdata-root, '/corpus-zip');
declare variable $config:rdf-root               := concat($config:webdata-root, "/rdf");
declare variable $config:rdf-works-root         := concat($config:rdf-root, '/works');
declare variable $config:rdf-authors-root       := concat($config:rdf-root, '/authors');
declare variable $config:rdf-lemmata-root       := concat($config:rdf-root, '/lemmata');
declare variable $config:rdf-sub-roots          := ($config:rdf-authors-root,
                                                    $config:rdf-works-root,
                                                    $config:rdf-lemmata-root);
declare variable $config:trash-root             := concat($config:webdata-root, "/trash");

(:This is  test comment, MAH 4.02.2022 :)


(: Paths to the TEI data repositories :)
(:
declare variable $config:tei-root :=
    let $descriptor :=
        collection(repo:get-root())//expath:package[@name = "https://salamanca.school/salamanca-tei"]
    return
        util:collection-name($descriptor);
:)
declare variable $config:tei-root       := 
    let $modulePath := replace(system:get-module-load-path(), '^(xmldb:exist://)?(embedded-eXist-server)?(.+)$', '$3')
    return concat(substring-before($modulePath, "/salamanca/"), "/salamanca-tei");

declare variable $config:tei-authors-root       := concat($config:tei-root, "/authors");
declare variable $config:tei-lemmata-root       := concat($config:tei-root, "/lemmata");
declare variable $config:tei-workingpapers-root := concat($config:tei-root, "/workingpapers");
declare variable $config:tei-works-root         := concat($config:tei-root, "/works");
declare variable $config:tei-meta-root          := concat($config:tei-root, "/meta");
declare variable $config:tei-sub-roots          := ($config:tei-authors-root,
                                                    $config:tei-lemmata-root,
                                                    $config:tei-workingpapers-root,
                                                    $config:tei-works-root);
declare variable $config:tei-specialchars       := doc($config:tei-meta-root || '/specialchars.xml')//tei:charDecl;

(: declare variable $config:home-url   := replace(replace(replace(request:get-url(), substring-after(request:get-url(), '/salamanca'), ''),'/rest/', '/'), 'localhost', 'h2250286.stratoserver.net'); :)

declare variable $config:repo-descriptor        := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
declare variable $config:expath-descriptor      := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

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

declare function config:errorhandler($netVars as map(*)*) {
    if (($config:instanceMode = "staging") or ($config:debug = "trace") or ("debug=trace" = $netVars('params')) ) then ()
    else
        <error-handler>
            <forward url="{$netVars('controller')}/error-page.html" method="get"/>
            <forward url="{$netVars('controller')}/modules/view.xql"/>
        </error-handler>
};
