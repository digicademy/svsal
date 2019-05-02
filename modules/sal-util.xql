xquery version "3.1";

module namespace sal-util = "http://salamanca/sal-util";

import module namespace config = "http://salamanca/config" at "config.xqm";
import module namespace app        = "http://salamanca/app"    at "app.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";


(: Normalizes work, author, lemma, news, and working paper ids (and returns everything else as-is :)
declare function sal-util:normalizeId($id as xs:string?) as xs:string? {
    if ($id) then
        if (matches($id, '^[wW]\d{4}(_[vV][oO][lL]\d{2})?$')) then translate($id, 'wvLO', 'WVlo')
        else if (matches($id, '^[lLaAnN]\d{4}$')) then upper-case($id) (: lemma, author, news :)
        else if (matches($id, '^[wW][pP]\d{4}$')) then upper-case($id)
        else $id
    else ()
};


(: validate work/author/... IDs :)

declare function sal-util:AUTexists($aid as xs:string?) as xs:boolean {
    if ($aid) then boolean(doc($config:tei-meta-root || '/' || 'sources-list.xml')/tei:TEI/tei:text//tei:author[lower-case(substring-after(@ref, 'author:')) eq lower-case($aid)])
    else false()
};

(: 1 = valid & available; 0 = valid, but not yet available; -1 = not valid :)
declare function sal-util:AUTvalidateId($aid as xs:string?) as xs:integer {
    if ($aid and matches($aid, '^[aA]\d{4}$')) then
        (: TODO: additional condition when author articles are available - currently this will always resolve to -1 :)
        if (sal-util:AUTexists(sal-util:normalizeId($aid))) then 0
        else -1
    else -1    
};

declare function sal-util:LEMexists($lid as xs:string?) as xs:boolean {
    (: TODO when we have a list of lemma ids :)
    (:if ($lid) then boolean(doc(.../...) eq $lid])
    else :)
    false()
};

(: 1 = valid & available; 0 = valid, but not yet available; -1 = not valid :)
declare function sal-util:LEMvalidateId($lid as xs:string?) as xs:integer {
    if ($lid and matches($lid, '^[lL]\d{4}$')) then
        (: TODO: additional conditions when lemmata/entries are available - currently this will always resolve to -1 :)
        if (sal-util:LEMexists(sal-util:normalizeId($lid))) then 0
        else -1
    else -1    
};

declare function sal-util:WRKexists($wid as xs:string?) as xs:boolean {
    if ($wid) then boolean(doc($config:tei-meta-root || '/' || 'sources-list.xml')/tei:TEI/tei:text//tei:bibl[lower-case(substring-after(@corresp, 'work:')) eq lower-case($wid)])
    else false()
};

(: 2 = valid, full data available; 1 = valid, but only metadata available; 0 = valid, but not yet available; -1 = not valid :)
declare function sal-util:WRKvalidateId($wid as xs:string?) as xs:integer {
    if ($wid and matches($wid, '^[wW]\d{4}(_Vol\d{2})?$')) then
        if (app:WRKisPublished(<dummy/>, map{}, $wid)) then 2
        else if (doc-available($config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml')) then 1
        else if (sal-util:WRKexists($wid)) then 0
        else -1
    else -1    
};

(: concepts? :)

