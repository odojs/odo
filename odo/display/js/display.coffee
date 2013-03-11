$ ->
  
  $filter = $ '.pagefilter'
  $pages = _($ '.pagemenu li:not(.nav-header)').map (el) ->
    $el = $ el
    $a = $el.find 'a'
    {
      $el: $ el
      section: $a.attr 'data-section'
      title: $a.attr 'data-title'
    }
  
  linkify = (converter) ->
    [
      type: 'output'
      filter: (source) ->
        window.markdown.linkify source
    ]
  
  linkifyWiki = (section, titles) ->
    (converter) ->
      [
        type: 'output'
        filter: (source) ->
          window.markdown.linkifyWiki source, titles, (url, text) ->
            "<a class=\"pagelink\" data-section=\"#{section}\" data-title=\"#{url}\" href=\"#{section}/#{url}\">#{url}</a>"
      ]
  
  $filter.on 'keyup change', ->
    val = $filter.val()
    
    _($pages).each (page) ->
      if !val? or page.title.caseInsensitiveContains val
        page.$el.show()
      else
        page.$el.hide()
  
  $(document).on 'click', 'a.pagelink', (e) ->
    e.preventDefault()
    $this = $ this
    section = $this.attr 'data-section'
    title = $this.attr 'data-title'
    url = "/fetch/pagecontents/bysectionandpage?section=#{section}&page=#{title}"
    $.get url, (data) ->
      converter = new Showdown.converter
        extensions: [
          linkify
          linkifyWiki section, _($pages)
            .filter((page) -> page.section is section)
            .map((page) -> page.title)
        ]
      $('.page').html converter.makeHtml data.contents
      $filter.val ''
      $filter.trigger 'change'
      window.scrollTo 0, 0