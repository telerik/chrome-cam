util = require('util')

log = (msg) ->

	console.log """

		*******************************************************
		#{msg}
		*******************************************************

	"""

desc 'Builds the application to /extension'
task 'default', (params) ->	

	log "Removing Build Folder"
	jake.rmRf "build"

	log "Copying Extension Manifest, Background Scripts and Icons"
	jake.cpR "src/extension", "build"

	log "Creating Build Directories If Necessary"

	jake.mkdirP "build/chrome/javascripts"
	jake.mkdirP "build/app/javascripts"

	log "Copying Styles Folders"

	jake.cpR "src/app/styles", "build/app"
	jake.cpR "src/chrome/styles", "build/chrome"

	log "Copying Index"

	jake.cpR "src/app/index.html", "build/app/index.html"

	log "Copying Chrome JavaScripts"

	jake.cpR "src/chrome/javascripts", "build/chrome"

	jake.exec "r.js -o src/app/javascripts/app.build.js", () -> 

		log "Copying Build Folder Main, Require, jQuery and Kendo"

		jake.cpR "src/app/javascripts/build/main.js", "build/app/javascripts/main.js"
		jake.cpR "src/app/javascripts/build/require.js", "build/app/javascripts/require.js"
		jake.cpR "src/app/javascripts/build/jquery.min.js", "build/app/javascripts/jquery.min.js"
		jake.cpR "src/app/javascripts/build/kendo.all.min.js", "build/app/javascripts/kendo.all.min.js"

		log "FINISHED!"

	, { printStdout: true }

	
