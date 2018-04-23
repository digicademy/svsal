xquery version "3.1";

module namespace iiif     = "http://salamanca/iiif";
declare namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace xi      = "http://www.w3.org/2001/XInclude";

import module namespace config    = "http://salamanca/config"               at "config.xqm";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace functx     = "http://www.functx.com";
import module namespace i18n       = "http://exist-db.org/xquery/i18n"       at "i18n.xql";
import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace xmldb      = "http://exist-db.org/xquery/xmldb";

declare option output:method "json";
declare option output:media-type "application/json";

(: relative server domain! :)
declare variable $iiif:serverDomain := $config:serverdomain;
declare variable $iiif:proto := "http";

declare variable $iiif:facsServer := $iiif:proto || "://facs." || $iiif:serverDomain;
declare variable $iiif:imageServer := $iiif:facsServer || "/iiif/image/";
declare variable $iiif:presentationServer := $iiif:facsServer || "/iiif/presentation/";

declare function iiif:needsResource($targetWorkId as xs:string) as xs:boolean {
    let $targetWorkModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')

    return if (util:binary-doc-available($config:iiif-root || '/' || $targetWorkId || '.json')) then
                let $resourceModTime := xmldb:last-modified($config:iiif-root, $targetWorkId || '.json')
                return if ($resourceModTime lt $targetWorkModTime) then true() else false()
        else
            true()
};

declare function iiif:needsResourceString($node as node(), $model as map(*)) {
    let $currentWorkId := (string($model('currentWork')/@xml:id))
    return if (iiif:needsResource($currentWorkId)) then
                <td title="source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="iiif-admin.xql?resourceId={$currentWorkId}"><b>Create IIIF resource NOW!</b></a></td>
            else
                <td title="{concat('IIIF resource created on: ', string(xmldb:last-modified($config:iiif-root, $currentWorkId || '.json')), ', Source from: ', string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml')), '.')}">Creating IIIF resource unnecessary. <small><a href="iiif-admin.xql?resourceId={$currentWorkId}">Create IIIF resource anyway!</a></small></td>
    
};

declare function iiif:getIiifResource($targetWorkId as xs:string) as map(*) {
    let $tei  := doc($config:tei-works-root || '/' || $targetWorkId || '.xml')//tei:TEI
    let $iiifResource :=
        if ($tei) then
        (: dataset exists: :)
            if ($tei/tei:text[@type='work_multivolume']) then
                (: work has several volumes :)
                iiif:mkMultiVolumeCollection($targetWorkId, $tei)
            else if ($tei/tei:text[@type='work_monograph' or @type='work_volume']) then
                (: single volume :)
                iiif:mkSingleVolumeManifest($targetWorkId, $tei, ())
            else ()
        else ()
        (: no TEI dataset available -> do nothing :)
    return $iiifResource
};

