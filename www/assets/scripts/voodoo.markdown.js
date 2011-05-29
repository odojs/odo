(function($) {
	$.extend($, {
        markdown: function () {
            return {
                strip: function (markdown) {
                    return markdown
                        .replace(/(\[[a-zA-Z ][^\]]*\])/g, function(match, p1, index, title) {
                            return match.substr(1, match.length - 2);
                        })
                        .replace(/(\[[0-9]*\])/g, function(match, p1, index, title) {
                            return '';
                        })
                        .replace(/\*\*\[\*\*/, '')
                        .replace(/\*\*\]\*\*/, '')
                        .replace(/\*\*\*\*/, '');
                },
                list: function (markdown) {
                    // remove blank lines
                    // prefix every new line with *
                    var result = [];
                    var chunks = content.split('\n');
                    $.each(chunks, function(key, value) {
                        if (value == '')
                            return;
                        result.push('* ' + value);
                    });
                    return result.join('\n');
                }
            }
        }
	});
})(jQuery);