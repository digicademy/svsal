xquery version "3.1";

(: ####++++----

Xql File to upload the corresponding Pdf File into the corresponding folder 
MAH 10.02.2022

 ----++++#### :)

module namespace upload = "https://www.salamanca.school/xquery/upload";

declare namespace tei         = "http://www.tei-c.org/ns/1.0";
declare namespace compression = "http://exist-db.org/xquery/compression";
declare namespace exist       = "http://exist.sourceforge.net/NS/exist";
declare namespace file        = "http://exist-db.org/xquery/file";
declare namespace request     = "http://exist-db.org/xquery/request";
declare namespace util        = "http://exist-db.org/xquery/util";
declare namespace xmldb       = "http://exist-db.org/xquery/xmldb";

import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace admin      = "https://www.salamanca.school/xquery/admin"      at "admin.xqm";
import module namespace app        = "https://www.salamanca.school/xquery/app"        at "app.xqm";
import module namespace config     = "https://www.salamanca.school/xquery/config"     at "config.xqm";
import module namespace render-app = "https://www.salamanca.school/xquery/render-app" at "render-app.xqm";

declare option exist:timeout "43000000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)
declare option exist:output-size-limit "5000000"; (: max number of nodes in memory :)


declare function upload:uploadPdf($rid as xs:string) {
    
    
    let $PdfInput := request:get-uploaded-file-name('FileUpload')
    let $content := request:get-uploaded-file-data('FileUpload')
    let $debug := if ($config:debug = ("trace", "info")) then
        console:log("[ADMIN] PDF ready to store.")
    else
        ()
    let $store := (xmldb:store($config:pdf-root, $PdfInput, util:binary-to-string($content)))
    let $resultpositive := if (doc-available($config:pdf-root || '/' || $rid || ".pdf"))
    then
        <results>
            <message>The PDF for the work has been successfully uploaded. </message>
        </results>
    else
        ()
    
    let $debug := if ($config:debug = ("trace", "info")) then
        console:log("[ADMIN] Checking the PDF input.")
    else
        ()
    
    
    return
        
        if ($rid eq substring-before($PdfInput, ".pdf"))
        
        then
            $store and $resultpositive
        
        
        
        else
            if (doc-available($config:pdf-root || '/' || $rid || ".pdf")) then
                <results>
                    <message>The PDF {$PdfInput} of the work {$rid} exists already and was rendered on </message>
                </results>
            
            else
                <results>
                    <message>The PDF {$PdfInput} of the work {$rid} could not be uploaded. Possible errors are:
                        - The file does not correspond to the work. Please check that you upload the corresponding PDF.
                        - The file </message>
                </results>




};
