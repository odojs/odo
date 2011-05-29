/*
	Voodoo Overlay - display and communicate with a modal overlay

	Version: 1.0
	Author: Thomas Coats


	Features:
	
	1.	API functionality:
		
		$.overlay().show();
		$.overlay().hide();


	Required CSS:
	
        #overlay 
        {
            position: fixed;
            top: 0;
            left: 0;
            height: 100%;
            width: 100%;
            z-index: 1001;
            opacity: 0.4;
            background-color: black;
        }
        
*/

(function ($) {
	$.overlay = function (settings) {
        $.overlay.api = {
            show: function () {
                if (!$.overlay.overlay) {
                    $.overlay.overlay = $('<div />')
                        .attr('id', 'overlay')
                        .css('height', $('document').css('height'))
                        .appendTo($('body'));
                }
                return $.overlay.api;
            },
            hide: function () {
                if ($.overlay.overlay) {
                    $.overlay.overlay.remove();
                    $.overlay.overlay = null;
                }
                return $.overlay.api;
            }
        };
		return $.overlay.api;
	};
})(jQuery);