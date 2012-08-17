util = require('util')

log = (msg) ->

	console.log """

		*******************************************************
			#{msg}
		*******************************************************

	"""

desc 'Builds the application to /extension'
task 'default', (params) ->	

	jake.rmRf "src/app/javascripts/build"

	log "Building And Ugliying JavaScripts"

	jake.exec "r.js -o src/app/javascripts/app.build.js", () -> 

		log "Copying Styles Folder"

		jake.cpR "src/app/styles", "extension/app/styles"

		log "Copying Index"

		jake.cpR "src/app/index.html", "extension/app/index.html"

		log "FINISHED!"

	, { printStdout: true }

	