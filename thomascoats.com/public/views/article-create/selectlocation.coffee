define ['knockout', 'articles'], (ko, ArticleLogic) ->
	class SelectLocation
		constructor: ->
			@articlename = ko.observable ''
			@areas = ko.observableArray []
			@selectedIndex = ko.observable 0
			
		activate: (options) =>
			{ @wizard, @dialog, activationData } = options
			@articlename activationData
			
			new ArticleLogic().getAreasForAutocomplete().then (areas) =>
				for area in areas
					@areas.push area
			
		up: =>
			index = @selectedIndex()
			index--
			if index < 0
				index = @areas().length - 1
			@selectedIndex index
			
		down: =>
			index = @selectedIndex()
			index++
			index = index % @areas().length
			@selectedIndex index
			
		close: =>
			@dialog.close()
		
		submit: =>
			@selectArea @areas()[@selectedIndex()]
			
		selectArea: (area) =>
			options = {
				model: 'views/article-create/reviewarticle'
				activationData: {
					name: @articlename()
					area: area
				}
			}
			@wizard.forward(options)()