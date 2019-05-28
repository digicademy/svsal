xquery version "3.0";

module namespace rdf            = "http://salamanca/rdf";
declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";
declare namespace templates        = "http://exist-db.org/xquery/templates";
import module namespace functx     = "http://www.functx.com";
import module namespace app        = "http://salamanca/app"     at "app.xql";
import module namespace config     = "http://salamanca/config"  at "config.xqm";
import module namespace render     = "http://salamanca/render"  at "render.xql";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace http       = "http://expath.org/ns/http-client";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";
import module namespace i18n       = "http://exist-db.org/xquery/i18n";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace xmldb      = "http://exist-db.org/xquery/xmldb";


declare function rdf:needsRDF($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    let $subcollection := 
        if (starts-with(upper-case($targetWorkId), 'W')) then $config:rdf-works-root
        else if (starts-with(upper-case($targetWorkId), 'A')) then $config:rdf-authors-root
        else if (starts-with(upper-case($targetWorkId), 'L')) then $config:rdf-lemmata-root
        else ()
    return    
        if (doc-available($subcollection || '/' || $targetWorkId || '.rdf')) then
            let $rdfModTime := xmldb:last-modified($subcollection, $targetWorkId || '.rdf')
            return 
                if ($rdfModTime lt $targetWorkModTime) then true() else false()
                else true()
};

declare function rdf:needsRDFString($node as node(), $model as map(*)) {
    let $currentWorkId := max((string($model('currentWork')?('wid')), string($model('currentAuthor')/@xml:id), string($model('currentLemma')/@xml:id), string($model('currentWp')/@xml:id)))
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $currentWorkId, '.xml'))) then $subcollection
            else ()
    let $rdfSubcollection := 
        if (starts-with(upper-case($currentWorkId), 'W')) then $config:rdf-works-root
        else if (starts-with(upper-case($currentWorkId), 'A')) then $config:rdf-authors-root
        else if (starts-with(upper-case($currentWorkId), 'L')) then $config:rdf-lemmata-root
        else ()
    return 
        if (rdf:needsRDF($currentWorkId)) then
            <td title="{concat(if (doc-available($rdfSubcollection || '/' || $currentWorkId || '.rdf')) then concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentWorkId || '.rdf')), ', ') else (), 'Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}"><a href="rdf-admin.xql?resourceId={$currentWorkId}"><b>Create RDF NOW!</b></a></td>
        else
            <td title="{concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentWorkId || '.rdf')), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}">Creating RDF unnecessary. <small><a href="rdf-admin.xql?resourceId={$currentWorkId}">Create RDF anyway!</a></small></td>
};
