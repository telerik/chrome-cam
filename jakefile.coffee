util = require('util')

folder = "chrome-photo-booth"

log = (msg) ->

	console.log """

		*******************************************************
		#{msg}
		*******************************************************

	"""

desc 'Builds the application to /extension'
task 'default', (params) ->	

	log "Removing Build Folder"
	jake.rmRf folder

	log "Copying Extension Manifest, Background Scripts and Icons"
	jake.cpR "src/extension", folder

	log "Creating Build Directories If Necessary"

	jake.mkdirP "#{folder}/chrome/javascripts"
	jake.mkdirP "#{folder}/app/javascripts"

	log "Copying Styles Folders"

	jake.cpR "src/app/styles", "#{folder}/app"
	jake.cpR "src/chrome/styles", "#{folder}/chrome"

	log "Copying Index"

	jake.cpR "src/app/index.html", "#{folder}/app/index.html"

	log "Copying Chrome JavaScripts"

	jake.cpR "src/chrome/javascripts", "#{folder}/chrome"

	jake.exec "r.js -o src/app/javascripts/app.build.js", () -> 

		log "Copying App Scripts"

		jake.cpR "src/app/javascripts/build/main.js", "#{folder}/app/javascripts/main.js"
		jake.cpR "src/app/javascripts/build/require.js", "#{folder}/app/javascripts/require.js"
		jake.cpR "src/app/javascripts/build/jquery.min.js", "#{folder}/app/javascripts/jquery.min.js"
		jake.cpR "src/app/javascripts/build/kendo.all.min.js", "#{folder}/app/javascripts/kendo.all.min.js"

		log "FINISHED!"

	, { printStdout: true }

	
