xquery version "3.0";

declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal               = "http://salamanca.adwmainz.de";
declare namespace opensearch       = "http://a9.com/-/spec/opensearch/1.1/";
import module namespace sphinx      = "http://salamanca/sphinx"          at "modules/sphinx.xql";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";
import module namespace i18n        = "http://exist-db.org/xquery/i18n"  at "modules/i18n.xql";
import module namespace config      = "http://salamanca/config"          at "modules/config.xqm";
import module namespace xmldb       = "http://exist-db.org/xquery/xmldb";
import module namespace httpclient  = "http://exist-db.org/xquery/httpclient";


(: declare copy-namespaces no-preserve, inherit; :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";
declare variable $snippetLength  := 1200;

let $mode   := request:get-parameter('mode',    'html')
let $wid    := request:get-parameter('wid',     'W0013')
let $field  := request:get-parameter('field',   'corpus')
let $q      := request:get-parameter('q',       '')
let $sort   := request:get-parameter('sort',    '2')
let $sortby := request:get-parameter('sortby',  'sphinx_fragment_number')
let $ranker := request:get-parameter('ranker',  '2')
let $offset := request:get-parameter('offset',  '0')
let $limit  := request:get-parameter('limit',   '10')



let $output :=  if ($mode = "load") then
                    sphinx:loadSnippets('*')
                else if ($mode = "details") then
                    sphinx:details($wid, $field, $q, $offset, $limit)
                else
                    admin:sphinx-out(<div/>, map{ 'dummy':= 'dummy'}, $wid, $mode)
return $output
