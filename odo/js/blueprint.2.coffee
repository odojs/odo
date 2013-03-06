root = global ? (process ? this)
inject = root.inject


# Measurement
# -----------
# A measurement of performance. It's possible we can distill someone's effort into four measurements, skill, output, group contribution, and project contribution.
class Measurement
	inject.auto @

	# Let's set some defaults. These have been chosen to show a little peak of colour for affordance.
	constructor: (skill = 0.05, output = 0.05, group = 0.05, delivery = 0.05) ->
		@Skill = ko.observable skill
		@Output = ko.observable output
		@Group = ko.observable group
		@Delivery = ko.observable delivery

	clone: () ->
		result = new Measurement
		result.Skill @Skill()
		result.Output @Output()
		result.Group @Group()
		result.Delivery @Delivery()
		result

	total: ->
		@Skill() + @Output() + @Group() + @Delivery()

inject.bind('Measurement').to('Measurement').many()
inject.bind('ChangingMeasurement').to('Measurement').many()


# User
# ----
# 
class User
	inject.auto @

	constructor: (Measurement, name = 'default') ->
		@Measurement = ko.observable Measurement
		@Name = ko.observable name

inject.bind('User').to('User').many()

# App
# ---
# The entry point for our models. The contents of this class will move to something like 'MeasurementEditor' in the future.
class App
	inject.auto @

	# These constructor parameters need to match contracts in pminject
	constructor: () ->
		@Users = ko.observableArray()

inject.bind('App').to('App').single()


# DOM Ready
# ---------
# Once the DOM has loaded let knockout do it's stuff.
$ ->
	app = inject.one 'App'

	app.Users.push new User (inject.one 'Measurement'), 'Mary'
	app.Users.push new User (inject.one 'Measurement'), 'Sally'

	ko.applyBindings app