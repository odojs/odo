(function($) {
	$.extend($, {
        linkify: function (html, linkify) {
            if (!linkify)
                linkify = function (url) {
                    return '<a href="' + url + '">' + url + '</a>';
                }
            return html.replace(/(?:http|ftp|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+(?:[\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&amp;/~\+#])/g, function(match, index) {
                // skip anything inside an HTML tag
                if ((html.lastIndexOf('>', index) < html.lastIndexOf('<', index))
                        // skip anything already inside an anchor tag
                        || (html.lastIndexOf('</a>', index) < html.lastIndexOf('<a ', index)))
                    return match;
                return linkify(match);
            });
        },
        linkifyWord: function (html, word, linkify) {
            var result = '';
            var lowerCaseword = word.toLowerCase();
            
            while (html.length > 0) {
                var i = html.toLowerCase().indexOf(lowerCaseword, i);
                if (i < 0)
                    return result + html;
        
                // should we skip?
                if (
                        // skip if there is a letter before
                        (i > 0 && /^[a-zA-Z]$/.test(html[i - 1]))
                        // skip if there is a letter afterwards
                        || (i + word.length < html.length && /^[a-zA-Z]$/.test(html[i + lowerCaseword.length]))
                        // skip anything inside an HTML tag
                        || (html.lastIndexOf('>', i) < html.lastIndexOf('<', i))
                        // skip anything already inside an anchor tag
                        || (html.lastIndexOf('</a>', i) < html.lastIndexOf('<a ', i))) {
                    i++;
                    continue;
                }
        
                // add the part that didn't, match plus our new content
                result += html.substring(0, i)
                    + linkify(word, html.substr(i, word.length));
        
                // we don't have to look at that part of the html
                html = html.substr(i + word.length);
                i = 0;
            }
          
            return result;
        },
        linkifyWiki: function (html, pages, linkify) {
            var newPages = pages.slice(0);
            // sort by string length, longer ones at the start
            newPages.sort(function (x, y) {
                if (x.length < y.length)
                    return 1;
                else if (x.length > y.length)
                    return -1;
                else
                    return 0;
            });
            // this means we are matching the longest articles first, 
            // so we will get the most complete match
            for (var i = 0; i < newPages.length; i++)
                html = $.linkifyWord(html, newPages[i], linkify);
            
            return html;
        }
    });
    
	$.extend($.fn, {
		maxLength: function(max) {
			this.each(function() {
				//Get the type of the matched element
				var type = this.tagName.toLowerCase();
				//If the type property exists, save it in lower case
				var inputType = this.type ? this.type.toLowerCase() : null;
				//Check if is a input type=text OR type=password
				if (type == "input" && inputType == "text" || inputType == "password") {
					//Apply the standard maxLength
					this.maxLength = max;
				}
				//Check if the element is a textarea
				else if (type == "textarea") {
					//Add the key press event
					$(this).keypress(function(e) {
						//Get the event object (for IE)
						var ob = e || event;
						//Get the code of key pressed
						var keyCode = ob.keyCode;
						//Check if it has a selected text
						var hasSelection = document.selection ? document.selection.createRange().text.length > 0 : this.selectionStart != this.selectionEnd;
						//return false if can't write more
						return !(this.value.length >= max && (keyCode > 50 || keyCode == 32 || keyCode == 0 || keyCode == 13) && !ob.ctrlKey && !ob.altKey && !hasSelection);
					});
					//Add the key up event
					$(this).keyup(function() {
						//If the keypress fail and allow write more text that required, this event will remove it
						if (this.value.length > max) {
							this.value = this.value.substring(0, max);
						}
					});
				}
			});
		},
		autoAddRow: function() {
			this.each(function() {
				// we are at the container for the list of items,
				// there has to be at least one item already here,
				// but there may be more than one
				var container = $(this);
				var hasDisabled = false;
				function replaceEndDigits(value, index) {
					return value.replace(/\d*$/m, '') + index;
				}
				function replaceIndex(row, attribute, index) {
					row.find('[' + attribute + ']').each(function() {
						var value = $(this).attr(attribute);
						$(this).attr(attribute, replaceEndDigits(value, index));
					});
				}
				function reindex() {
					var index = 1;
					container.children().each(function() {
						var row = $(this);
						var id = row.attr('id');
						if (id)
							row.attr('id', replaceEndDigits(id, index));
						replaceIndex(row, 'id', index);
						replaceIndex(row, 'for', index);
						index++;
					});
				}
				function focusCheck(row) {
					// I am no longer disabled
					if (row.hasClass('disabled')) {
						row.removeClass('disabled');
						hasDisabled = false;
					}
					
					// do we have a new temp field?
					if (!hasDisabled) {
						// create disabled
						var newRow = row.clone();
						newRow.addClass('disabled');
						//newRow.hide();
						container.append(newRow);
						// wire up the code
						newRow.find('input').focus(function() {
							focusCheck(newRow);
						});
						newRow.find('input').blur(function() {
							blurCheck(newRow);
						});
						// generate new automatic id
						reindex();
						//newRow.slideDown();
						hasDisabled = true;
					}
				}
				function blurCheck(row) {
					// any value in the inputs?
					var allEmpty = true;
					row.find('input').each(function() {
						if ($(this).val())
							allEmpty = false;
					});
					if (allEmpty) {
						//row.slideUp('fast', function() {
							row.remove();
							reindex();
						//});
					}
				}
				container.children().each(function() {
					var row = $(this);
					$(this).find('input').focus(function() {
						focusCheck(row);
					});
					$(this).find('input').blur(function() {
						blurCheck(row);
					});
				});
			});
		},
		// autotable checkbox and radio aren't supported as they don't have a 'null' state.
		// Only selects with an option that has a value of "" are supported
		autoTable: function(options) {
			var defaults = {
				//	are we going to automatically add rows?
				autoRows: true,
				//	are we going to automatically add columns?
				autoCols: true,
				// if a row or column is empty we nuke it
				autoRemove: true,
				// what things to listen to, .val() check is run on these - not ideal but works
				listenSelector: 'input:not(:checkbox, :radio, :hidden), textarea, select',
				// elements that will be named, one per td
				namingSelector: 'input, textarea, select',
				disabledClass: 'disabled',
				// cell element
				cellElement: 'td',
				// row element
				rowElement: 'tr'
			};
			options = $.extend(true, {}, defaults, options);
			this.each(function() {
				var topContainer = $(this);
				// we are at the container for the list of items,
				// there has to be at least one item already here,
				// but there may be more than one
				function reindex(container) {
					var rowindex = 1;
					container.find(options.rowElement).each(function() {
						var colindex = 1;
						$(this).find(options.cellElement).each(function() {
							$(this).find(options.namingSelector).attr('name', topContainer.attr('id') + 'r' + rowindex + 'c' + colindex);
							colindex++;
						});
						// remove the names of disabled inputs (they are just ther as helpers
						$(this).find(options.cellElement + '.' + options.disabledClass + ' ' + options.namingSelector).removeAttr('name');
						rowindex++;
					});
				}
				function getPosition(td) {
					var tr = td.parent();
					var col = tr.children().index(td);
					var row = tr.parent().children().index(tr);
					return {
						col: col,
						row: row
					};
				}
				function getBounds(container) {
					var tr = container.find(options.rowElement);
					var td = tr.first().find(options.cellElement);
					return {
						cols: td.size(),
						rows: tr.size()
					};
				}
				function focusCheck(input) {
					var td = input.parents(options.cellElement);
					var tr = td.parent();
					var trContainer = tr.parent();
					var pos = getPosition(td);
					var bounds = getBounds(trContainer);
					//alert(
					//	'focus row:' + pos.row + '/' + bounds.rows
					//	+ ' col:' + pos.col + '/' + bounds.cols);
					if (td.hasClass(options.disabledClass)) {
						if (pos.row == bounds.rows - 1 && options.autoRows) {
							// create new row
							var newtr = tr.clone();
							trContainer.append(newtr);
							newtr.find(options.cellElement).addClass(options.disabledClass);
							wireInput(newtr.find(options.listenSelector));
							var tds = tr.find(options.cellElement);
							if (options.autoCols)
								tds = tds.slice(0, -1);
							tds.removeClass(options.disabledClass);
						}
						if (pos.col == bounds.cols - 1 && options.autoCols) {
							// foreach row add a td (and wire it up)
							trContainer.children().each(function() {
								var newtd = td.clone();
								$(this).append(newtd);
								newtd.addClass(options.disabledClass);
								wireInput(newtd.find(options.listenSelector));
							});
							tds = trContainer.find(options.rowElement).find(options.cellElement + ':eq(' + pos.col + ')');
							if (options.autoRows)
								tds = tds.slice(0, -1);
							tds.removeClass(options.disabledClass);
						}
						reindex(trContainer);
					}
				}
				function blurCheck(input) {
					var td = input.parents(options.cellElement);
					var tr = td.parent();
					var trContainer = tr.parent();
					var pos = getPosition(td);
					var rowEmpty = true;
					tr.find(options.listenSelector).each(function() {
						if ($(this).val())
							rowEmpty = false;
					});
					if (rowEmpty && options.autoRows && options.autoRemove)
						tr.remove();
					var colEmpty = true
					var columntd = trContainer.find(options.rowElement).find(options.cellElement + ':eq(' + pos.col + ')');
					columntd.find(options.listenSelector).each(function() {
						if ($(this).val())
							colEmpty = false;
					});
					if (colEmpty && options.autoCols && options.autoRemove)
						columntd.remove();
					if (options.autoRemove && ((rowEmpty && options.autoRows) || (colEmpty && options.autoCols))) {
						reindex(trContainer);
					}
				}
				function wireInput(input) {
					input.focus(function() {
						focusCheck($(this));
					});
					input.blur(function() {
						blurCheck($(this));
					});
				}
				wireInput($(this).find(options.listenSelector));
				reindex($(this));
			});
		},
		autoSizeTextArea: function() {
			this.bind('keypress input beforepaste', function() {
				var lines = $(this).val().split('\n');
				var count = lines.length;
				var cols = $(this).attr('cols');
				$.each(lines, function() {
					count += parseInt(this.length / cols); 
				});
				$(this).attr('rows', count);
			});
			this.keypress();
		}
	});
})(jQuery);

String.prototype.toTitleCase = function() {
    return this.replace(/([\w&`'‘’"“.@:\/\{\(\[<>_]+-? *)/g, function(match, p1, index, title) {
        if (index > 0 && title.charAt(index - 2) !== ":" &&
        	match.search(/^(a(nd?|s|t)?|b(ut|y)|en|for|i[fn]|o[fnr]|t(he|o)|vs?\.?|via)[ \-]/i) > -1)
            return match.toLowerCase();
        if (title.substring(index - 1, index + 1).search(/['"_{(\[]/) > -1)
            return match.charAt(0) + match.charAt(1).toUpperCase() + match.substr(2);
        if (match.substr(1).search(/[A-Z]+|&|[\w]+[._][\w]+/) > -1 || 
        	title.substring(index - 1, index + 1).search(/[\])}]/) > -1)
            return match;
        return match.charAt(0).toUpperCase() + match.substr(1);
    });
};

// http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
function S4()   { return (((1+Math.random())*0x10000)|0).toString(16).substring(1); }
function guid() { return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()); }