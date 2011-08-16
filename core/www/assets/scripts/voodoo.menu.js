(function($) {
    $.menu = function(items, target) {
        this.items = items;
        this.target = target;
        this.init();
    };

	$.extend($.menu, {
        defaults: {
        },
		prototype: {
			init: function() {
				// items is array of menu items
				var menu = this.buildMenu(this.items);
				this.target.append(menu);
			},

			menuAction: function(item, value) {
				if (value.items) {
					var menu = item.children('.menu');
					// hide an already visible menu
					if (menu.is(':visible')) {
						item.find('.menu').hide();
						return;
					}
					else {
						menu.show();
					}
				}
				if (value.action)
					value.action();
				if (value.href)
					location.href = value.href;
			},

			buildMenuItem: function(value) {
				var link = $(
					'<a href="#"><span>'
					+ '<span class="title">' + value.title + '</span>'
					+ '<span class="character"> (<span class="character-value">' + value.character.toUpperCase() + '</span>)</span>'
					+ '</span></a>');
				var item = $('<li></li>');
				item.append(link);
				var menu = this;
				link.bind('click', function() {
					menu.menuAction(item, value);
					return false;
				});
				return item;
			},

			buildMenu: function(items) {
				var menu = $('<ul class="menu" />');
				var container = this;
				// items is array of menu items
				$.each(items, function(key, value) {
					var item = container.buildMenuItem(value);
					menu.append(item);
					if (value.items) {
						container.buildMenu(value.items).appendTo(item).hide();
					}
					$(document).bind('keydown', function(e) {
                        var ob = e || event;
                        var keyCode = ob.keyCode;
                        var target = $(event.target);
                        if (keyCode != value.character.charCodeAt(0)
                                || !menu.is(':visible')
                                || target.is('input')
                                || target.is('textarea')
                                || target.is('select'))
                            return;
                        container.menuAction(item, value);
                        return false;
                    });
				});
				return menu;
			}
		}
	});

	$.fn.menu = function(items) {
        var results = [];
		this.each(function() {
            var menu = $.data(this, 'menu');
			if (menu) {
                // shortcut to api call - show, hide etc.
                if (typeof items == 'string') {
                    menu[items]();
					return;
                }
            }
            else {
                if (typeof options == 'string') {
                    // do nothing, an api call to a menu that doesn't exist yet
					return;
                }

                menu = new $.menu(items, $(this));
                $.data(this, 'menu', menu);
                results.push(menu);
            }
		});
	 	return results;
	}
})(jQuery);


