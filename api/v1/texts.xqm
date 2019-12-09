xquery version "3.0" encoding "UTF-8";

(: ####++++----

    "Texts" API module

 ----++++#### :)

module namespace textsv1 = "http://api.salamanca.school/v1/texts";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
import module namespace rest = "http://exquery.org/ns/restxq";

import module namespace srest = "http://www.salamanca.school/xquery/srest" at "../srest.xqm";
import module namespace sutil = "http://www.salamanca.school/xquery/sutil" at "../../modules/sutil.xql";



(: RESTXQ API FUNCTIONS :)


(: complete corpus :)
declare
%rest:GET
%rest:path("/v1/texts")
%rest:query-param("format", "{$format}", "html")
function textsv1:getCorpus($format) {

  <result>
    <content>Hello Corpus</content>
  </result>
         
};


(: doc, based on "format" query param :)
declare 
%rest:GET
%rest:path("/v1/texts/{$rid}")
%rest:query-param("format", "{$format}", "html")
function textsv1:docRequest($rid, $format) {
    switch($format)
        case 'tei' return textsv1:TEIdeliverDoc($rid)
        default return ()
};


(: doc, based on "Accept" header (each mimetype has its own restxq function) :)
declare 
%rest:GET
%rest:path("/v1/texts/{$rid}")
%rest:produces("application/tei+xml")
function textsv1:TEIdocRequestThroughAcceptHeader($rid, $format) {
    textsv1:TEIdeliverDoc($rid)
};



(: CONTENT DELIVERY FUNCTIONS, based on format type :)


declare %private function textsv1:TEIdeliverDoc($rid as xs:string) {
    <teiContent>Hello {$rid}</teiContent>
};


(: RESOURCE VALIDATION :)

(:
~ Parses and validates a resource id of the form "work_id[:passage_id]". Returns a map with normalized ids for the
~ work, passage (if any), and the respective TEI dataset, as well as information about the status (available vs. 
~ not (yet) available) of each component. (For details see the comments in $valMap).
:)
declare function textsv1:validateResourceId($rid as xs:string?) as map(*) {
    (: the returned map has negative or no values by default;
       while validating the resource more and more deeply (see below), we update the map gradually :)
    let $valMap := map {
        'work_id': (), (: the id of the work (5-place, without any volume suffix) :)
        'rid_main': (), (: the "main" part of the resource id, before any colon or dot (if there are any). Case is normalized :)
        'tei_doc': (), (: the id of the TEI dataset for the work/volume, as found in $config:tei-works-root (without ".xml") :)
        'tei_status': -1, (: status of the work: see sutil:WRKvalidateId() :)
        'passage': (), (: the id of the passage :)
        'passage_status': 0, (: the status of the passage: 1 if passage is available, 0 if not :)
        'valid': false(), (: states if resource is valid/available :)
        'wellformed': false(), (: states if resource id is syntactically well-formed :)
        'legacy_mode': () (: legacy resource ids may contain a mode parameter such as "W0004.orig", which may be relevant for HTML/TXT delivery :)
    }
    
    (: first, we parse the resource id and determine the main component (before ":" or "."), 
        thereby also checking if the request is generally well-formed :)
    let $tokenized := tokenize($rid, ':')    
    let $valMap := 
        if (count($tokenized) eq 2 and matches($tokenized[1], '^[Ww]\d{4}$')) then 
            let $valMap := map:put($valMap, 'passage', $tokenized[2]) (: no case normalization with passage IDs :)
            return map:put($valMap, 'rid_main', upper-case($tokenized[1]))
        else if (count($tokenized) eq 1 and matches($tokenized, '^[Ww]\d{4}(_[Vv][Oo][Ll]\d{2})?$')) then 
            (: if there is no passage, Wxxxx_Volxx is allowed to specify the volume (for backwards compatibility) :)
            map:put($valMap, 'rid_main', translate($tokenized, 'wvOL', 'WVol'))
        else if (count($tokenized) eq 1 and matches($tokenized, '^[Ww]\d{4}(_[Vv][Oo][Ll]\d{2})?\.(orig|edit)$')) then
            let $valMap := map:put($valMap, 'legacy_mode', replace($tokenized, '^[Ww]\d{4}(_[Vv][Oo][Ll]\d{2})?\.(orig|edit)$', '$2'))
            return map:put($valMap, 'rid_main', translate(substring-before($tokenized, '.'), 'wvOL', 'WVol'))
        else $valMap
    
    (: now we can validate the resource id with all its components :)
    let $valMap :=
        if ($valMap('rid_main')) then
        (: we have a well-formed request, including at least an rid_main (such as "W0034") :)
            let $valMap := map:put($valMap, 'wellformed', true())
            (: we put work and tei_doc already into the map (like passage above), regardless of whether they are valid: :)
            let $valMap := map:put($valMap, 'work_id', substring($valMap('rid_main'), 1, 5))
            let $teiId := 
                if (matches(lower-case($valMap('passage')), '^vol\d{1,2}$')) then
                    format-number(xs:integer(replace($valMap('passage'), '^vol(\d{1,2})$', '$1')), '00')
                else $valMap('rid_main')
            let $valMap := map:put($valMap, 'tei_doc', $teiId)
            (: now comes the actual validation: :)
            let $valMap := map:put($valMap, 'tei_status', sutil:WRKvalidateId($valMap('tei_doc')))
            return
                if ($valMap('tei_status') eq 2) then
                (: the work/volume is available - but what about the (potential) passage? :)
                    if ($valMap('passage') and not(matches(lower-case($valMap('passage')), '^vol\d{1,2}$'))) then
                        (: (passages that refer to mere volumes have already been treated above) :)
                        if (doc($config:index-root || '/' || $valMap('work_id') || '_nodeIndex.xml')//sal:citetrail[./text() eq $valMap('passage')]) then
                            let $valMap := map:put($valMap, 'passage_status', 1)
                            return map:put($valMap, 'valid', true())
                        else $valMap
                    else map:put($valMap, 'valid', true())        
                else $valMap
        else 
            (: syntactically invalid request - no further validation necessary :)
            $valMap
    
(:    let $debug := util:log('warn', '[TEXTSAPI] validation results: ' || serialize($valMap, <output:serialization-parameters><output:method>json</output:method></output:serialization-parameters>)):)
    
    return $valMap
};

