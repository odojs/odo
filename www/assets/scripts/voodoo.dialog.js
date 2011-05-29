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
                    $.dialog.dialog = $('<div />')
                        .attr('id', 'dialog')
                        .append($('<div />')
                            .addClass('inner')
                            .append(content))
                        .appendTo($('body'));
                }
                return $.dialog.api;
            },
            hide: function () {
                if ($.dialog.dialog) {
                    $.dialog.dialog.remove();
                    $.dialog.dialog = null;
                }
                return $.dialog.api;
            }/*,
            shake: function () {
                if ($.dialog.current) {
                    var children = $.dialog.inner.children();
                    children.stop();
                    children
                        .animate({ 'margin-left': '+=10px' }, 50)
                        .animate({ 'margin-left': '-=20px' }, 100)
                        .animate({ 'margin-left': '+=20px' }, 100)
                        .animate({ 'margin-left': '-=20px' }, 100)
                        .animate({ 'margin-left': '+=10px' }, 50, function () {
                            children.css('margin-left', 'auto');
                        });
                }
                return $.dialog.api;
            }*/
        };
		return $.dialog.api;
	};
})(jQuery);