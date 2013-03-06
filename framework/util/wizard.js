/*
	Enlighten Wizard - display step by step processes

	Version: 1.0
	Author: Thomas Coats


	Features:

	1.	Simple linear steps:

		<div class="wizard">
			<div class="inner">
				<div class="pane">
					<h1>Step 1</h2>

					<button class="next">Next</button>
				</div>
				<div class="pane">
					<h1>Step 2</h2>

					<button class="next">Next</button>
					<button class="back">Back</button>upd
				</div>
				<div class="pane">
					<h1>Step 3</h2>

					<button class="prev">Back</button>
				</div>
			</div>
		</div>

	2.	Custom non-linear steps:

		<div class="wizard nonlinear">
			<div class="inner">
				<div class="pane">
					<h1>Menu</h2>

					<button href="settings" class="go">Settings</button>
					<button href="assign" class="go">Assign</button>
				</div>
				<div id="settings" class="pane">
					<h1>Settings</h2>

					<button class="cancel">Cancel</button>
				</div>
				<div id="assign" class="pane">
					<h1>Assign</h2>

					Name: <input type="text" />
					
					<button href="assigned" class="go">Assign</button>
					<button class="cancel">Cancel</button>
				</div>
				<div id="assigned" class="pane">
					<h1>Assign</h2>


					<button class="first">Back</button>
				</div>
			</div>
		</div>

	3.	Automatic binding of actions:
		
		class="next" - move to the next pane (if specified)
		class="prev" - move to the previous pane (if specified)
		class="first" - move to the first pane
		class="last" - move to the last pane
		class="cancel" - remove the current slide and move back to the previous slide
		class="go" - using the href of the element as the id of the pane to either move to or load as the next pane
		class="shake" - shake the wizard

		class="submit" - if you want to have the pane trigger validation (not defined in this file)

	4.	API functionality:
		
		$(selector).wizard().indexOf(pane)
		$(selector).wizard().clip()
		$(selector).wizard().append(pane)
		$(selector).wizard().go()
		$(selector).wizard().show(index, finished)
		$(selector).wizard().jump(index)
		$(selector).wizard().next()
		$(selector).wizard().prev()
		$(selector).wizard().first()
		$(selector).wizard().last()
		$(selector).wizard().cancel()
		$(selector).wizard().shake()



	Required CSS:

		.wizard,
		.wizard > .inner > .pane {
			padding: 0px;
			width: 760px;
			overflow: hidden;
		}

		.wizard > .inner {
			overflow: hidden;
			width: 9999px;
		}

		.wizard > .inner > .pane {
			padding: 0px;
			float: left;
		}
*/


