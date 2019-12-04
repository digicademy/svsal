xquery version "3.1";

(: ####++++----

    Functions for accessing iiif data from the database, and iiif-related util functions.
    (Note: *Creation* of iiif is handled in factory/works/iiif.xqm)

 ----++++#### :)

module namespace iiif     = "http://www.salamanca.school/xquery/iiif";
declare namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace xi      = "http://www.w3.org/2001/XInclude";

import module namespace config    = "http://www.salamanca.school/xquery/config"               at "config.xqm";
import module namespace app = "http://www.salamanca.school/xquery/app" at "app.xql";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace functx     = "http://www.functx.com";
import module namespace i18n       = "http://exist-db.org/xquery/i18n"       at "i18n.xql";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace sal-util    = "http://www.salamanca.school/xquery/sal-util" at "sal-util.xql";

declare option output:method "json";
declare option output:media-type "application/json";
 

(: Interface function for fetching a iiif resource, either (if possible) from the database or by creating it on-the-fly.
This resource may be either a manifest (for a single-volume work or a single volume within a multi-volume work) 
or a collection resource (for a multi-volume work).
@param $wid: the ID of the work or volume which the manifest is requested for
@return:     the iiif manifest/collection
:)
declare function iiif:fetchResource($wid as xs:string) as map(*)? {
    let $workId := sal-util:normalizeId($wid)
    let $workType := 
        if (matches($workId, '^W\d{4}(_Vol\d{2})?$')) then 
            doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:text/@type
        else ()
    let $output := 
        (: get multi-volume collection or single-volume manifest :)
        if ($workType = ('work_multivolume', 'work_monograph')) then
            if (util:binary-doc-available($config:iiif-root || '/' || $workId || '.json')) then 
                let $debug := console:log('Fetching iiif manifest for ' || $workId || ' from the DB.')
                return json-doc($config:iiif-root || '/' || $workId || '.json')
            else
                ()
                (: on-the-fly-creation - disabled for performance reasons :)
                (:let $debug := console:log('Creating iiif manifest for ' || $workId || '.')
                return iiif:createResource($workId):) 
        (: get manifest for single volume within a multi-volume work :)
        else if ($workType eq 'work_volume') then
            let $collectionId := substring-before($workId, '_Vol')
            let $volume := 
                (: if the resource for the collection is available in the DB, get the manifest from within the collection :)
                if (util:binary-doc-available($config:iiif-root || '/' || $collectionId || '.json')) then
                    let $debug := console:log('Fetching iiif manifest for ' || $workId || ' from collection for ' || $collectionId || ' from the DB.')
                    let $collection := json-doc($config:iiif-root || '/' || $collectionId || '.json')
                    let $manifest := array:get(array:filter(map:get($collection, 'members'), function($a) {contains(map:get($a, '@id'), $workId)}), 1)
                    return $manifest
                else 
                    ()
                    (: on-the-fly-creation - disabled for performance reasons :)
                    (:
                    let $debug := console:log('Creating iiif manifest for ' || $workId || '.')
                    return iiif:createResource($workId)
                    :)
            return $volume
        else ()
    return $output 
};


declare function iiif:MiradorData($node as node(), $model as map (*), $wid as xs:string?) as xs:string {
(:
Returns a JSON array of objects.
In the case of multi-volume works, return:
              data : [
                        {"collectionUri" : "https://salamanca.school:8443/exist/apps/salamanca/en/iiif-out.xql?wid=" + $wid},
                        {"manifestUri"   : "https://salamanca.school:8443/exist/apps/salamanca/en/iiif-out.xql?wid=W0013_Vol01",
                         "location" :    "MPIeR iiif Service"},
                        {"manifestUri"   : "https://salamanca.school:8443/exist/apps/salamanca/en/iiif-out.xql?wid=W0013_Vol02",
                         "location" :    "MPIeR iiif Service"}
              ]
In the case of single volume works, return:
              data : [
                        {"manifestUri" : "https://salamanca.school:8443/exist/apps/salamanca/en/iiif-out.xql?wid=" + $wid,
                         "location" :    "MPIeR iiif Service"}
              ]
:)
    let $debug :=  if ($config:debug = "trace") then console:log("iiif:MiradorData running...") else ()
    let $tei  := doc($config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml')//tei:TEI
    let $miradorData :=
        if ($tei) then
        (: dataset exists: :)
            if ($tei/tei:text[@type='work_multivolume']) then
                (: work has several volumes :)
                let $debug := console:log("Building Mirador data object for multivolume work:")
                let $collectionURI := "iiif-out.xql?wid=" || $wid
                let $volumeIDs     := for $fileName in $tei/tei:text/tei:group/xi:include/@href return doc($config:tei-works-root || '/' || $fileName)//tei:TEI/@xml:id/string()
                let $manifests     := for $id in $volumeIDs return map { "manifestUri" : concat("iiif-out.xql?wid=", $id), "location" :    "MPIeR iiif Service"}
                let $data-out      := (map {"collectionUri" : $collectionURI }, for $mf in $manifests return $mf)
                return $data-out
            else if ($tei/tei:text[@type='work_monograph' or @type='work_volume']) then
                (: single volume :)
                let $debug := console:log("Building Mirador data object for monograph work.")
                return array { map { "manifestUri" : concat("iiif-out.xql?wid=", $wid), "location" :    "MPIeR iiif Service"} }
            else ()
        else ()
    (:let $debug :=  if ($config:debug = "trace") then console:log(serialize($miradorData, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>))  else ():) (: this doesn't work... :)

     return serialize($miradorData, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)
};

declare function iiif:MiradorWindowObject($node as node(), $model as map (*), $wid as xs:string?) as xs:string {
(: Return a JSON Array like this one:
                [
                    {
                        "loadedManifest" :     "https://salamanca.school:8443/exist/apps/salamanca/en/iiif-out.xql?wid=W0013_Vol01",
                        "canvasID" :           "http://salamanca.school/iiif/presentation/W0013_Vol01/canvas/p1",
                        "viewType" :           "ImageView",
                        "availableViews" :     ["ImageView", "ThumbnailsView"],
                        "displayLayout" :      false,  // change layout of panels (e.g. add panel)
                        "bottomPanelVisible" : false  //  - " - invisible
                    }
                ]
:)

    let $debug     :=  if ($config:debug = "trace") then console:log("iiif:MiradorData running...") else ()
    let $tei       := doc($config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml')//tei:TEI
    let $manifest  :=
        if ($tei) then
        (: dataset exists: :)
            if ($tei/tei:text[@type='work_multivolume']) then
(:                            let $volumeID      := for $fileName in ($tei/tei:text/tei:group/xi:include/@href)[1] return doc($config:tei-works-root || '/' || $fileName)//tei:TEI/@xml:id/string():)
                let $volumeID      := for $fileName in ($tei/tei:text/tei:group/xi:include/@href)[1] return doc($config:tei-works-root || '/' || $fileName)//tei:TEI/@xml:id/string()
                return concat("iiif-out.xql?wid=", $volumeID)
            else if ($tei/tei:text[@type='work_monograph' or @type='work_volume']) then
                concat("iiif-out.xql?wid=", $wid)
            else ()
        else ()
    let $debug :=  if ($config:debug = "trace") then console:log("Manifest: " || $manifest || ".") else ()
(:  TODO: Retrieve Startcanvas, currently we omit it, falling back to the default (1st canvas)
    let $mf := json-doc($config:app-root || '/' || $manifest)
    let $canvasId := $mf("sequences")(1)("canvases")(1)("@id")
    let $debug :=  if ($config:debug = "trace") then console:log("CanvasId: " || $canvasId || ".") else ()
:)
    let $windowObject := array {
        map {
            "loadedManifest": $manifest,
            "viewType" :           "ImageView",
            "availableViews" :     array { "ImageView", "ThumbnailsView" },
            "displayLayout" :      true(),
            "bottomPanelVisible" : false()
             }
     }

    let $debug :=  if ($config:debug = "trace") then console:log(serialize($windowObject, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>))  else ()

     return serialize($windowObject, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)
};

(:
~ Returns the canonical (citetrail) URI of the page break(s) matching one or more canvas ID(s).
:)
declare function iiif:getPageId($canvasId as xs:string*) {
    let $htmlCollection := collection($config:html-root )
    let $results := map:merge(
                            for $id in $canvasId
                                let $htmlAnchor := $htmlCollection//a[@data-canvas = $id]
                                let $pageId     := $htmlAnchor/@data-sal-id/string()
                                return map:entry( $id , $pageId)
                            )
    return $results
};

(:~
Manipulates a iiif full-image URI with regards to the scale of resolution of the image resource. Note: does not check whether 
the URI leads to an actual image.
@param uri: the URI of the image, conforming to the iiif image api
@param scale: a value between 0 and 100 scaling the width and height of the image (in percent)
@return: the manipulated URI
~:)
declare function iiif:scaleImageURI($uri as xs:string?, $scale as xs:integer) as xs:string? {
    if (matches($uri, '/full/.*?/.*?/default.jpg$')) then
        let $before := replace($uri, '^(.*?/full/).*?/.*?/default.jpg$', '$1')
        let $imgScaler := 'pct:' || string($scale)
        let $after := replace($uri, '^.*?/full/.*?(/.*?/default.jpg)$', '$1')
        return $before || $imgScaler || $after
    else ()
};


(: TODO:
    - create top collection comprising all SvSal works?
    (- create ranges (deprecation warning...)?)
    - dealing with TEI data which has been separated into Wxxx_a, Wxxx_b etc due to performance issues?
 :)

