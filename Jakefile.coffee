util = require('util')
system = do ->
    try
        require('system')
    catch ex
        null

isWindows = /^win/.test(process.platform)

chromeCamDir = "chrome-cam"
buildDir = "build"
appBuildDir = "#{buildDir}/app"
chromeBuildDir = "#{buildDir}/chrome"
srcDir = "src"

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

    fatLog "Clearing old build directory"
    jake.rmRf buildDir

    # This may be a bug in jake, but there isn't a way to copy just the
    # contents of a folder (not the folder itself) if the directory you're
    # copying into already exists.
    fatLog "Copying Extension folder"
    jake.cpR "#{srcDir}/extension", "#{buildDir}"

    fatLog "Transpiling App CoffeeScript files"
    jake.exec "coffee -c -o #{appBuildDir}/staging/scripts #{srcDir}/app/scripts", ->

        jake.cpR "#{srcDir}/app/views", "#{appBuildDir}/staging/views"
        jake.cpR "#{srcDir}/common", "#{appBuildDir}/staging/common"

        fatLog "Building App module"
        requireCmd = unless isWindows then "r.js" else "r.js.cmd"
        jake.cpR "#{srcDir}/app/app.build.js", "#{appBuildDir}/staging/app.build.js"

        jake.exec "#{requireCmd} -o #{appBuildDir}/staging/app.build.js", () ->
            jake.mkdirP "#{appBuildDir}/scripts"
            jake.cpR "#{appBuildDir}/staging/build/scripts/main.js", "#{appBuildDir}/scripts/main.js"

            fatLog "Removing staging directory"
            jake.rmRf "#{appBuildDir}/staging"

            fatLog "Copying App Html files"
            jake.cpR "#{srcDir}/app/index.html", "#{appBuildDir}/index.html"

            fatLog "Copying Common dependencies for App"
            jake.cpR "#{srcDir}/common", "#{appBuildDir}/common"

            fatLog "Copying Libs for App"
            jake.cpR "#{srcDir}/app/libs", "#{appBuildDir}/libs"

            fatLog "Copying styles for App"
            jake.cpR "#{srcDir}/app/styles", "#{appBuildDir}/styles"
        , printStdout: true

    fatLog "Transpiling Chrome CoffeeScript files"
    jake.exec "coffee -c -o #{chromeBuildDir}/scripts #{srcDir}/chrome/scripts", ->

        fatLog "Copying Common dependencies for Chrome"
        jake.cpR "#{srcDir}/common", "#{chromeBuildDir}/common"

        fatLog "Copying Libs for Chrome"
        jake.cpR "#{srcDir}/chrome/libs", "#{chromeBuildDir}/libs"

        fatLog "Copying styles for App"
        jake.cpR "#{srcDir}/chrome/styles", "#{chromeBuildDir}/styles"