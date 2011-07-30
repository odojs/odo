/*
	Voodoo Dialog - display and communicate with a modal dialog

	Version: 1.0
	Author: Thomas Coats


	Features:

	1.	API functionality:
		
		$.dialog().show();
		$.dialog().hide();


	Required CSS:
    
        #dialog
        {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            width: 100%;
            z-index: 1002;
        }
            
            #dialog > .inner {
                margin: 150px auto 50px auto;
            }
*/

(function ($) {
	$.dialog = function (settings) {
	    $.dialog.api = {
            show: function (content) {
                if (!$.dialog.dialog) {
                    if ($.overlay)
                        $.overlay().show();
                    $.dialog.dialog = $('<div />')
                        .attr('id', 'dialog')
                        .append($('<div />')
                            .addClass('inner')
                            .append(content))
                        .appendTo($('body'));
                }
                return $.dialog.api;
            },
            hide: function (fn) {
                if ($.dialog.dialog) {
                    if (fn) {
                        $.dialog.hide.push(fn);
                        return $.dialog.api;
                    }
                    if ($.overlay)
                        $.overlay().hide();
                    $.each($.dialog.hide, function(key, fn) {
                        fn();
                    });
                    $.dialog.hide = [];
                    $.dialog.dialog.remove();
                    $.dialog.dialog = null;
                }
                return $.dialog.api;
            }
        };
		return $.dialog.api;
	};
    $.dialog.hide = [];
})(jQuery);