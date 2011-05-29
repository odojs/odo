// turns <a href="http://www.youtube.com/v/NY5N5vgtUB4&hl=en_US&fs=1&">Heaviest truck pulled (640x385)</a> into a swfobject embed



// I would like to expand this to take options etc.
(function($) {
    $.fn.flashEmbed = function() {
        // we need to name the ids that we create so we keep an index
        var index = 1;
        $("a[href^='http://www.youtube.com/'],a[href^='http://youtube.com/'],a[href$='.swf']").each(function() {
            var id = 'swfobject-' + index;
            // find the width and height in the html (widthxheight)
            var matches = /\((\d*)x(\d*)\)/g.exec($(this).html());
            if (!matches) return;
            
            // replace the link with a div
            $('<div />')
                .attr('id', id)
                .html($(this).html())
                .insertAfter($(this));
            $(this).remove();
            
            // launch swfobject
            swfobject.embedSWF(
                $(this).attr('href'),
                id,
                matches[1],
                matches[2],
                '8');
            
            index++;
        });
    }
})(jQuery);      
