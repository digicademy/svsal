xquery version "3.1";

import module   namespace   config  = "http://salamanca/config" at "modules/config.xqm";
import module   namespace   console = "http://exist-db.org/xquery/console";
import module   namespace   admin   = "http://salamanca/admin"  at "modules/admin.xql";
declare         namespace   output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request = "http://exist-db.org/xquery/request";
declare         namespace   response = "http://exist-db.org/xquery/response";
declare         namespace   util     = "http://exist-db.org/xquery/util";
declare namespace tei               = "http://www.tei-c.org/ns/1.0";

(: This corpus administration module creates a zip file containing all TEI files (except for W0010!) :)

let $debug              := if ($config:debug = ("trace", "info")) then console:log("Creating corpus zip file requested.") else ()

let $tmpCollection := $config:data-root || '/sal-tei-corpus'

(: Create temporary collection to be zipped :)
let $removeStatus := if (xmldb:collection-available($tmpCollection)) then xmldb:remove($tmpCollection) else ()
let $zipTmp := xmldb:create-collection($config:data-root, 'sal-tei-corpus')

(: Get TEI data, expand them and store them in the temporary collection :)
let $serializationOpts := 'method=xml expand-xincludes=yes omit-xml-declaration=no indent=yes encoding=UTF-8 media-type=application/tei+xml' 
let $works := for $reqWork in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5 and not(. eq 'W0010')]/string()
                return if (doc-available($config:tei-works-root || '/' || $reqWork || '.xml')) then
                        let $expanded := util:expand(doc($config:tei-works-root || '/' || $reqWork || '.xml')/tei:TEI, $serializationOpts) 
                        let $store := xmldb:store-as-binary($tmpCollection, $expanded/@xml:id || '.xml', $expanded)
                        return $expanded
                       else ()
    
(: Create a zip archive from the temporary collection and store it :)    
let $zip := compression:zip(xs:anyURI($tmpCollection), false())
let $save := xmldb:store-as-binary($config:files-root , 'sal-tei-corpus.zip', $zip)

(: Clean the database from temporary files/collections :)
let $removeStatus2 := for $work in $works return xmldb:remove($tmpCollection, $work/@xml:id || '.xml')
let $removeStatus3 := if (xmldb:collection-available($tmpCollection)) then xmldb:remove($tmpCollection) else ()
let $filepath := $config:files-root  || '/sal-tei-corpus.zip'
let $removeStatus4            := if (file:exists($filepath)) then
                                      xmldb:remove($filepath)
                                 else ()

let $debug              := if ($config:debug = ("trace", "info")) then console:log("Created and stored corpus zip.") else ()

return 
if ($save) then <output><status>Saved corpus zip file at {$filepath}.</status></output>
else <output><status>Corpus zip file could not be stored!</status></output>


