
Typeselect = (element, options) ->
  @$element = $ element
  @options = $.extend({}, $.fn.typeselect.defaults, options)
  @matcher = @options.matcher || @matcher
  @sorter = @options.sorter || @sorter
  @highlighter = @options.highlighter || @highlighter
  @updater = @options.updater || @updater
  @source = @options.sources || @options.source
  @$menu = $ @options.menu
  @shown = false
  @$element.attr 'autocomplete', 'off'
  @listen()

Typeselect.prototype = {

  constructor: Typeselect

  select: () ->
    val = @$menu.find('.active').attr('data-value')
    @$element
      .val(@updater(val))
      .change()
    @hide()

  updater: (item) ->
    item

  show: () ->
    pos = $.extend({}, @$element.position(), {
      height: @$element[0].offsetHeight
    })

    @$menu
      .insertAfter(@$element)
      .css({
        top: pos.top + pos.height
        left: pos.left
      })
      .show()

    @shown = true
    @

  hide: () ->
    @$menu.hide()
    @shown = false
    @

  lookup: (event) ->
    @query = @$element.val()
    @$menu.empty()

    if !@query || @query.length < @options.minLength
      return if @shown then @hide() else @

    items = null

    #console.log @source()
    
    items = @source

    if $.isFunction items
      items = items @query

    if !Array.isArray(items) and typeof items is 'object'
      @process items
      return @

    if items?
      @process {
        '': items
      }

  process: (source) ->
    that = @

    lists = for header, items of source
      if $.isFunction items
        items = items @query
      items = $.grep items, (item) ->
        that.matcher item
      items = @sorter items
      continue if !items.length
      @render header, items.slice 0, @options.items

    if !lists.length
      return if @shown then @hide() else @

    @$menu.find('li:not(.nav-header)').first().addClass 'active'

    list.show() for list in lists
    @

  matcher: (item) ->
    return ~item.toLowerCase().indexOf @query.toLowerCase()

  sorter: (items) ->
    beginswith = []
    caseSensitive = []
    caseInsensitive = []
    item

    while (item = items.shift())
      if !item.toLowerCase().indexOf @query.toLowerCase()
        beginswith.push item
      else if ~item.indexOf @query
        caseSensitive.push item
      else
        caseInsensitive.push item

    beginswith.concat caseSensitive, caseInsensitive

  highlighter: (item) ->
    query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
    item.replace new RegExp('(' + query + ')', 'ig'), ($1, match) ->
      '<strong>' + match + '</strong>'

  render: (header, items) ->
    that = @

    items = items.map (item) ->
      result = $(that.options.item).attr 'data-value', item
      result.find('a').html that.highlighter item
      return result[0]

    if header?
      items.unshift $(that.options.header).attr('data-value', header).text(header)[0]

    items = $ items

    @$menu.append items
    @

  next: (event) ->
    active = @$menu.find('.active').removeClass('active')
    next = active.next()

    if next.length and next.is '.nav-header'
      next = next.next()

    if !next.length
      next = $(@$menu.find('li:not(.nav-header)')[0])

    next.addClass('active')

  prev: (event) ->
    active = @$menu.find('.active').removeClass('active')
    prev = active.prev()

    if prev.length and prev.is '.nav-header'
      prev = prev.prev()

    if !prev.length
      prev = @$menu.find('li').last()

    prev.addClass('active')

  listen: () ->
    @$element.on 'blur', $.proxy @blur, @
    @$element.on 'keypress', $.proxy @keypress, @
    @$element.on 'keyup', $.proxy @keyup, @

    if @eventSupported('keydown')
      @$element.on 'keydown', $.proxy @keydown, @

    @$menu.on 'click', $.proxy(@click, @)
    @$menu.on 'mouseenter', 'li', $.proxy @mouseenter, @

  eventSupported: (eventName) ->
    isSupported = eventName in @$element
    if !isSupported
      @$element.attr eventName, 'return;'
      isSupported = (typeof @$element[eventName] is 'function')
    isSupported

  move: (e) ->
    return if !@shown

    switch e.keyCode
      when 9 # tab
        e.preventDefault()
        break
      when 13 # enter
        e.preventDefault()
        break
      when 27 # escape
        e.preventDefault()
        break

      when 38 # up arrow
        e.preventDefault()
        @prev()
        break

      when 40 # down arrow
        e.preventDefault()
        @next()
        break

    e.stopPropagation()

  keydown: (e) ->
    @suppressKeyPressRepeat = ~$.inArray e.keyCode, [40,38,9,13,27]
    @move(e)

  keypress: (e) ->
    return if @suppressKeyPressRepeat
    @move(e)

  keyup: (e) ->
    switch e.keyCode
      when 40 # down arrow
        break
      when 38 # up arrow
        break
      when 16 # shift
        break
      when 17 # ctrl
        break
      when 18 # alt
        break

      when 9 # tab
        return if !@shown
        @select()
        break
      when 13 # enter
        return if !@shown
        @select()
        break

      when 27 # escape
        return if !@shown
        @hide()
        break

      else
        @lookup()

    e.stopPropagation()
    e.preventDefault()

  blur: (e) ->
    that = this
    setTimeout (() -> that.hide()), 150

  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @select()

  mouseenter: (e) ->
    @$menu.find('.active').removeClass('active')
    $(e.currentTarget).addClass('active')
}


# TYPESELECT PLUGIN DEFINITION
old = $.fn.typeselect

$.fn.typeselect = (option) ->
  @each () ->
    $this = $ this
    data = $this.data('typeselect')
    options = typeof option is 'object' && option
    if !data
      $this.data 'typeselect', (data = new Typeselect(this, options))
    if typeof option is 'string'
      data[option]()

$.fn.typeselect.defaults = {
  source: []
  items: 5
  menu: '<ul class="typeselect dropdown-menu nav nav-list"></ul>'
  header: '<li class="nav-header"></li>'
  item: '<li><a href="#"></a></li>'
  minLength: 1
}

$.fn.typeselect.Constructor = Typeselect


# TYPESELECT NO CONFLICT
$.fn.typeselect.noConflict = () ->
  $.fn.typeselect = old
  @


# TYPESELECT DATA-API
$(document).on('focus.typeselect.data-api', '[data-provide="typeselect"]', (e) ->
  $this = $ this
  return if $this.data('typeselect')
  e.preventDefault()
  $this.typeselect $this.data()
)