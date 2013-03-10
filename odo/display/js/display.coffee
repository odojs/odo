$ ->
  $filter = $ '.pagefilter'
  $pages = _($ '.pagemenu li:not(.nav-header)').map (el) ->
    $el: $ el
    text: $(el).find('a').text()
  
  $filter.keyup ->
    val = $filter.val()
    
    _($pages).each (page) ->
      if !val? or page.text.caseInsensitiveContains val
        page.$el.show()
      else
        page.$el.hide()
    
  $pagelinks = $ '.pagemenu a'
  $page = $ '.page'
  
  $pagelinks.click (e) ->
    e.preventDefault()
    $this = $ this
    $.get $this.attr('href'), (data) ->
      $page.html (new Showdown.converter()).makeHtml data.contents