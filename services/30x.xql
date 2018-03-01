xquery version "3.0";

import module namespace request  = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace console  = "http://exist-db.org/xquery/console";

let $path               := request:get-parameter('path', '')
let $status             := request:get-parameter('statusCode', 303)

return
    (
        response:set-status-code($status), response:set-header('Location', $path)
    )
