xquery version "3.1";

(: ####++++----

    Work resolver module for intelligent work ID resolution.
    Handles XInclude parent detection for multivolume works in CI/CD pipelines.

----++++#### :)

module namespace resolver = "https://www.salamanca.school/xquery/resolver";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xi = "http://www.w3.org/2001/XInclude";

import module namespace config = "https://www.salamanca.school/xquery/config" at "config.xqm";
import module namespace console = "http://exist-db.org/xquery/console";

(:~
 : Resolves file paths to work IDs that need regeneration.
 : Handles XInclude parent detection for multivolume works.
 : @param $file-paths Sequence of file paths from git diff
 : @return Sequence of unique work IDs to regenerate
 :)
declare function resolver:resolve-work-ids($file-paths as xs:string*) as xs:string* {
    let $work-ids := 
        for $file in $file-paths
        let $direct-id := resolver:extract-work-id($file)
        let $parent-ids := resolver:find-parent-works($direct-id)
        return ($direct-id, $parent-ids)
    return distinct-values($work-ids[. != ''])
};

(:~
 : Extracts work ID from file path (e.g., "works/W0066_Vol_02.xml" → "W0066_Vol_02")
 : @param $file-path The file path to extract from
 : @return The extracted work ID or empty sequence
 :)
declare function resolver:extract-work-id($file-path as xs:string) as xs:string? {
    if (matches($file-path, 'W\d{4}')) then
        replace($file-path, '^.*/((W\d{4})[^/]*?)\.xml$', '$1')
    else ()
};

(:~
 : Finds parent works that XInclude this work (for multivolume detection)
 : @param $work-id The work ID to check
 : @return Sequence of parent work IDs
 :)
declare function resolver:find-parent-works($work-id as xs:string?) as xs:string* {
    if (empty($work-id)) then ()
    else
        let $debug := if ($config:debug = ("trace", "info")) then 
            console:log("[RESOLVER] Looking for parents of work: " || $work-id)
        else ()
        let $parent-works := 
            collection($config:tei-works-root)//tei:TEI[
                .//xi:include[contains(@href, $work-id)]
            ]/@xml:id/string()
        let $debug := if ($config:debug = ("trace", "info") and count($parent-works) > 0) then 
            console:log("[RESOLVER] Found " || count($parent-works) || " parent work(s) for " || $work-id || ": " || string-join($parent-works, ', '))
        else ()
        return $parent-works
};

(:~
 : Returns a dependency map for all works (for caching/optimization)
 : @return Map of work-id → parent-work-ids
 :)
declare function resolver:get-dependency-map() as map(*) {
    let $debug := if ($config:debug = ("trace", "info")) then 
        console:log("[RESOLVER] Building dependency map...")
    else ()
    let $entries :=
        for $work in collection($config:tei-works-root)//tei:TEI[@xml:id]
        let $work-id := $work/@xml:id/string()
        let $included-works := $work//xi:include/@href/string() ! resolver:extract-work-id(.)
        return
            for $included in $included-works[. != '']
            return map:entry($included, $work-id)
    let $merged-map := if (count($entries) > 0) then map:merge($entries) else map {}
    let $debug := if ($config:debug = ("trace", "info")) then 
        console:log("[RESOLVER] Dependency map built with " || map:size($merged-map) || " entries.")
    else ()
    return $merged-map
};
