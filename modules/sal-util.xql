xquery version "3.1";

module namespace sal-util = "http://salamanca/sal-util";

(: Normalizes work, author, lemma, news, and working paper ids (and returns everything else as-is :)
declare function sal-util:normalizeId($id as xs:string?) as xs:string? {
    if ($id) then
        if (matches($id, '^[wW]\d{4}(_[vV][oO][lL]\d{2})?$')) then translate($id, 'wvLO', 'WVlo')
        else if (matches($id, '^[lLaAnN]\d{4}$')) then upper-case($id) (: lemma, author, news :)
        else if (matches($id, '^[wW][pP]\d{4}$')) then upper-case($id)
        else $id
    else ()
};