xquery version "3.0";

declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace sphinx      = "http://www.salamanca.school/xquery/sphinx"          at "modules/sphinx.xqm";

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

let $mode   := request:get-parameter('mode',    'html')
let $wid    := request:get-parameter('wid',     'W0013')
let $field  := request:get-parameter('field',   'corpus')
let $q      := request:get-parameter('q',       '')
let $sort   := request:get-parameter('sort',    '2')
let $sortby := request:get-parameter('sortby',  'sphinx_fragment_number')
let $ranker := request:get-parameter('ranker',  '2')
let $offset := request:get-parameter('offset',  '0')
let $limit  := request:get-parameter('limit',   '10')
let $lang   := request:get-parameter('lang',    'en')

let $output :=  if ($mode = "load") then
                    sphinx:loadSnippets('all')
                else if ($mode = "details") then
                    sphinx:details($wid, $field, $q, $offset, $limit, $lang)
                else ()
return $output
