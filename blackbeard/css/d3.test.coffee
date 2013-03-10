data = [
	{ Name: 'Bob', Measurement: new Measurement 0.1, 0.2, 0.5, 0.4 }
	{ Name: 'Maggie', Measurement: new Measurement 0.2, 0.1, 0.3, 0.3 }
	{ Name: 'Steven', Measurement: new Measurement 1, 1, 0, 1 }
	{ Name: 'Dreyfus', Measurement: new Measurement 0.4, 0.1, 0.3, 0.4 }
	{ Name: 'Edward', Measurement: new Measurement 0.3, 0.3, 0.1, 0.2 }
	{ Name: 'Fiona', Measurement: new Measurement 0.2, 0.5, 0.5, 0.1 }
	{ Name: 'Garry', Measurement: new Measurement 0.1, 0.3, 0.4, 0.2 }
	{ Name: 'Hayden', Measurement: new Measurement 0.2, 0.2, 0.3, 0.1 }
	{ Name: 'Tim', Measurement: new Measurement 0.3, 0.3, 0.2, 0.1 }
	{ Name: 'Jane', Measurement: new Measurement 0.4, 0.2, 0.1, 0.1 }
	{ Name: 'Ken', Measurement: new Measurement 0.5, 0.5, 0.4, 0.1 }
	{ Name: 'Liam', Measurement: new Measurement 0.1, 0.1, 0.1, 0.1 }
	{ Name: 'Mirriam', Measurement: new Measurement 0.3, 0.0, 0.2, 0.1 }
]

data.sort (a, b) -> a.Measurement.total() - b.Measurement.total()


# DOM Ready
# ---------
# Once the DOM has loaded let knockout do it's stuff.
$ ->
	ko.applyBindings inject.one 'App'

	margin =
		top: 20
		right: 20
		bottom: 30
		left: 100
	width = 540 - margin.left - margin.right
	height = 500 - margin.top - margin.bottom

	x = d3.scale.linear()
		.range([0, width])

	y = d3.scale.ordinal()
		.rangeRoundBands([height, 0], .1)

	yAxis = d3.svg.axis()
		.scale(y)
		.orient('left')

	svg = d3.select("body")
		.append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

	x.domain([0, d3.max(data, (d) -> d.Measurement.total() )])
	y.domain(data.map((d) -> d.Name ));

	measurement = svg.selectAll(".bar")
		.data(data)
		.enter()
		.append("g")

	measurement
		.append("rect")
		.attr("class", "skill")
		.attr("x", (d) -> 0 )
		.attr("width", (d) -> x(
			d.Measurement.Skill()))
		.attr("y", (d) -> y(d.Name) )
		.attr("height", y.rangeBand())

	measurement
		.append("rect")
		.attr("class", "output")
		.attr("x", (d) -> x(
			d.Measurement.Skill()) )
		.attr("width", (d) -> x(
			d.Measurement.Skill() + d.Measurement.Output()))
		.attr("y", (d) -> y(d.Name) )
		.attr("height", y.rangeBand())

	measurement
		.append("rect")
		.attr("class", "group")
		.attr("x", (d) -> x(
			d.Measurement.Skill() + d.Measurement.Output()) )
		.attr("width", (d) -> x(
			d.Measurement.Skill() + d.Measurement.Output() + d.Measurement.Group()))
		.attr("y", (d) -> y(d.Name) )
		.attr("height", y.rangeBand())

	measurement
		.append("rect")
		.attr("class", "delivery")
		.attr("x", (d) -> x(
			d.Measurement.Skill() + d.Measurement.Output() + d.Measurement.Group()) )
		.attr("width", (d) -> x(
			d.Measurement.Skill() + d.Measurement.Output() + d.Measurement.Group() + d.Measurement.Delivery()))
		.attr("y", (d) -> y(d.Name) )
		.attr("height", y.rangeBand())

	measurement
		.append("text")
		.attr("class", "name")
		.attr("y", (d) -> y(d.Name) )
		.attr("dy", 20 )
		.attr("dx", -8 )
		.style("text-anchor", "end")
		.text((d) -> d.Name)