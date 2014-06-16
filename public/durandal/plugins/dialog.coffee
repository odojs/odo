define [
	'knockout'
	'jquery'
	'plugins/dialog'
	'plugins/router'
], (ko, $, dialog, router) ->
	dialog.addContext 'OdoDialog',
		compositionComplete: (child, parent, context) ->
			$child = $ child
			
			options =
				backdrop: 'static'
			
			theDialog = dialog.getDialog context.model
			$host = $ theDialog.host
			$host.modal options
			$('body').scrollTop 0
			
			# rebuild autofocus functionality - bootstrap messes with it
			$host.one 'shown.bs.modal', ->
				$child.find('[autofocus],.autofocus').first().focus()
			
			# in practice we use a dialog component so this doesn't work -- probably should rethink how this works
			if $child.hasClass 'autoclose'
				$host.one 'shown.bs.modal', ->
					$host.one 'click.dismiss.modal', ->
						theDialog.close()
			
		
		addHost: (theDialog) ->
			body = $ 'body'
			host = $('<div class="modal fade" id="odo-modal" tabindex="-1" role="dialog" aria-hidden="true">')
				.appendTo(body)
			theDialog.host = host.get 0
			if router.disable?
				router.disable()
		
		removeHost: (theDialog) ->
			$(theDialog.host)
				.one('hidden.bs.modal', ->
					ko.removeNode theDialog.host
					if router.enable?
						router.enable()
				)
				.modal 'hide'