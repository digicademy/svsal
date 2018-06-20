xquery version "1.0";

(: Prepare db before package data is uploaded.
   - upload collection configuration
:)

import module namespace xmldb =   "http://exist-db.org/xquery/xmldb";
import module namespace sm    =   "http://exist-db.org/xquery/securitymanager";
import module namespace util  = "http://exist-db.org/xquery/util";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: Membership in the admin group is required for writing in the database and setting permissions, which many administration 
    (like render.xql/html) tasks do. Permissions are enforced by file ownership, managed in post-install.xql :)

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xmldb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: store the collection configuration :)
local:mkcol("/db/system/config", $target), 
        xmldb:store-files-from-pattern(concat("/db/system/config", $target), $dir, "*.xconf")


