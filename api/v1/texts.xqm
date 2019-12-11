xquery version "3.0" encoding "UTF-8";

(: ####++++----

    "Texts" API module

 ----++++#### :)

module namespace textsv1 = "http://api.salamanca.school/v1/texts";

declare namespace sal = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace util = "http://exist-db.org/xquery/util";

import module namespace srest = "http://www.salamanca.school/xquery/srest" at "../srest.xqm";
import module namespace sutil = "http://www.salamanca.school/xquery/sutil" at "../../modules/sutil.xql";
import module namespace config = "http://www.salamanca.school/xquery/config" at "../../modules/config.xqm";



(: RESTXQ API FUNCTIONS :)


(: Complete corpus :)

declare
%rest:GET
%rest:path("/v1/texts")
%rest:query-param("format", "{$format}", "html")
function textsv1:getCorpus($format) {

  <result>
    <content>Hello Corpus</content>
  </result>
         
};


(: Doc, based on "format" query param :)

declare 
%rest:GET
%rest:path("/v1/texts/{$rid}")
%rest:query-param("format", "{$format}", "html")
%rest:query-param("mode", "{$mode}", "")
%rest:query-param("q", "{$q}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:query-param("viewer", "{$viewer}", "")
%rest:query-param("frag", "{$frag}", "")
%rest:query-param("canvas", "{$canvas}", "")
%output:indent("no")
function textsv1:docRequest($rid, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    (: this method accepts all possible query params in principle, but only the suitable ones are passed 
    to the respective format function - the other ones are simply ignored :)
    switch($format)
        case 'tei' return textsv1:TEIdeliverDoc($rid, $mode)
        default return ()
};


(: Doc, based on "Accept" header (each mimetype has its own restxq function) :)

declare 
%rest:GET
%rest:path("/v1/texts/{$rid}")
%rest:query-param("mode", "{$mode}", "")
%rest:produces("application/tei+xml")
%rest:produces("application/xml")
%rest:produces("text/xml")
%output:indent("no")
function textsv1:TEIdocRequestThroughAcceptHeader($rid, $mode) {
    textsv1:TEIdeliverDoc($rid, $mode)
};


(: TODO: txt and html: legacy_mode :)


(: CONTENT DELIVERY FUNCTIONS, based on format type :)

(: Returns the TEI doc/fragment for a *valid* resource (see textsv1:validateResourceId()) :)
declare %private function textsv1:TEIdeliverDoc($rid as xs:string, $mode as xs:string?) {
    let $resource := textsv1:validateResourceId($rid)
    let $mode := if ($mode) then $mode else if ($resource('legacy_mode')) then $resource('legacy_mode') else ()
    return 
        if ($resource('tei_status') eq 2 and $resource('valid') and not($mode eq 'meta')) then 
            (: full, valid doc/fragment requested :)
            let $serialize := util:declare-option("output:indent", "no")
            return
            srest:deliverTEI(
                util:expand(doc($config:tei-works-root || '/' || $resource('tei_doc') || '.xml')/tei:TEI, 'indent="no"'),
                $resource('rid')
            )
        else if ($resource('tei_status') ge 1 and $mode eq 'meta') then
            (: teiHeader of an available dataset requested :)
            (: TODO tei_header :)
            <result>TEI resource not yet fully available, but delivering teiHeader: {$rid}</result>
        else if ($resource('tei_status') = (1, 0)) then
            srest:error404NotYetAvailable()
        else if (not($resource('wellformed'))) then
            srest:error400BadResource()
        else 
            srest:error404NotFound()
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
        'valid': false(), (: states if resource is valid/available :)
        'work_id': (), (: the id of the work (5-place, without any volume suffix) :)
        'rid_main': (), (: the "main" part of the resource id, before any colon or dot (if there are any). Case is normalized :)
        'tei_doc': (), (: the id of the TEI dataset for the work/volume, as found in $config:tei-works-root (without ".xml") :)
        'tei_status': -1, (: status of the work: see sutil:WRKvalidateId() :)
        'passage': (), (: the id of the passage :)
        'passage_status': 0, (: the status of the passage: 1 if passage is available, 0 if not :)
        'wellformed': false(), (: states if resource id is syntactically well-formed :)
        'legacy_mode': (), (: legacy resource ids may contain a mode parameter such as "W0004.orig", which may be relevant for HTML/TXT delivery :)
        'rid': $rid (: the originally requested resource id :)
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
            let $passageIsFullVolume := matches(lower-case($valMap('passage')), '^vol\d{1,2}$')
            let $teiId := 
                if ($passageIsFullVolume) then
                    format-number(xs:integer(replace($valMap('passage'), '^vol(\d{1,2})$', '$1')), '00')
                else $valMap('rid_main')
            let $valMap := map:put($valMap, 'tei_doc', $teiId)
            (:
            (\: if passage refers to full volume, remove the passage - the info is already stored in $valMap('tei_doc') :\)
            let $valMap := if ($passageIsFullVolume) then map:put($valMap, 'passage', ()) else $valMap
            :)
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
    
    let $debug := util:log('warn', '[TEXTSAPI] validation results: ' || serialize($valMap, $srest:jsonOutputParams))
    
    return $valMap
};


