function highlightSpanClassInText(htmlClass,invokingElement){
    if ($(invokingElement).hasClass('highlighted')) {
            $("." + htmlClass).removeClass('highlighted');
    } else {
            $("." + htmlClass).addClass('highlighted');
    }
    $(invokingElement).toggleClass("highlighted");
/*    $(invokingElement).children("span").toggleClass("glyphicon-check glyphicon-unchecked"); */
}

function toggleOrigEditMode(invokingElement){
    $(".edited").toggleClass('unsichtbar');
    $(".original").toggleClass('unsichtbar');
}

function applyOrigMode() {
    console.log("Setting viewing mode to orig.");
    $(".edited").addClass('unsichtbar');
    $(".original").removeClass('unsichtbar');
    params = new URLSearchParams(window.location.search) ;
    params.set('mode', 'orig');
    window.history.replaceState(null, '', window.location.pathname+'?'+params+window.location.hash);
    if ($('.next').length) {
        nextParams = new URLSearchParams($('.next')[0].search);
        nextParams.set('mode', 'orig');
        $('.next').prop('href',     $('.next')[0].pathname     + '?' + nextParams);
    }
    if ($('.previous').length) {
        prevParams = new URLSearchParams($('.previous')[0].search);
        prevParams.set('mode', 'orig');
        $('.previous').prop('href', $('.previous')[0].pathname + '?' + prevParams);
    }
    if ($('.top').length) {
        topParams = new URLSearchParams($('.next')[0].search);
        topParams.set('mode', 'orig');
        $('.top').prop('href',      $('.top')[0].pathname      + '?' + topParams);
    }
}

function applyEditMode() {
    console.log("Setting viewing mode to edit.");
    $(".edited").removeClass('unsichtbar');
    $(".original").addClass('unsichtbar');    
    params = new URLSearchParams(window.location.search) ;
    params.set('mode', 'edit');
    window.history.replaceState(null, '', window.location.pathname+'?'+params+window.location.hash);
    if ($('.next').length) {
        nextParams = new URLSearchParams($('.next')[0].search);
        nextParams.set('mode', 'edit');
        $('.next').prop('href',     $('.next')[0].pathname     + '?' + nextParams);
    }
    if ($('.previous').length) {
        prevParams = new URLSearchParams($('.previous')[0].search);
        prevParams.set('mode', 'edit');
        $('.previous').prop('href', $('.previous')[0].pathname + '?' + prevParams);
    }
    if ($('.top').length) {
        topParams = new URLSearchParams($('.next')[0].search);
        topParams.set('mode', 'edit');
        $('.top').prop('href',      $('.top')[0].pathname      + '?' + topParams);
    }
}

function applyMode() {
    mode = window.location.href.match(/mode=((orig)|(edit))/i)[1]
    if (mode == 'orig') {
        applyOrigMode();
    } else if (mode == 'edit') {
        applyEditMode();
    }
}
