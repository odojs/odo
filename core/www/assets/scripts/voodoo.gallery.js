(function($){
    $.gallery = function(options, target) {
        this.options = $.extend(true, {}, $.gallery.defaults, options);
        this.target = target;
        this.init();
    };
    
    $.extend($.gallery, {
        defaults: {
            imageClass: 'image',
            descriptionClass: 'description',
            selectedClass: 'selected',
            selectedStyle: {
                width: '400px',
                height: '300px',
                'margin-top': '-150px',
                'margin-left': '-200px'
            },
            unselectedStyle: {
                width: '40px',
                height: '30px',
                'margin-top': '-15px',
                'margin-left': '-20px'
            },
            descriptionStyle: {
                'margin-left': '-200px'
            },
            delay: 400,
            style: 'diagonalLine'
        },
        prototype: {
            init: function() {
                var gallery = this;
                this.target.height('300px');
                this.target.show();
                //this.position = this['diagonalLine'];
                document.onkeyup = function(e) {
                    // left
                    if (e.keyCode == 37)
                        gallery.prev();
                    // right
                    else if (e.keyCode == 39)
                        gallery.next();
                };
                this.items = [];
                var index = 0;
                this.target.children().each(function() {
                    var image = $(this).children('.' + gallery.options.imageClass);
                    var imageLink = image.wrap('<a href="#" />');
                    var item = {
                        index: index,
                        target: $(this),
                        image: image,
                        description: $(this).children('.' + gallery.options.descriptionClass)
                    };
                    gallery.items.push(item);
                    if ($(this).hasClass(gallery.options.selectedClass)) {
                        gallery.selectedItem = item;
                        item.image.css(gallery.options.selectedStyle);
                    }
                    else {
                        item.image.css(gallery.options.unselectedStyle);
                        item.description.hide();
                    }
                    
                    imageLink.click(function() {
                        gallery.select(item);
                        return false;
                    });
                    
                    item.description.css(gallery.options.descriptionStyle);
                    item.target.css({position: 'absolute'}, gallery.options.delay);
                    index++;
                });
                
                var selectedIndex = this.selectedItem.index;
                $.each(this.items, function(key, item) {
                    item.target.css(gallery.position(item), gallery.options.delay);
                });
            },
            position: function(item) {
                return this[this.options.style](item);
            },
            simpleLine: function(item) {
                var xoffset = 0;
                var yoffset = 0;
                
                var difference = item.index - this.selectedItem.index;
                var position = Math.max(Math.min(difference, 1), -1);
                
                
                // width of thumb + 10
                xoffset = difference * 50;
                //xoffset = position * 50;
                
                // push out a bit more for the selected image (width of selected / 2 - width of thumb / 2)
                if (xoffset > 0)
                    xoffset += 180;
                else if (xoffset < 0)
                    xoffset -= 180;
                
                return {
                    top: (150 + yoffset) + 'px',
                    left: (200 + xoffset) + 'px'
                };
            },
            diagonalLine: function(item) {
                var xoffset = 0;
                var yoffset = 0;
                
                var difference = item.index - this.selectedItem.index;
                var position = Math.max(Math.min(difference, 1), -1);
                
                
                // width of thumb + 10
                xoffset = difference * 50;
                //xoffset = position * 50;
                
                // push out a bit more for the selected image (width of selected / 2 - width of thumb / 2)
                if (xoffset > 0)
                    xoffset += 180;
                else if (xoffset < 0)
                    xoffset -= 180;
                
                var yoffset = Math.abs(difference) * 40;
                
                return {
                    top: (150 + yoffset) + 'px',
                    left: (200 + xoffset) + 'px'
                };
            },
            bottomBox: function(item) {
                var xoffset = 0;
                var yoffset = 0;
                
                var difference = item.index - this.selectedItem.index;
                var position = Math.max(Math.min(difference, 1), -1);
                
                
                // width of thumb + 10
                //xoffset = difference * 50;
                xoffset = position * 50;
                
                // push out a bit more for the selected image (width of selected / 2 - width of thumb / 2)
                if (xoffset > 0)
                    xoffset += 180;
                else if (xoffset < 0)
                    xoffset -= 180;
                
                var yoffset = Math.abs(difference) * 40;
                
                return {
                    top: (150 + yoffset) + 'px',
                    left: (200 + xoffset) + 'px'
                };
            },
            box: function(item) {
                var xoffset = 0;
                var yoffset = 0;
                
                var difference = item.index - this.selectedItem.index;
                var position = Math.max(Math.min(difference, 1), -1);
                
                
                // width of thumb + 10
                //xoffset = difference * 50;
                xoffset = position * 40;
                
                // push out a bit more for the selected image (width of selected / 2 - width of thumb / 2)
                if (xoffset > 0)
                    xoffset += 180;
                else if (xoffset < 0)
                    xoffset -= 180;
                
                var yoffset = Math.abs(difference) * 30 - Math.abs(position) * 165;
                
                return {
                    top: (150 + yoffset) + 'px',
                    left: (200 + xoffset) + 'px'
                };
            },
            select: function(item) {
                var gallery = this;
                $.each(this.items, function(key, item) {
                    item.target.removeClass(gallery.options.selectedClass);
                });
                this.selectedItem = item;
                item.target.addClass(gallery.options.selectedClass);
                this.animateAll();
            },
            animateAll: function() {
                var gallery = this;
                var selectedIndex = this.selectedItem.index;
                $.each(this.items, function(key, item) {
                    item.image.stop();
                    if (item == gallery.selectedItem) {
                        item.image.animate(gallery.options.selectedStyle, gallery.options.delay, function() {
                            item.description.stop();
                            item.description.fadeIn(gallery.options.delay);
                        });
                    }
                    else {
                        item.image.animate(gallery.options.unselectedStyle, gallery.options.delay);
                        item.description.stop();
                        item.description.hide();
                    }
                    item.target.stop();
                    item.target.animate(gallery.position(item), gallery.options.delay);
                });
            },
            prev: function() {
                var prevIndex = (this.items.length + this.selectedItem.index - 1) % this.items.length;
                this.select(this.items[prevIndex]);
            },
            next: function() {
                var nextIndex = (this.selectedItem.index + 1) % this.items.length;
                this.select(this.items[nextIndex]);
            }
        }
    });
    
    $.fn.gallery = function(options) {
        var results = [];
        this.each(function() {
            // check if a gallery for this element was already created
            var gallery = $.data(this, 'gallery');
            if (gallery) {
                if (options) {
                    // update options
                    gallery.options = $.extend(true, {}, gallery.options, options);
                    gallery.animateAll();
                }
                results.push(gallery);
            }
            else {
                gallery = new $.gallery(options, $(this));
                $.data(this, 'gallery', gallery);
                results.push(gallery);
            }
        });
        
        return results;
    }
})(jQuery);