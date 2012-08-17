# Chrome PhotoBooth Application
A Chrome OS PhotoBooth Style Application

## Running The Application
In order to run this application, you will need the latest build of [Chrome Canary](https://tools.google.com/dlpage/chromesxs/ "Google Chrome - Get a fast new browser. For PC, Mac, and Linux").

1. Install the [App Launcher](https://chrome.google.com/webstore/detail/odmpalfplhaahlgnkkonchfhpegdcgjm "Chrome Web Store - App Launcher")

2. Navigate to 

    chrome://extensions

3. Check "Developer Mode"

4. Click "Load Unpacked Extension"

5. Navigate to where the "Extension" folder in this project is and select the whole folder

6. Launch the application with the App Launcher 

## Building The Application
The project is structured in two distinct areas.  The "src" directory holds all of the source code.  The "extension" directory holds all of the compiled code that runs in the extension.  Except for the background.js file and the manifest, you are largely expected to develop in the "src" folder.

### Install Node

1. Install [Node & NPM](http://nodejs.org/ "node.js")

### Install Necessary Node Modules

1. Install the CoffeeScript transpiler (Global)
	npm install -g coffee-script

2. Install Jitter for watching/transpiling files (Global)
    npm install -g jitter

3. Install RequireJS for building the src/app directory (Global)
    npm install -g requirejs

4. Install Jake for automated builds (Global)
    npm install -g jake

### Start Jitter

1. From the main chrome-photo-booth directory, tell jitter to watch the chrome directory and transpile to the extension directory
    jitter src/chrome/coffeescripts extension/chrome/javascripts

2. From the main chrome-photo-booth directory, tell jitter to watch the app directory and transpile to the app directory
    jitter src/app/coffeescripts src/app/javascripts

### Building With RequireJS
The application is modular and must be built with RequireJS optimizier in order to update the application in the extension.  The code will not work inside of the extension if it is not built first.  CSP in the extension will block the use of any external HTML files which will include all templates.

1. From the same directory as the jakefile.coffee file, run the following command
    jake

This will build the files and copy them to the correct location in the **extension** directory.

## Debugging
It is not necessary to build for the sake of debugging.  You can open up the **index.html** file in the src/app folder directly and develop against it.  When you are happy with your changes and want to see them in the extension, you will have to build.