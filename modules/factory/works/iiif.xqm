xquery version "3.1";

(: ####++++----

    Functions for creating iiif manifests/collections for works, based on TEI data and data requested from 
    the digilib iiif server.

 ----++++#### :)

module namespace iiif     = "https://www.salamanca.school/factory/works/iiif";
declare namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace xi      = "http://www.w3.org/2001/XInclude";

import module namespace config    = "http://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace app = "http://www.salamanca.school/xquery/app" at "xmldb:exist:///db/apps/salamanca/modules/app.xqm";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace sutil    = "http://www.salamanca.school/xquery/sutil" at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";



(: Creates a new iiif resource, either a manifest (for a single-volume work or 
a single volume within a multi-volume work) or a collection resource (for a multi-volume work).
@param $wid: the ID of the work or volume which the manifest is requested for
@return:     the iiif manifest/collection :)
declare function iiif:createResource($targetWorkId as xs:string) as map(*) {
    let $tei  := doc($config:tei-works-root || '/' || sutil:normalizeId($targetWorkId) || '.xml')//tei:TEI
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
    let $id := $config:iiifPresentationServer || "collection/" || $workId
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
    let $metadata := iiif:mkMetadata($tei)

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
    return $collection-out
};

(: includes single-volume works as well as single volumes as part of multi-volume works:)
(: volumeId: xml:id of TEI node of single TEI file, e.g. "W0004" or "W0013_Vol01" :)
declare function iiif:mkSingleVolumeManifest($volumeId as xs:string, $teiDoc as node(), $collectionId as xs:string?) {
    let $debug := if ($config:debug = "trace") then console:log("iiif:mkSingleVolumeManifest running (" || $volumeId || " requested) ...") else ()
    let $tei := util:expand($teiDoc)
    (: File metadata section :)
    let $id := $config:iiifPresentationServer || $volumeId || "/manifest"
    let $label := normalize-space($tei/tei:teiHeader//tei:titleStmt/tei:title[@type="main"]/text())

    (: Bibliographical metadata section :)
    let $metadata := iiif:mkMetadata($tei)

    let $description := "Coming soon..." (: TODO, depends on available description in TEI metadata :)
    (: the thumbnail works only if we have a titlePage with a pb in or before it: :)
    let $thumbnailId := iiif:getThumbnailId($tei)
    let $thumbnailServiceId := concat($config:iiifImageServer, $thumbnailId)
    let $thumbnail := map {
        "@id": concat($config:iiifImageServer, $thumbnailId, "/full/full/0/default.jpg"),
        "service": map {
            "@context": "http://iiif.io/api/image/2/context.json",
            "@id": $thumbnailServiceId,
            "profile": "http://iiif.io/api/image/2/level1.json"
        }
    }

    (: Sequences, including all the canvases and images for the volume :)
    (: currently, there is but one sequence (the default sequence/order of pages for the volume) :)
    let $sequences := array { iiif:mkSequence($volumeId, $tei, concat($config:iiifImageServer, $thumbnailId, "/full/full/0/default.jpg")) } 

    (: Presentation information :)
    let $viewingDirection := "left-to-right"
    let $viewingHint := "paged" (: can/should we make Mirador present the two canvases of a page stitched together (recto/verso)? otherwise: "continuous" :)

    (: Rights information :)
    let $license         := "" (: TODO: which license for image data? https://creativecommons.org/licenses/by/4.0/ :)
    let $attribution     := "Presented by the project 'The School of Salamanca. A Digital Collection of Sources and a Dictionary of its Juridical-Political Language.' (http://salamanca.adwmainz.de)"

    (: Links to other data/formats :)
    let $seeAlso := array {
        map {"@id": concat($config:apiserverTexts, '/', substring($volumeId, 1, 5), "?format=tei"),
            "format": "text/xml"},
        map {"@id": concat($config:apiserverTexts, '/', substring($volumeId, 1, 5), "?format=rdf"),
            "format": "application/rdf+xml"}
    }
    let $renderingId := if (contains($volumeId, "_")) then concat("http://id.", $config:serverdomain, "/texts/", substring-before($volumeId, "_"), ":", substring-after($volumeId, "_"))
                        else concat("http://id.", $config:serverdomain, "/texts/", $volumeId) (: better: provide native .html URL? :)
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

(: Creates a sequence of canvases. 
    @param $volumeId The ID of the volume to be processed. 
    @tei The TEI node of the volume.
    @thumbnailUrl The complete URL of the thumbnail, as also stated in the "thumbnail" field's "@id" attribute :)
declare function iiif:mkSequence($volumeId as xs:string, $tei as node(), $thumbnailUrl as xs:string) {
    let $debug := if ($config:debug = "trace") then console:log("iiif:mkSequence running...") else ()

    let $id := $config:iiifPresentationServer || $volumeId || "/sequence/normal"

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
    (: The startCanvas is identifiable by its containing (within "resource"/"@id") 
        the URL of the title page (=thumbnail). The following assumes that this URL can be found somewhere 
        within the first 30 canvases:)
    let $getStartCanvas := 
        for $i in (1 to 15)  (: assuming that no work has less than 15 images AND that the thumbnail occurs within the first 15 images :)
            let $canvasImage := map:get($canvases($i), "images")(1)
            let $imageResourceId := map:get(map:get($canvasImage, "resource"), "@id")
            let $return := if ($imageResourceId eq $thumbnailUrl) 
                            then  map:get($canvases($i), "@id") else ()
            return $return
    let $startCanvas := if (count($getStartCanvas) eq 1) then $getStartCanvas else $startPageNo

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

    let $id := $config:iiifPresentationServer || $volumeId || "/canvas/p" || string($index)
    let $label := "p. " || string($index)

    let $digilibImageId := $config:iiifImageServer || iiif:teiFacs2IiifImageId($facs)
    (: get image height and width from the digilib server (i.e. from each image json file): :)
    let $options := map { "liberal": true(), "duplicates": "use-last" }
    
    let $debug := if ($config:debug = ('trace', 'info')) then console:log('Getting image resource from digilib server: ' || $digilibImageId) else ()
    let $digilibImageResource := json-doc($digilibImageId, $options)
    
    let $imageHeight := map:get($digilibImageResource, "height")
    let $imageWidth := map:get($digilibImageResource, "width")

    let $images := array {
        map {
            "@context": "http://iiif.io/api/presentation/2/context.json",
            "@id": concat($config:iiifPresentationServer, $volumeId, "/annotation/p", string($index), "-image"),
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

(: Transforms the canvas shipped from an external digilib server into a "Salamanca" canvas 
by adding some info (such as Salamanca URLs) 
@param $volumeId The volume's ID.
@param $canvas The external canvas to be processed.
@param $index A counter supplied to the function when it is iteratively called, to be used for the pagination of canvases.
:)
declare function iiif:transformDigilibCanvas($volumeId as xs:string, $canvas as map(*), $index as xs:integer) {
    let $id := $config:iiifPresentationServer || $volumeId || "/canvas/p" || string($index)
    let $label := "p. " || string($index)

    let $dl-images := map:get($canvas, "images")
    let $dl-image1 := array:get($dl-images, 1) (: assumes that the "images" element contains only one relevant subelement: the first one  :)
    let $dl-resource := map:get($dl-image1, "resource")

    let $digilibImageId := $config:iiifImageServer || substring-before(substring-after(map:get($dl-resource, "@id"), "/Scaler/IIIF/svsal!"), "/full/full/0/default.jpg")

    let $imageHeight := map:get($dl-resource, "height")
    let $imageWidth := map:get($dl-resource, "width")

    let $images := array {
        map {
            "@context": "http://iiif.io/api/presentation/2/context.json",
            "@id": concat($config:iiifPresentationServer, $volumeId, "/annotation/p", string($index), "-image"),
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

(: Gets the bibliographic metadata of a given TEI document (node).
    @param $tei The TEI document node for a work
    @returns An "metadata" array according to the IIIF presentation specifications
    :)
declare function iiif:mkMetadata($tei as node()) as array(*) {
    let $monogr := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr
    let $pubPlace := if ($monogr/tei:imprint/tei:pubPlace[@role='thisEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='thisEd']/@key)
                     else if ($monogr/tei:imprint/tei:pubPlace[@role='firstEd']) then normalize-space($monogr/tei:imprint/tei:pubPlace[@role='firstEd']/@key)
                     else ()
    let $publishers :=    if ($monogr/tei:imprint/tei:publisher[@n='thisEd']) then app:rotateFormatName($monogr/tei:imprint/tei:publisher[@n='thisEd']/tei:persName)
                                else app:rotateFormatName($monogr/tei:imprint/tei:publisher[@n='firstEd']/tei:persName)        
    let $pubDate := if ($monogr/tei:imprint/tei:date[@type='thisEd']) then string($monogr/tei:imprint/tei:date[@type='thisEd']/@when)
                    else if ($monogr/tei:imprint/tei:date[@type='firstEd']) then string($monogr/tei:imprint/tei:date[@type='firstEd']/@when)
                    else ()
    let $lang := string($tei/tei:text/@xml:lang)

    let $metadata := array {
        map {"label": iiif:getI18nLabels("title"), "value": normalize-space($tei//tei:titleStmt/tei:title[@type="main"]/text())},
        map {"label": iiif:getI18nLabels("author"), "value": normalize-space($tei//tei:titleStmt/tei:author)},
        map {"label": iiif:getI18nLabels("date-added"), "value": ""},
        map {"label": iiif:getI18nLabels("language"), "value": $lang},
        map {"label": iiif:getI18nLabels("publish-place"), "value": $pubPlace},
        map {"label": iiif:getI18nLabels("publish-date"), "value": $pubDate},
        map {"label": iiif:getI18nLabels("publishers"), "value": $publishers},
        map {"label": iiif:getI18nLabels("full-title"), "value": normalize-space($tei//tei:sourceDesc/tei:biblStruct//tei:monogr/tei:title[@type='main'])}
    }
(:   further potential metadata fields:
        map {"label": "Topic", "value": ""},
        map {"label": "About", "value": ""}  :)
    return $metadata
};

declare function iiif:getThumbnailId($tei as node()) as xs:string {
    let $expandedTei := util:expand($tei)
    let $thumbnailFacs := 
        if ($expandedTei/tei:text/tei:front//tei:titlePage[1]//tei:pb[1]) then 
            $expandedTei/tei:text/tei:front//tei:titlePage[1]//tei:pb[1]/@facs
        else $expandedTei/tei:text/tei:front//tei:titlePage[1]/preceding-sibling::tei:pb[1]/@facs
    return iiif:teiFacs2IiifImageId($thumbnailFacs[1])
};

(: Returns for a specific label keyword an array of labels in English, Spanish, and German.
    @param $labelKey The label keyword for which internationalized versions are required
    @return An array of (maps for) labels in English, Spanish, and German :)
declare function iiif:getI18nLabels($labelKey as xs:string?) as array(*) {
    let $labels := map { "title": map {"en": "Title", "de": "Titel", "es": "Título"},
                         "author": map {"en": "Author", "de": "Autor", "es": "Autor"},
                         "date-added": map {"en": "Date Added", "de": "Hinzugefügt", "es": "Agregado"},
                         "language": map {"en": "Language", "de": "Sprache", "es": "Lengua"},
                         "publish-place": map {"en": "Publish Place", "de": "Erscheinungsort", "es": "Lugar de Publicación"},
                         "publish-date": map {"en": "Publish Date", "de": "Erscheinungsjahr", "es": "Año de Publicación"},
                         "publishers": map {"en": "Publishers", "de": "Verleger", "es": "Editores"},
                         "full-title": map {"en": "Full Title", "de": "Gesamter Titel", "es": "Título Completo"},
                         "publisher": map {"en": "Publisher", "de": "Verleger", "es": "Editor"}
                         }
    let $currentLabel := if (map:contains($labels, $labelKey) ) then 
                        array {
                            map { "@value": map:get(map:get($labels, $labelKey), "en"), "@language": "en" },
                            map { "@value": map:get(map:get($labels, $labelKey), "es"), "@language": "es" },
                            map { "@value": map:get(map:get($labels, $labelKey), "de"), "@language": "de" } 
                        }
                        else ()
    return $currentLabel
};

(: converts a tei:pb/@facs value (given that it has the form "facs:Wxxxx(-x)-xxxx") into an image id understandable by the Digilib server,
    such as "W0013!A!W0013-A-0009". Changes in the Digilib settings, for instance with the delimiters, might make changes in this function necessary :)
declare function iiif:teiFacs2IiifImageId($facs as xs:string?) as xs:string {
    let $debug := 
        if (not(matches($facs, 'facs:W\d{4}(-[A-z])?-\d{4}'))) then 
            error(xs:QName('iiif:teiFacs2IiifImageId'), '@facs value "' || $facs || ' could not be parsed as ^facs:W\d{4}(-[A-z])?-\d{4}$') 
        else ()
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
        "Vol01": "A","Vol02": "B","Vol03": "C","Vol04": "D","Vol05": "E","Vol06": "F","Vol07": "G","Vol08": "H","Vol09": "I","Vol10": "J"
    }
    let $iiifVolumeId :=
        if (matches($volumeId, "^W[0-9]{4}$")) then $volumeId
        else if (matches($volumeId, "^W[0-9]{4}_Vol[0-9]{2}$")) then concat(substring-before($volumeId, "_"), "!", map:get($volumeMap, substring-after($volumeId, "_")))
        else if (matches ($volumeId, "^W[0-9]{4}_[a-z]+$")) then substring-before($volumeId, "_")
        else ()
    return $iiifVolumeId
};

