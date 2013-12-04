define ['jquery'], ($) ->
	emit: (event, payload) =>
		$.post("/eventstore/event/#{event}").then(() =>
			)