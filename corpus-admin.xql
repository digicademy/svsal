xquery version "3.1";

import module   namespace   config  = "http://salamanca/config" at "modules/config.xqm";
import module   namespace   console = "http://exist-db.org/xquery/console";
import module   namespace   admin   = "http://salamanca/admin"  at "modules/admin.xql";
declare         namespace   output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request = "http://exist-db.org/xquery/request";
declare          namespace response = "http://exist-db.org/xquery/response";
declare namespace tei               = "http://www.tei-c.org/ns/1.0";

(: This corpus administration module can be used, in a more elaborated form, for any corpus-scale file creation tasks 
(e.g., TEI corpus zip, IIIF collection resource, etc.) :)

let $debug              := if ($config:debug = ("trace", "info")) then console:log("Creating corpus zip.") else ()

let $serializationOpts := 'method=xml media-type=application/tei+xml omit-xml-declaration=no indent=yes expand-xincludes=yes'
let $works := for $reqWork in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5]/string()
                return if (doc-available($config:tei-works-root || '/' || $reqWork || '.xml')) then
                       let $debug := console:log("Expanding " || $reqWork || " (" || substring(serialize(doc($config:tei-works-root || '/' || $reqWork || '.xml')), 1, 300) || " ...).")
                       let $expanded := util:expand(doc($config:tei-works-root || '/' || $reqWork || '.xml')/tei:TEI, $serializationOpts)
                       let $debug := console:log("Expanded. Result: " || substring(serialize($expanded), 1, 300) || " ...")
                       return $expanded
                        else ()
let $debug := console:log("Number of works: " || count($works) || ", number of works/tei:TEI: " || count($works/tei:TEI) || ".")
let $tmpCollection := $config:data-root || '/sal-tei-corpus'
let $removeStatus := if (xmldb:collection-available($tmpCollection)) then xmldb:remove($tmpCollection) else ()

let $zipTmp := xmldb:create-collection($config:data-root, 'sal-tei-corpus')
let $storeStatus := for $work in $works return xmldb:store($tmpCollection, $work/@xml:id || '.xml', $work)
let $zip := compression:zip(xs:anyURI($tmpCollection), false())

let $remove-status2 := if (xmldb:collection-available($tmpCollection)) then xmldb:remove($tmpCollection) else ()


let $debug              := if ($config:debug = ("trace", "info")) then console:log("Creating corpus zip.") else ()

let $filepath := $config:data-root || '/sal-tei-corpus.zip'
let $removeStatus3            := if (file:exists($filepath)) then
                                      xmldb:remove($filepath)
                                 else ()

let $save := xmldb:store-as-binary($config:data-root, 'sal-tei-corpus.zip', $zip)

return 
if ($save) then <output><status>Saved corpus zip file at {$filepath}.</status></output>
else <output><status>Corpus zip file could not be stored!</status></output>


