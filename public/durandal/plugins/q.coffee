define ['durandal/system', 'q'], (system, Q) ->
	# use Q promises internally in durandal
	system.defer = (action) ->
		dfd = Q.defer()
		action.call dfd, dfd
		promise = dfd.promise
		dfd.promise = ->
			promise

		dfd
	
	# a version of require that returns a promise immediately
	window.requireQ = (deps) ->
		dfd = Q.defer()
		requirejs deps, -> dfd.resolve arguments
		dfd.promise
	
	originalDefine = window.define
	# a version of define that waits until all deps have been required, and if they are promises waits for those as well
	window.defineQ = (name, deps, callback) ->
		
		method = (cb) ->
			->
				that = @
				dfd = Q.defer()
				args = Array::slice.call arguments, 0
				
				Q
					.all(args)
					.then (resolved) ->
						dfd.resolve cb.apply that, resolved
				
				dfd.promise
		
		# magical argument detection, needed so we know which argument is the callback, otherwise we would just .apply arguments
		
		if typeof name isnt 'string'
			if system.isArray name
				# defineQ(deps, callback)
				args = [name, method(deps)]
			else
				# defineQ(callback)
				args = [method(name)]
		
		else if !system.isArray deps
			# defineQ(name, callback)
			args = [name, method(deps)]
		
		else
			# defineQ(name, deps, callback)
			args = [name, deps, method(callback)]
		
		originalDefine.apply @, args
	
	# when durandal is looking for deps, make sure we are okay if they return promises instead of the actual module
	system.acquire = ->
		deps = undefined
		first = arguments[0]
		arrayRequest = false
		if system.isArray(first)
			deps = first
			arrayRequest = true
		else
			deps = Array::slice.call arguments, 0
		
		dfd = Q.defer()
		requirejs deps, ->
			Q.spread arguments, ->
				args = arguments
				setTimeout (->
					if args.length > 1 or arrayRequest
						dfd.resolve Array::slice.call args, 0
					else
						dfd.resolve args[0]
				), 1

		dfd.promise
	
	# can set module id on a promised object - it simply waits
	originalSetModuleId = system.setModuleId
	system.setModuleId = (obj, id) ->
		if system.isPromise obj
			obj.then (newObj) ->
				originalSetModuleId newObj, id
			return
		
		originalSetModuleId obj, id
