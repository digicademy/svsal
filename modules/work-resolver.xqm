xquery version "3.1";

(: ####++++----

    Work Resolver Module

    Provides functions to resolve TEI file paths to work IDs that need regeneration.
    Handles XInclude parent detection for multivolume works.

    Example use cases:
    - A changed file like "works/W0013.xml" resolves to work "W0013"
    - A changed file like "works/W0066_Vol_02.xml" resolves to parent work "W0066"

----++++#### :)

module namespace resolver = "https://www.salamanca.school/xquery/resolver";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xi = "http://www.w3.org/2001/XInclude";

import module namespace console = "http://exist-db.org/xquery/console";
import module namespace config = "https://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";

(:~
 : Resolves a sequence of TEI file paths to work IDs that need regeneration.
 : Handles XInclude parent detection for multivolume works.
 :
 : @param $file-paths Sequence of file paths (e.g., "works/W0013.xml", "works/W0066_Vol_02.xml")
 : @return Sequence of unique work IDs that need regeneration
 :)
declare function resolver:resolve-work-ids($file-paths as xs:string*) as xs:string* {
    let $debug := if ($config:debug = "trace") then
        console:log("[RESOLVER] Resolving work IDs for file paths: " || string-join($file-paths, ", "))
    else ()

    let $work-ids :=
        for $file-path in $file-paths
        let $work-id := resolver:extract-work-id($file-path)
        return
            if ($work-id) then
                (: Return the direct work ID and any parent works that include it :)
                let $parent-ids := resolver:find-parent-works($work-id)
                let $debug := if ($config:debug = "trace" and count($parent-ids) > 0) then
                    console:log("[RESOLVER] Found parent works for " || $work-id || ": " || string-join($parent-ids, ", "))
                else ()
                return ($work-id, $parent-ids)
            else
                let $warning := console:log("[RESOLVER] Warning: Could not extract work ID from file path: " || $file-path)
                return ()

    (: Deduplicate and sort the results :)
    let $unique-ids := distinct-values($work-ids)
    let $debug := if ($config:debug = "trace") then
        console:log("[RESOLVER] Resolved to unique work IDs: " || string-join($unique-ids, ", "))
    else ()

    return $unique-ids
};

(:~
 : Finds parent works that include a given work via XInclude.
 : Searches through the TEI works collection for xi:include references.
 :
 : @param $work-id The work ID to search for (e.g., "W0066_Vol_02")
 : @return Sequence of parent work IDs
 :)
declare function resolver:find-parent-works($work-id as xs:string) as xs:string* {
    let $debug := if ($config:debug = "trace") then
        console:log("[RESOLVER] Searching for parent works that include: " || $work-id)
    else ()

    (: Search for files that XInclude this work :)
    let $parent-docs :=
        try {
            collection($config:tei-works-root)//xi:include[contains(@href, $work-id || '.xml')]/root()
        } catch * {
            let $error := console:log("[RESOLVER] Error searching for parent works: " || $err:description)
            return ()
        }

    (: Extract work IDs from the parent documents :)
    let $parent-ids :=
        for $doc in $parent-docs
        let $doc-uri := document-uri($doc)
        let $filename := tokenize($doc-uri, '/')[last()]
        let $parent-id := resolver:extract-work-id($filename)
        where $parent-id and $parent-id != $work-id
        return $parent-id

    let $debug := if ($config:debug = "trace" and count($parent-ids) > 0) then
        console:log("[RESOLVER] Found " || count($parent-ids) || " parent work(s) for " || $work-id)
    else ()

    return distinct-values($parent-ids)
};

(:~
 : Extracts work ID from a file path.
 : Handles both simple works (W0013.xml) and volume files (W0066_Vol_02.xml).
 :
 : @param $file-path File path like "works/W0013.xml" or "works/W0066_Vol_02.xml"
 : @return Work ID like "W0013" or "W0066_Vol_02", or empty if no match
 :)
declare function resolver:extract-work-id($file-path as xs:string) as xs:string? {
    (: Extract just the filename from the path :)
    let $filename := tokenize($file-path, '/')[last()]

    (: Remove .xml extension :)
    let $name-without-ext := replace($filename, '\.xml$', '')

    (: Check if it matches a work ID pattern (W followed by 4 digits, optionally with _Vol_XX) :)
    let $match := matches($name-without-ext, '^W\d{4}(_Vol_\d+)?$')

    return
        if ($match) then
            $name-without-ext
        else
            let $debug := if ($config:debug = "trace") then
                console:log("[RESOLVER] File path does not match work ID pattern: " || $file-path)
            else ()
            return ()
};

(:~
 : Helper function to get the base work ID from a volume ID.
 : For example, "W0066_Vol_02" returns "W0066".
 :
 : @param $work-id Work ID which may include volume suffix
 : @return Base work ID without volume suffix
 :)
declare function resolver:get-base-work-id($work-id as xs:string) as xs:string {
    if (contains($work-id, '_Vol_')) then
        substring-before($work-id, '_Vol_')
    else
        $work-id
};
