This is the repo for the Retail Ad Builder. This project programatically builds out ads via `rake build`.

## Getting started

Make sure you have all dependencies installed by running:

    bundle

### Development

Development consists of using Sinatra and Sprockets for building files. Simply boot up the server by running:

    rackup

And then navigating to http://localhost:9292/TYPE/SIZE where `TYPE` is any of these:

* general
* discovery
* leadership
* passion
* service
* general_alt
* leadership_alt
* passion_alt

and `SIZE` is any of these:

* 160x600
* 300x250
* 300x600
* 728x90

For example, if you wanted to see the general version of the 300x250 ad, you would go to http://localhost:9292/general/300x250.

#### The src folder

All development happens within the `src` folder. Templates live in this folder and assets live in the `src/assets` folder.

#### Scripts and Stylesheets

All css files must be placed into `src/assets/css` and all js files must be placed into `src/assets/js`.

    assets/
      css/
        base.css
        SIZE.css
      js/
        base.js
        SIZE.js

Each template loads in their corresponding stylesheet and script file (e.g. the "300x250" template would load "300x250.js" and "300x250.css"). Each stylesheet and script file loads in their "base" version that is applied to all templates. Any shared code would exist there, while the template-specific code would exist within the template file.

##### Custom-built jQuery

We're using a custom-built jQuery to save KBs. For reference, here are the flags we're currently building jQuery against:

    -ajax,-deprecated,-event,-offset,-wrap,-core/ready,-exports/amd

_[Go here](https://github.com/jquery/jquery#how-to-build-your-own-jquery) to read more about building a custom version of jQuery._

#### Image naming conventions

All of the images must be placed into `src/assets/images`. Each image must follow a special naming convention or they won't be included via the build script. There are three ways you can name an image:

    global_foo_bar.jpg
    300x250_foo_bar.jpg
    general_300x250_foo_bar.jpg

### global images

Images prefixed with `global_` will be included into EVERY ad. Make sure you only give this prefix to the images that MUST be in EVERY ad, or else you're wasting precious KBs.

### size images

Images prefixed with a size (e.g. `300x250_`) will be included into **every ad that has that size**. For example, if you had 3 versions of the 300x250 ad, they would all get that image. Use this if the image will be in every variation of the specific size ad.

### type and size images

Images prefixed with first a type (e.g. `general_`) _and then_ a size (e.g. `300x250_`) will be included into the single ad that has that type and the size. Use this if the image will not be in every variation of the specific size ad.


### Building for handoff

To build all of the ads, simply run `rake build`. If you only need to build specific ads, you can run the rake command with arguments.

    rake build[types,sizes]

Where "types" would be a _space-delimited_ string of types (e.g. "general discovery leadership") and "sizes" would be a _space-delimited_ string of sizes (e.g. "300x250 728x90").

Running the build task will start the server, gather the assets and place them in the `dist` folder, and then kill the server. After the task has been completed, you can zip up the `dist` folder and put it wherever you'd like.

