xquery version "3.1";

module namespace corr = "https://api.salamanca.school/xquery/corr";

declare namespace functx = "http://www.functx.com";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare variable $corr:separators := '¶\(\)/\.,:;\?¡¿\*&amp;&apos;§'; (: characters that may occur as token separators; excluded '\-\+&quot;' 
                                                                        there shouldn't be any quotation signs :)
(: characters that are 'equivalent': they might occur in any possible combination in a word form :)
declare variable $corr:interchangeableChars := map {
        'u': 'v',
        'v': 'u',
        'i': 'j',
        'j': 'i',
        'æ': 'ę'
    };
 
(: (composed) characters that can simply be replaced (all of them) in a word form :)
declare variable $corr:replaceableChars := map {
        'ſ': 's',
        'æ': 'ae',
        'œ': 'oe',
        'è': 'e',
        'é': 'e',
        'ò': 'o',
        'ó': 'o',
        'à': 'a',
        'á': 'a',
        'ù': 'u',
        'ú': 'u'
    };

(: define colors for rendering the various types of classes in the HTML list :)
declare variable $corr:color-ok := "lightgreen";
declare variable $corr:color-not-found := "#ff6666";
declare variable $corr:color-ambiguous := "orange";
declare variable $corr:color-additional := "cyan";
declare variable $corr:color-lemma-unknown := "#cc9bea";
declare variable $corr:color-special-form := "#b3b3ff";

(: FUNCTIONS FOR THE CREATION OF CORRECTION LISTS :)

(: Tokenizes a given line. 
@param $line: the line's text as a string
@return: a list of tokens in the order of their occurrence, each token within a <tok> element.
:)
declare function corr:tokenizeLine($line as xs:string) {
    let $removeSeparators := replace($line, concat('[', $corr:separators ,']'), ' ')
    let $normSpace := normalize-space($removeSeparators)
    let $tokens := tokenize($normSpace, '\s+')
    for $token in tokenize($normSpace, '\s+') return 
        (: remove digit-only tokens; include Roman numbers here? :)
        if (matches($token, '^\d+$')) then ()
        else <tok>{$token}</tok>
};

(: Determines the type of a token with regards to its potential line-crossing.
@param $token: the token to be checked.
@param $precedingLb: the lb element corresponding to the line that the token occurs in.
@param $followingLb: the lb element of the following line.
@return: a string indicating whether the token is part of a larger, line-crossing token marked by hyphenation signs ("hyphenated"), 
         is *not* part of a larger token ("simple") or might potentially be a sub-token ("complex").
:)
declare function corr:getTokenType($token as node(), $precedingLb as node(), $followingLb as node()?) as xs:string {
    (: determine position of the current token :)
    let $pos := 
        if (not($token/preceding-sibling::tok) and not($token/following-sibling::tok)) then 'single'
        else if (not($token/preceding-sibling::tok)) then 'first' 
        else if (not($token/following-sibling::tok)) then 'last' 
        else 'inter'
    let $type :=    
        if ($pos eq 'single') then
            if ($precedingLb[@break eq 'yes'] and $followingLb[@break eq 'yes']) then 'simple'
            else if ($precedingLb[@break eq 'no'] or $followingLb[@break eq 'no']) then 'hyphenated'
            else 'complex'
        else if ($pos eq 'first') then
            if ($precedingLb[@break eq 'yes']) then 'simple'
            else if ($precedingLb[@break eq 'no']) then 'hyphenated'
            else 'complex'
        else if ($pos eq 'last') then
            if ($followingLb[@break eq 'yes']) then 'simple'
            else if (not($followingLb)) then 'simple' (: TODO: check if this works or is necessary at all :)
            else if ($followingLb[@break eq 'no']) then 'hyphenated'
            else 'complex'
        else 'simple'
    return $type
};

(: Processes an lb element, trying to determine whether it is a word-separating element by analyzing the 
preceding and the following line text with regards to clear separation markers (interpunctuation etc.)
@param $break: a tei:lb element
@return: the processed tei:lb element, possibly complemented by a @break="yes" (if it definitely is a break)
:)
declare function corr:getBreak($break as node()) {
    let $regexString := concat('[', $corr:separators ,']')
    let $isBreak := 
        (: if lb is preceded or followed by a note anchor, it has to be a break :)
        if ($break/preceding-sibling::text[1]/@type[. eq 'note-anchor'] or $break/following-sibling::text[1]/@type[. eq 'note-anchor']) then true()
        (: check if first following text node (that is not just a newline) starts with a special sign :)
        else if (matches(normalize-space($break/following-sibling::text[1]), '^' || $regexString)) then true()
        (: check if last preceding text node (that is not just a newline), if there is any, ends with a special sign :)
        else if ($break/preceding-sibling::text) then
            if (matches(normalize-space($break/preceding-sibling::text[1]), $regexString || '$')) then true()
            else false()
        else if (not($break/preceding-sibling::text)) then true() (: TODO: check if this works or is necessary at all; 
                                                                           was supposed to be relevant especially for (first line in) marginals :)
        else false()
    let $lb := 
        if ($isBreak) then
            if ($break[@break eq 'no']) then error(QName('', 'LBAlreadyHasBreak'), $break/@xml:id) 
            (: this should not throw an error (in case the lb already has @break=no, something is wrong with the previous lb tagging) :)
            else <lb>{$break/(@*, if (not($break/@break[. eq 'yes'])) then attribute break {'yes'} else ())}</lb>
        else <lb>{$break/(@*)}</lb>
    return $lb
};

(: Transforms a simple "facs:..." id (as used in pb/@facs) into a full-blown URL leading to the respective image resource 
@param $imageId: the image id for which a link is to be created.
@return: the image link.
:)
declare function corr:makeImageUrl($imageId as xs:string) as xs:string {
    let $imgUrl := 
        if (matches($imageId, '^facs:W\d{4}-[A-z]-\d{4}$')) then 
            replace($imageId, '^facs:((W\d{4})-([A-z])-(\d{4}))$', 'http://facs.salamanca.school/$2/$3/$1.jpg')
        else if (matches($imageId, '^facs:W\d{4}-\d{4}$')) then 
            replace($imageId, '^facs:((W\d{4})-\d{4})$', 'http://facs.salamanca.school/$2/$1.jpg')
    else error()
    return $imgUrl
};

(: Gets a wordform from a dictionary for a given input token. If a wordform corresponding to the token exists 
in the dict (potentially normalized: u/v, i/j), the wordform is returned; otherwise, an empty sequence is returned. 
@param $token: the token for which a word form is to be extracted.
@param $dict: the freeling dictionary
@return: the wordform, if existing in the dict, or the empty sequence
:)
declare function corr:getWordformFromDict($token as xs:string, $dict as map(*)) {
    let $normalizedToken := corr:replaceChars($token, $corr:replaceableChars)
    let $tokenVariants := 
        (: we compare the token in several different forms with the dictionary: 
         1. the original token, unaltered 
         2. the normalized token, with special characters in standardized form (e.g., 'é' -> 'e')
         3. all forms of the *original* token with interchanged characters (e.g., 'u' vs. 'v')
         4. all forms of the *normalized* token with interchanged characters
         :)
        distinct-values(
            ($token, 
             $normalizedToken,
             corr:interchangeChars($token),
             corr:interchangeChars($normalizedToken))
        )
    let $variantsInDict :=
        for $t in $tokenVariants return
            if (map:contains($dict, lower-case($t))) then lower-case($t) else ()
    (: deprecated: dict entries are always lower-cased, so we lower-case the *first* letter; 
       subsequent letters should already be lower-cased, otherwise this needs to be corrected manually :)
    (:let $lowerFirst := if (matches($token, '^[A-Z]')) then concat(lower-case(substring($token, 1, 1)), substring($token, 2, string-length($token))) else $token:)
    
    (: we check if the token contains an upper-cased letter after previous lower-cased letters; in this case, we have a typo or print error that needs 
        to be resolved manually :)
    let $incorrectUpperChar := if (matches($token, '[a-z].*?[A-Z]')) then true() else false()
    (: we check for the token in lower-cased form with the dictionary :)
    let $out := 
        if ($incorrectUpperChar) then ()
        else if (count($variantsInDict) gt 0) then $variantsInDict[1] 
(:        else if (map:contains($dict, lower-case($token))) then lower-case($token) :)
        else ()
    return $out
};

(:
~ Creates the forms of a token for all possible combinations of interchangeable chars (see $corr:interchangeableChars).
~ Number of possible combinations: 2^X where X is the number interchangeable chars in the token.
:)
declare function corr:interchangeChars($token as xs:string?) as xs:string* {
        let $char := substring($token,1,1)
        let $prefixes := 
            if (map:contains($corr:interchangeableChars, $char)) then
                ($char, map:get($corr:interchangeableChars, $char))
            else 
                $char
        return
            if (substring($token,2)) then
                for $prefix in $prefixes return 
                    for $suffix in corr:interchangeChars(substring($token,2)) return
                        $prefix || $suffix
            else $prefixes
    
};

(:
~ Replaces all characters in a token by their standardized forms (see $corr:replaceableChars).
:)
declare function corr:replaceChars($token as xs:string, $charMap as map(*)?) as xs:string {
    if (map:size($charMap) gt 0) then
        let $thisKey := map:keys($charMap)[1]
        let $replacedToken := replace($token, $thisKey, map:get($charMap, $thisKey))
        return
            corr:replaceChars($replacedToken, map:remove($charMap, $thisKey))
    else 
        $token
};


declare function corr:importDict($lang as xs:string) as map(*) {
    if ($lang eq 'es') then 
        (: Spanish: there are currently 2 dicts :)
        (: a) the freeling dict (already containing lemmata), with wordforms as keys and lemmata as values :)
        let $freelingDict := map:merge(  
            for $line in tokenize(unparsed-text('../../../../woerterbuecher/es/wordforms-es.txt', 'utf-8'), '\n') 
                let $wordform := normalize-space(tokenize($line, '>')[1])
                let $lemma := normalize-space(tokenize($line, '>')[2])
                return if ($wordform and $lemma) then map:entry($wordform, $lemma) else ()
        )
        (: b) the iteratively extended dict of wordforms from Svsal texts only :)
        let $svsalDict := map:merge(
            for $line in tokenize(unparsed-text('../../../../woerterbuecher/build/dict/svsal-wordforms-es.txt', 'utf-8'), '\n')
                let $wordform := normalize-space(tokenize($line, '>')[1])
                let $lemma := normalize-space(tokenize($line, '>')[2])
                return if ($wordform and $lemma) then map:entry($wordform, $lemma) else ()
        )
        (: merge the maps from a) and b), with priority for the custom-built svsal key-value pairs :)
        return map:merge(($freelingDict, $svsalDict), map{'duplicates':'use-last'})
        (: deprecated: :)
        (:let $svsalDict := map:merge(
            for $line in tokenize(unparsed-text('../../../../woerterbuecher/es/svsal-wordforms-es-REVISED.txt', 'utf-8'), '\n')
                let $wordform := normalize-space($line)
                let $lemma := if ($freelingDict?($wordform)) then $freelingDict?($wordform) else 'N/A'
                return if ($wordform ne '') then map:entry($wordform, $lemma) else ()
        ):)
    else if ($lang eq 'la') then
        (: Latin: there is currently only the digicademy dict :)
        let $dict := map:merge(  
            for $line in tokenize(unparsed-text('../../../../woerterbuecher/lat/wordforms-lat-full.txt', 'utf-8'), '\n') 
                let $wordform := normalize-space(tokenize($line, '>')[1])
                let $lemma := normalize-space(tokenize($line, '>')[2])
                return if ($wordform and $lemma) then map:entry($wordform, $lemma) else ()
        )
        return $dict
    else error() (: wrong language input :)
};


(: TODO: 
    - remove Roman digits?
    - if there occur any errors, return to version from before 2018-11-06
:)

