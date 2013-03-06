class Measurement
	constructor: (name = 'default', skill = 0.05, output = 0.05, group = 0.05, delivery = 0.05) ->
		@Name = ko.observable name
		@Skill = ko.observable skill
		@Output = ko.observable output
		@Group = ko.observable group
		@Delivery = ko.observable delivery

	total: ->
		@Skill() + @Output() + @Group() + @Delivery()

class App
	constructor: () ->
		@Measurements = ko.observableArray()
		@SortedMeasurements = ko.dependentObservable (() ->
		    @Measurements.slice().sort (a, b) -> b.total() - a.total()), @

	addMeasurement: (measurement) ->
		@Measurements.push measurement
		@

$ ->
	app = new App
	app.addMeasurement new Measurement 'Bob', 0.1, 0.2, 0.5, 0.4
	app.addMeasurement new Measurement 'Maggie', 0.2, 0.1, 0.3, 0.3
	app.addMeasurement new Measurement 'Steven', 1, 1, 0, 1
	app.addMeasurement new Measurement 'Dreyfus', 0.4, 0.1, 0.3, 0.4
	app.addMeasurement new Measurement 'Edward', 0.3, 0.3, 0.1, 0.2
	app.addMeasurement new Measurement 'Fiona', 0.0, 0.0, 0.0, 0.0
	app.addMeasurement new Measurement 'Garry', .1, 0.3, 0.4, 0.2
	app.addMeasurement new Measurement 'Hayden', 0.2, 0.2, 0.3, 0.1
	app.addMeasurement new Measurement 'Tim', 0.3, 0.3, 0.2, 0.1
	app.addMeasurement new Measurement 'Jane', 0.4, 0.2, 0.1, 0.1
	app.addMeasurement new Measurement 'Ken', 0.5, 0.5, 0.4, 0.1
	app.addMeasurement new Measurement 'Liam', 0.1, 0.1, 0.1, 0.1
	app.addMeasurement new Measurement 'Mirriam', 0.3, 0.0, 0.2, 0.1

	ko.applyBindings app



	window.app = app
	window.Measurement = Measurement