declare function iiif:mkMultiVolumeCollection($workId as xs:string, $tei as node()) as map(*) {
    let $debug := if ($config:debug = "trace") then console:log("iiif:mkMultiVolumeCollection running (" || $workId || " requested) ...") else ()
    let $id := $iiif:presentationServer || "collection/" || $workId
    let $label := normalize-space($tei//tei:titleStmt/tei:author) || ": " ||
        normalize-space($tei//tei:titleStmt/tei:title[@type="main"]/text()) || " [multi-volume collection]"
    let $viewingHint := "multi-part"
    let $description := "Coming soon..." (: TODO, depends on available description in TEI metadata :)
    let $license         := "" (: TODO: which license for image data? https://creativecommons.org/licenses/by/4.0/ :)
    let $attribution     := "Presented by the project 'The School of Salamanca. A Digital Collection of Sources and a Dictionary of its Juridical-Political Language.' (http://salamanca.adwmainz.de)"

    (: get manifests for each volume :)
    let $volumeFileNames := for $fileName in $tei/tei:text/tei:group/xi:include/@href return $fileName
    let $debug := if ($config:debug = "trace") then console:log("Get manifests for " || string-join($volumeFileNames, ', ') || "...") else ()

    let $volumeNodes := for $fileName in $volumeFileNames return doc($config:tei-works-root || '/' || $fileName)//tei:TEI
    let $debug := if ($config:debug = "trace") then console:log("(These correspond to the following Work-Ids: " || string-join($volumeNodes/@xml:id/string(), ', ') || ").") else ()

    let $volumeManifests := for $teiNode in $volumeNodes return iiif:mkSingleVolumeManifest($teiNode/@xml:id, $teiNode, $id)
    let $manifests := array {for $manifest in $volumeManifests return $manifest}

    (: Bibliographical metadata section :)
    (: TODO: alternate title? :)
    let $monogr := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr
    let $pubPlace := if ($monogr/tei:imprint/tei:pubPlace[@role='thisEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='thisEd']/@key)
                     else if ($monogr/tei:imprint/tei:pubPlace[@role='firstEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='firstEd']/@key)
                     else ()
    let $publishers := if ($monogr/tei:imprint/tei:publisher[@n='thisEd'])
                       then array { for $publisher in $monogr/tei:imprint/tei:publisher[@n='thisEd']//tei:persName
                                   return map {"label": "Publisher", "value": normalize-space($publisher[text()]) } }
                       else if ($monogr/tei:imprint/tei:publisher[@n='firstEd'])
                       then array { for $publisher in $monogr/tei:imprint/tei:publisher[@n='firstEd']//tei:persName
                                   return map {"label": "Publisher", "value": normalize-space($publisher[text()]) } }
                       else ()
    let $pubDate := if ($monogr/tei:imprint/tei:date[@type='thisEd']) then normalize-space($monogr/tei:imprint/tei:date[@type='thisEd'])
                    else if ($monogr/tei:imprint/tei:date[@type='firstEd']) then normalize-space($monogr/tei:imprint/tei:date[@type='firstEd'])
                    else ()
    let $lang := string($tei/tei:text/@xml:lang)

    let $metadata := array {
        map {"label": "Title", "value": normalize-space($tei//tei:titleStmt/tei:title[@type="main"]/text())},
        map {"label": "Author", "value": normalize-space($tei//tei:titleStmt/tei:author)},
        map {"label": "Date Added", "value": ""},
        map {"label": "Language", "value": $lang},
        map {"label": "Publish Place", "value": $pubPlace},
        map {"label": "Publish Date", "value": $pubDate},
        map {"label": "Publishers", "value": $publishers},
        map {"label": "Full Title", "value": normalize-space($tei//tei:sourceDesc/tei:biblStruct//tei:monogr/tei:title[@type='main'])},
        map {"label": "Topic", "value": ""},
        map {"label": "About", "value": ""}
    }

	
    (: the "manifests" property (below) is likely to be deprecated in v3.0 and should probably be changed to "members" then :)
    let $collection-out := map {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": $id,
        "@type": "sc:Collection",
        "label": $label,
        "metadata": $metadata,
        "viewingHint": $viewingHint,
        "description": $description,
        "attribution": $attribution,
        "license": $license,
        "members": $manifests
    }
(: rendering? seeAlso? thumbnail? :)
    return $collection-out
};

(: includes single-volume works as well as single volumes as part of multi-volume works:)
(: volumeId: xml:id of TEI node of single TEI file, e.g. "W0004" or "W0013_Vol01" :)
declare function iiif:mkSingleVolumeManifest($volumeId as xs:string, $tei as node(), $collectionId as xs:string?) {
    let $debug := if ($config:debug = "trace") then console:log("iiif:mkSingleVolumeManifest running (" || $volumeId || " requested) ...") else ()
    (: File metadata section :)
    let $id := $iiif:presentationServer || $volumeId || "/manifest"
    let $label := normalize-space($tei/tei:teiHeader//tei:titleStmt/tei:title[@type="main"]/text())

    (: Bibliographical metadata section :)
    (: TODO: alternate title? :)
    let $monogr := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr
    let $pubPlace := if ($monogr/tei:imprint/tei:pubPlace[@role='thisEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='thisEd']/@key)
                     else if ($monogr/tei:imprint/tei:pubPlace[@role='firstEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='firstEd']/@key)
                     else ()
    let $publishers := if ($monogr/tei:imprint/tei:publisher[@n='thisEd'])
                       then array { for $publisher in $monogr/tei:imprint/tei:publisher[@n='thisEd']//tei:persName
                                   return map {"label": "Publisher", "value": normalize-space($publisher[text()]) } }
                       else if ($monogr/tei:imprint/tei:publisher[@n='firstEd'])
                       then array { for $publisher in $monogr/tei:imprint/tei:publisher[@n='firstEd']//tei:persName
                                   return map {"label": "Publisher", "value": normalize-space($publisher[text()]) } }
                       else ()
    let $pubDate := if ($monogr/tei:imprint/tei:date[@type='thisEd']) then string($monogr/tei:imprint/tei:date[@type='thisEd']/@when)
                    else if ($monogr/tei:imprint/tei:date[@type='firstEd']) then string($monogr/tei:imprint/tei:date[@type='firstEd']/@when)
                    else ()
    let $lang := string($tei/tei:text/@xml:lang)

    let $metadata := array {
        map {"label": "Title", "value": normalize-space($tei//tei:titleStmt/tei:title[@type="main"]/text())},
        map {"label": "Author", "value": normalize-space($tei//tei:titleStmt/tei:author)},
        map {"label": "Date Added", "value": ""},
        map {"label": "Language", "value": $lang},
        map {"label": "Publish Place", "value": $pubPlace},
        map {"label": "Publish Date", "value": $pubDate},
        map {"label": "Publishers", "value": $publishers},
        map {"label": "Full Title", "value": normalize-space($tei//tei:sourceDesc/tei:biblStruct//tei:monogr/tei:title[@type='main'])},
        map {"label": "Topic", "value": ""},
        map {"label": "About", "value": ""}
    }

    let $description := "Coming soon..." (: TODO, depends on available description in TEI metadata :)
    (: the thumbnail works only if we have a titlePage with a pb in or before it: :)
    let $thumbnailId := iiif:getThumbnailUrl($tei)
    let $thumbnailServiceId := "" (:TODO :)
    let $thumbnail := map {
        "@id": concat($config:digilibServerScaler, $thumbnailId, "/full/full/0/default.jpg"),
        "service": map {
            "@context": "http://iiif.io/api/image/2/context.json",
            "@id": $thumbnailServiceId,
            "profile": "http://iiif.io/api/image/2/level1.json"
        }
    }

    (: Sequences, including all the canvases and images for the volume :)
    let $sequences := array { iiif:mkSequence($volumeId, $tei, $thumbnailId) } (: currently, there is but one sequence (the default sequence/order of pages for the volume) :)

    (: Presentation information :)
    let $viewingDirection := "left-to-right"
    let $viewingHint := "paged" (: can/should we make Mirador present the two canvases of a page stitched together (recto/verso)? otherwise: "continuous" :)

    (: Rights information :)
    let $license         := "" (: TODO: which license for image data? https://creativecommons.org/licenses/by/4.0/ :)
    let $attribution     := "Presented by the project 'The School of Salamanca. A Digital Collection of Sources and a Dictionary of its Juridical-Political Language.' (http://salamanca.adwmainz.de)"

    (: Links to other data/formats :)
    let $seeAlso := array {
        map {"@id": concat("http://tei.", $iiif:serverDomain, "/", substring($volumeId, 1, 5), ".xml"),
            "format": "text/xml"},
        map {"@id": concat("http://data.", $iiif:serverDomain, "/", substring($volumeId, 1, 5), ".rdf"),
            "format": "application/rdf+xml"}
    }
    let $renderingId := if (contains($volumeId, "_")) then concat("http://id.", $iiif:serverDomain, "/works.", substring-before($volumeId, "_"), ":", substring-after($volumeId, "_"))
                        else concat("http://id.", $iiif:serverDomain, "/works.", $volumeId) (: better: provide native .html URL? :)
    let $rendering := map {
        "@id": $renderingId,
        "label": "HTML view",
        "format": "text/html"
    }

    let $manifest-out := map {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": $id,
        "@type": "sc:Manifest",
        "label": $label,
        "metadata": $metadata,
        "description": $description,
        "thumbnail": $thumbnail,
        "viewingDirection": $viewingDirection,
        "viewingHint": $viewingHint,
        "license": $license,
        "attribution": $attribution,
        "seeAlso": $seeAlso,
        "rendering": $rendering,
        "sequences": $sequences
    }
    let $manifest-out2 := if ($collectionId) then map:put($manifest-out, "within", $collectionId) else $manifest-out
    return $manifest-out2
    (: do we need a (SvSal-)logo on the manifest level, to be shown in Mirador for example? :)

};

declare function iiif:mkSequence($volumeId as xs:string, $tei as node(), $thumbnail as xs:string) {
    let $debug := if ($config:debug = "trace") then console:log("iiif:mkSequence running...") else ()

    let $id := $iiif:presentationServer || $volumeId || "/sequence/normal"

(:  here is currently a problem, apparently in both conditions:  :)
    let $canvases :=
        if (count($tei/tei:text/tei:body//tei:pb) > 15) then
            (: we have a full text :)
            let $canvases-seq := for $facs at $n in $tei/tei:text//tei:pb/@facs return iiif:mkCanvasFromTeiFacs($volumeId, $facs, $n)
            let $canvases-out := array {for $canvas in $canvases-seq return $canvas}
            return $canvases-out
        else
            (: no full text available: get canvases from automatically generated digilib manifest and transform them: :)
            let $digilib-mf-uri  := $config:digilibServerManifester || iiif:getIiifVolumeId($volumeId)
            let $options         := map { "liberal": true(), "duplicates": "use-last" }
            let $digilib-manifest     := json-doc($digilib-mf-uri, $options)
            let $digilib-sequence1 := array:get(map:get($digilib-manifest, "sequences"), 1) (: assumes that there is only one – the default – sequence in the digilib manifest :)
            let $digilib-canvases := map:get($digilib-sequence1, "canvases")
            let $digilib-canvases-seq := for $i in (1 to array:size($digilib-canvases)) return array:get($digilib-canvases, $i)
            let $startPageNo := 1
            let $canvases-seq := for $canvas at $n in $digilib-canvases-seq return iiif:transformDigilibCanvas($volumeId, $canvas, $n)

            let $canvases-out := array {for $canvas in $canvases-seq return $canvas}
            return $canvases-out

    let $startPageNo := if ($tei/tei:text//tei:titlepage/following::tei:pb) then
                            $tei/tei:text//tei:titlepage/following::tei:pb/count(preceding::tei:pb) + 1
                        else
                            1
    let $startCanvas := $canvases($startPageNo)("id")    (: TODO: currently contains no valid canvas URL, should return the canvas URL of the thumbnail image :)

    let $sequences-out := map {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": $id,
        "@type": "sc:Sequence",
        "label": "Current Page Order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "startCanvas": $startCanvas,
        "canvases": $canvases
    }
    return $sequences-out
};

declare function iiif:mkCanvasFromTeiFacs($volumeId as xs:string, $facs as xs:string, $index as xs:integer) {

    let $id := $iiif:presentationServer || $volumeId || "/canvas/p" || string($index)
    let $label := "p. " || string($index)

    (: TODO: currently points to digilib server with native URL, should eventually be formulated as facs... URL :)
    let $digilibImageId := $config:digilibServerScaler || iiif:teiFacs2IiifImageId($facs)
    (: get image height and width from the digilib server (i.e. from each image json file): :)
    let $options := map { "liberal": true(), "duplicates": "use-last" }

    let $digilibImageResource := json-doc($digilibImageId, $options)
    
    let $imageHeight := map:get($digilibImageResource, "height")
    let $imageWidth := map:get($digilibImageResource, "width")

    let $images := array {
        map {
            "@context": "http://iiif.io/api/presentation/2/context.json",
            "@id": concat($iiif:presentationServer, $volumeId, "/annotation/p", string($index), "-image"),
            "@type": "oa:Annotation",
            "motivation": "sc:painting",
            "resource": map {
                "@id": concat($digilibImageId, "/full/full/0/default.jpg"),
                "@type": "dctypes:Image",
                "format": "image/jpeg",
                "service": map {
                    "@context": "http://iiif.io/api/image/2/context.json",
                    "@id": $digilibImageId,
                    "profile": "http://iiif.io/api/image/2/level2.json"
                },
                "height": $imageHeight,
                "width": $imageWidth
            },
            "on": $id
        }
    }

    let $canvas-out := map {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": $id,
        "@type": "sc:Canvas",
        "label": $label,
        "height": $imageHeight,
        "width": $imageWidth,
        "images": $images
    }
    return $canvas-out
};


declare function iiif:transformDigilibCanvas($volumeId as xs:string, $canvas as map(*), $index as xs:integer) {
    let $id := $iiif:presentationServer || $volumeId || "/canvas/p" || string($index)
    let $label := "p. " || string($index)

    let $dl-images := map:get($canvas, "images")
    let $dl-image1 := array:get($dl-images, 1) (: assumes that the "images" element contains only one relevant subelement: the first one  :)
    let $dl-resource := map:get($dl-image1, "resource")

    let $digilibImageId := $config:digilibServerScaler || substring-before(substring-after(map:get($dl-resource, "@id"), "/Scaler/IIIF/svsal!"), "/full/full/0/default.jpg")

    let $imageHeight := map:get($dl-resource, "height")
    let $imageWidth := map:get($dl-resource, "width")

    let $images := array {
        map {
            "@context": "http://iiif.io/api/presentation/2/context.json",
            "@id": concat($iiif:presentationServer, $volumeId, "/annotation/p", string($index), "-image"),
            "@type": "oa:Annotation",
            "motivation": "sc:painting",
            "resource": map {
                "@id": concat($digilibImageId, "/full/full/0/default.jpg"),
                "@type": "dctypes:Image",
                "format": "image/jpeg",
                "service": map {
                    "@context": "http://iiif.io/api/image/2/context.json",
                    "@id": $digilibImageId,
                    "profile": "http://iiif.io/api/image/2/level2.json"
                },
                "height": $imageHeight,
                "width": $imageWidth
            },
            "on": $id
        }
    }

    let $canvas-out := map {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": $id,
        "@type": "sc:Canvas",
        "label": $label,
        "height": $imageHeight,
        "width": $imageWidth,
        "images": $images
    }
    return $canvas-out
};

declare function iiif:getThumbnailUrl($tei as node()) as xs:string {
    let $thumbnailFacs := if ($tei/tei:text/tei:front//tei:titlePage[1]//tei:pb[1]) then $tei/tei:text/tei:front/tei:titlePage//tei:pb[1]/@facs
                          else $tei/tei:text/tei:front//tei:titlePage[1]/preceding-sibling::tei:pb[1]/@facs
    return iiif:teiFacs2IiifImageId($thumbnailFacs)
};

(: converts a tei:pb/@facs value (given that it has the form "facs:Wxxxx(-x)-xxxx") into an image id understandable by the Digilib server,
    such as "W0013!A!W0013-A-0009". Changes in the Digilib settings, for instance with the delimiters, might make changes in this function necessary :)
declare function iiif:teiFacs2IiifImageId($facs as xs:string?) as xs:string {
    let $facsWork := substring-before(substring-after($facs, "facs:"), "-")
    let $facsVol := if (contains(substring-after($facs, "-"), "-")) then substring-before(substring-after($facs, "-"),"-") else ()
    let $facsImgId := substring($facs, string-length($facs) - 3, 4)
    let $iiifImageId := if ($facsVol)
        then concat($facsWork, "!", $facsVol, "!", $facsWork, "-", $facsVol, "-", $facsImgId)
        else concat($facsWork, "!", $facsWork, "-", $facsImgId)
    return $iiifImageId
};

(: Returns the appropriate image id of a volume, based on its xml:id (as given in the TEI node) and the volume number therein (if any).
    If a work has been separated into several files with identifiers ending on underscore + lowercased letter, then this id will be returned. :)
declare function iiif:getIiifVolumeId($volumeId as xs:string) as xs:string {
    let $volumeMap := map {
        "Vol01": "A",
        "Vol02": "B",
        "Vol03": "C",
        "Vol04": "D",
        "Vol05": "E",
        "Vol06": "F",
        "Vol07": "G",
        "Vol08": "H",
        "Vol09": "I",
        "Vol10": "J"
    }
    let $iiifVolumeId :=
        if (matches($volumeId, "^W[0-9]{4}$")) then $volumeId
        else if (matches($volumeId, "^W[0-9]{4}_Vol[0-9]{2}$")) then concat(substring-before($volumeId, "_"), "!", map:get($volumeMap, substring-after($volumeId, "_")))
        else if (matches ($volumeId, "^W[0-9]{4}_[a-z]+$")) then substring-before($volumeId, "_")
        else ()
    return $iiifVolumeId
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
    let $tei  := doc($config:tei-works-root || '/' || $wid || '.xml')//tei:TEI
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
    let $debug :=  if ($config:debug = "trace") then console:log(serialize($miradorData, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>))  else ()

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
    let $tei       := doc($config:tei-works-root || '/' || $wid || '.xml')//tei:TEI
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

declare function iiif:getPageId($canvasId as xs:string*) {
    let $HTMLcollection := collection($config:html-root )
    let $results := map:new(
                            for $id in $canvasId
                                let $htmlAnchor := $HTMLcollection//a[@data-canvas = $id]
                                let $pageId     := $htmlAnchor/@data-sal-id/string()
                                return map:entry( $id , $pageId)
                            )
    return $results
};


(: TODO:
    - create top collection for SvSal
    - create ranges (deprecation warning...)?;
    - startCanvas in Sequence
    - check validity and consistency of @id on every level
    - dealing with TEI data which has been separated into Wxxx_a, Wxxx_b etc due to performance issues
 :)
(:        serialize($iiifResource,
            <output:serialization-parameters>
                <output:method>json</output:method>
            </output:serialization-parameters>)
:)

