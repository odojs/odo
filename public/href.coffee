# Split up the href into
# "#{protocol}://#{subdomain}.#{rootdomain}#{url}"
define [], ->
	chunks = window.location.href.split '://'
	protocol = chunks[0]
	chunks = chunks.slice(1).join('').split '/'
	domain = chunks[0]
	url = '/' + chunks.slice(1).join '/'
	chunks = domain.split '.'
	subdomain = chunks[0]
	rootdomain = chunks.slice(1).join '.'
	
	protocol: protocol
	domain: domain
	url: url
	subdomain: subdomain
	rootdomain: rootdomain