(function ($) {
	$.wizard = function (options, target) {
		this.options = $.extend(true, {}, $.wizard.defaults, options);
		this.target = target;
		this.init();
	};

	$.wizard.count = 0;

	$.extend($.wizard, {
		defaults: {
			delay: 400,
			width: null, // width of target
			easing: 'swing',
			transitioned: function (pane) { },
			stack: null, // set this to an array of panes
			current: null, // set this to a pane,
			bind: true,
			trackHeight: true,
			trackDisabled: true,
			nonlinear: false
		},
		prototype: {
			init: function () {
				var wizard = this;
				if (!this.options.width)
					this.options.width = this.target.innerWidth();

				this.inner = this.target.children('.inner');

				this.inner.find('.pane').hide();

				// setup stack if it doesn't exist
				if (!this.options.stack) {
					this.options.stack = [];
					this.inner.find('.pane').each(function () {
						wizard.options.stack.push($(this));
					});
				}
				// setup current if it's not set
				if (!this.options.current)
					this.options.current = this.options.stack[0];

				// display the stack
				if (this.options.stack)
					$.each(this.options.stack, function () {
						this.detach();
						this.appendTo(wizard.inner).show();
					});

				if (this.options.bind) {
					this.target.find('.next').click(function (e) {
						e.preventDefault();
						wizard.next();
					});
					this.target.find('.prev').click(function (e) {
						e.preventDefault();
						wizard.prev();
					});
					this.target.find('.first').click(function (e) {
						e.preventDefault();
						wizard.first();
					});
					this.target.find('.last').click(function (e) {
						e.preventDefault();
						wizard.last();
					});
					this.target.find('.cancel').click(function (e) {
						e.preventDefault();
						wizard.cancel();
					});
					this.target.find('.clip').click(function (e) {
						e.preventDefault();
						wizard.go($($(this).attr('href')));
					});
					this.target.find('.go').click(function (e) {
						e.preventDefault();
						wizard.move($($(this).attr('href')));
					});
					this.target.find('.shake').click(function (e) {
						e.preventDefault();
						wizard.shake();
					});
				}

				// go to current
				this.jump(this.indexOf(this.options.current));

				this.focus();
			},
			indexOf: function (pane) {
				for (var i = 0; i < this.options.stack.length; i++)
					if (this.options.stack[i].get(0) == pane.get(0))
						return i;
				return -1;
			},
			clip: function () {
				// remove all items on the stack after the current index
				while (this.options.stack.length > this.index + 1) {
					// gone forever
					this.options.stack.pop().hide();
				}

				return this;
			},
			append: function (pane) {
				var wizard = this;

				if (pane instanceof Array) {
					$.each(pane, function () {
						wizard.append(this);
					});
					return this;
				}

				wizard.options.stack.push(pane);
				pane.detach();
				pane.appendTo(wizard.inner).show();

				return this;
			},
			go: function (pane, f) {

				var index = this.indexOf(pane);
				var wizard = this;
				// existing pane
				if (index != -1) {
					this.show(index, function (pane) {
						wizard.clip();
						if (f) f();
					});
					return this;
				}

				// we are displaying a new pane
				this.clip();
				this.append(pane);
				this.next(f);

				return this;
			},
			move: function (pane, f) {

				var index = this.indexOf(pane);
				var wizard = this;
				// existing pane
				if (index != -1) {
					this.show(index, function (pane) {
						if (f) f();
					});
					return this;
				}
			},
			show: function (index, f) {

				//alert('show ' + this.index + ' -> ' + index);
				var wizard = this;
				var currentIndex = this.index;

				if (index == this.index) {
					if (f) f();
					return this;
				}

				// has to be in the list
				if (index < 0 || index >= this.options.stack.length)
					return;

				var goingForward = index > currentIndex;

				//Clear validation errors & help callouts
				if ($.fn.tiptip) {
					$.tiptip.hideAll('tiptip-validation-error');
					$.tiptip.hideAll('tiptip-help-callout');
				}
				$('.validation-summary-errors').hide();

				//Validate only if progressing forward in the stack
				if (goingForward) {
					if (!this.validatePane(currentIndex))
						return this;
				}

				// forward
				if (goingForward) {
					// fade everything
					$.each(this.options.stack, function () {
						this
							.show()
							.stop()
							.animate(
								{ 'opacity': 0 },
								wizard.options.delay / 2,
								wizard.options.easing)
							.removeClass('active-wizard-pane');
					});

					// show what we are moving to
					this.options.stack[index]
						.stop()
						.css({ 'opacity': 1 });
				}
				// backward
				else {
					// show current
					this.options.stack[currentIndex]
						.stop()
						.show()
						.css({ 'opacity': 1 });

					// fade in everything
					$.each(this.options.stack, function () {
						this
							.stop()
							.animate(
								{ 'opacity': 1 },
								wizard.options.delay,
								wizard.options.easing);
					});
				}

				this.index = index;

				// move our view to see the index
				this.inner
					.stop()
					.animate(
						{ 'margin-left': '-' + (this.options.width * this.index) + 'px' },
						wizard.options.delay,
						wizard.options.easing,
						function () {
							if (f) f();
							wizard.options.transitioned(wizard.options.stack[wizard.index]);
							wizard.options.stack[wizard.index].addClass('active-wizard-pane');
							wizard.focus();


						});

				wizard.updateDisabled();
				wizard.updateHeight(true);

				if (!wizard.target.hasClass('inline'))
					$(window).scrollTop(1);

				return this;
			},
			//focus on first form element
			focus: function () {
				var currentPane = this.options.stack[this.index];
				if (!currentPane)
					return this;
				var $firstInput = currentPane.find('input[type!=hidden]:first');

				if (!$firstInput.length)
					$firstInput = currentPane.find('textarea:first');
				if (!$firstInput.length)
					$firstInput = currentPane.find('select:first');
				if (!$firstInput.length)
					$firstInput = currentPane.find('button:first');

				if ($firstInput.length && $firstInput.is(':visible'))
					$firstInput.focus();

				return this;
			},
			validatePane: function (index) {
				if ($.fn.validate) {
					var $form = this.options.stack[index].find('form');
					if ($form.is('*')) {
						if (!$form.validate().form()) {
							this.shake();
							return false;
						}
					}
				} return true;
			},
			validateCurrentPane: function () {
				this.validatePane(this.index);
			},
			jump: function (index, callback) {
				// has to be in the list
				if (index < 0 || index >= this.options.stack.length)
					return;

				this.index = index;

				// show everything
				$.each(this.options.stack, function () {
					this.css({ 'opacity': 1 });
					this.removeClass('active-wizard-pane');
				});

				// move our view to see the index
				this.inner
					.stop()
					.css({ 'margin-left': '-' + (this.options.width * this.index) + 'px' });

				this.updateHeight(false);
				this.updateDisabled();

				this.options.transitioned(this.options.stack[this.index]);
				this.options.stack[this.index].addClass('active-wizard-pane');

				if (callback) callback();

				return this;
			},
			trackHeight: function (shouldTrack) {
				this.options.trackHeight = shouldTrack;
				if (!shouldTrack) {
					this.target.css('height', 'auto');
				}
				return this;
			},
			updateHeight: function (animate) {
				if (!this.options.trackHeight)
					return;

				var wizard = this;
				setTimeout(function () {
					if (!wizard.options.trackHeight || wizard.options.stack[wizard.index].is(':not(:visible)')) {
				    console.log('Not visible');
						return;
				  }
					var height = wizard.options.stack[wizard.index].outerHeight();
					wizard.target.children(':not(.inner):visible').each(function () {
						height += $(this).outerHeight();
					});
					wizard.target
						.stop()
						.animate({ 'height': height + 'px' }, animate ? wizard.options.delay : 0);					
					if (wizard.target.hasClass('guide')) {						
						var trigger = $('#viewfarmmodule');
						if (!trigger.length) trigger = $('#viewfeedwedgemodule');
						if(trigger) trigger.tooltip().updateHeight(height + 5);
					}
				}, 10);
				return this;
			},
			updateDisabled: function () {
				if (!this.options.trackDisabled)
					return;

				// disable everything
				this.inner.find('.pane').each(function () {
					$(this).find('input, select, button').each(function () {
						var $this = $(this);
						if ($this.attr('data-disabled') == null) {
							var isDisabled = $this.attr('disabled') ? true : false;
							$this.attr('data-disabled', isDisabled ? 'true' : 'false');
						}
						$this.attr('disabled', true);
					});
				});

				// enable the current pane
				this.options.stack[this.index].find('input, select, button').each(function () {
					var $this = $(this);
					var isDisabled = $this.attr('data-disabled') === 'true' ? true : false;
					if (!isDisabled)
						$this.removeAttr('disabled');
					$this.removeAttr('data-disabled');
				});
			},
			next: function (callback) {
				this.show(this.index + 1, callback);

				return this;
			},
			prev: function (callback) {
				this.show(this.index - 1, callback);
				if (this.options.nonlinear)
					this.clip();
				return this;
			},
			first: function (callback) {
				this.show(0, callback);

				return this;
			},
			last: function (callback) {
				this.show(this.options.stack.length - 1, callback);

				return this;
			},
			cancel: function () {
				var wizard = this;
				this.show(this.index - 1, function () {
					wizard.clip();
				});

				return this;
			},
			shake: function () {
				var wizard = this;
				wizard.target.stop();
				wizard.target
					.animate({ 'margin-left': '+=10px' }, 50)
					.animate({ 'margin-left': '-=20px' }, 100)
					.animate({ 'margin-left': '+=20px' }, 100)
					.animate({ 'margin-left': '-=20px' }, 100)
					.animate({ 'margin-left': '+=10px' }, 50, function () {
						wizard.target.css('margin-left', 'auto').stop();
					});
				return this;
			}
		}
	});

	$.fn.wizard = function (options, params) {
		var result;
		this.each(function () {
			// check if a wizard for this element was already created
			var wizard = $.data(this, 'wizard');
			if (wizard) {
				// shortcut to api call - next, prev etc.
				if (typeof options == 'string') {
					if (params)
						wizard[options](params);
					else
						wizard[options]();
				}
				result = wizard;
			}
			else {
				wizard = new $.wizard(options, $(this));
				$.data(this, 'wizard', wizard);
				result = wizard;
			}
		});
		return result;
	};
})(jQuery);