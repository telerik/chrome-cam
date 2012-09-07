util = require('util')
system = do ->
	try
		require('system')
	catch ex
	    null

folder = "chrome-cam"
src = "src"
chrome = "#{src}/chrome/"
app = "#{src}/app/"

log = (msg) ->

	console.log msg

fatLog = (msg) ->

	console.log """

		*******************************************************
		#{msg}
		*******************************************************

	"""

desc 'Builds the application to /extension'
task 'default', (params) ->	

	fatLog "Removing Build Folder"
	jake.rmRf folder

	fatLog "Copying Extension Manifest, Background Scripts and Icons"
	jake.cpR "src/extension", folder

	fatLog "Creating Build Directories If Necessary"

	jake.mkdirP "#{folder}/chrome/javascripts"
	jake.mkdirP "#{folder}/app/javascripts"

	fatLog "Copying Styles Folders"

	jake.cpR "src/app/styles", "#{folder}/app"
	jake.cpR "src/chrome/styles", "#{folder}/chrome"

	fatLog "Copying Index"

	jake.cpR "src/app/index.html", "#{folder}/app/index.html"

	fatLog "Transpiling Chrome CoffeeScript Files"

	jake.exec "coffee -c -o #{chrome}javascripts #{chrome}coffeescripts", () ->

		fatLog "Copying Chrome JavaScripts"

		jake.cpR "src/chrome/javascripts", "#{folder}/chrome"

	fatLog "Transpiling App CoffeeScript Files"

	jake.exec "coffee -c -o #{app}javascripts #{app}coffeescripts", () ->

		jake.exec "r.js -o src/app/javascripts/app.build.js", () -> 

			fatLog "Copying App Scripts"

			jake.cpR "src/app/javascripts/build/main.js", "#{folder}/app/javascripts/main.js"
			jake.cpR "src/app/javascripts/build/require.js", "#{folder}/app/javascripts/require.js"
			jake.cpR "src/app/javascripts/build/jquery.min.js", "#{folder}/app/javascripts/jquery.min.js"
			jake.cpR "src/app/javascripts/build/kendo.all.min.js", "#{folder}/app/javascripts/kendo.all.min.js"

			fatLog "Building Extension"
			chromePath = (system && system.env.CHROME_BIN_PATH) || "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
			jake.exec "'#{chromePath}' --pack-extension=#{folder} --pack-extension-key=#{folder}.pem --no-message-box", () ->			
				fatLog "FINISHED!"
				# display a growl notification. this will fail pretty much everywhere
				# but my machine
				jake.exec "growlnotify Buildage -m 'Build Is Done Man'"

			, { printStdout: true }

		, { printStdout: true }



