xquery version "3.1";

import module   namespace   config  = "http://salamanca/config" at "modules/config.xqm";
import module   namespace   console = "http://exist-db.org/xquery/console";
import module   namespace   admin   = "http://salamanca/admin"  at "modules/admin.xql";
declare         namespace   output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request = "http://exist-db.org/xquery/request";
declare         namespace   response = "http://exist-db.org/xquery/response";
declare         namespace   util     = "http://exist-db.org/xquery/util";
declare namespace tei               = "http://www.tei-c.org/ns/1.0";

let $format := request:get-parameter('format', '')

let $save :=
    if ($format eq 'tei') then admin:createTeiCorpus('admin')
    else if ($format eq 'txt') then admin:createTxtCorpus('admin') 
    else ()

return 
if ($save) then <output><status>Saved corpus zip file at {$save}.</status></output>
else <output><status>Corpus zip file could not be stored!</status></output>


