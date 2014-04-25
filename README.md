# Ad Builder

Ad Builder helps you make your HTML5 ads, quickly. Do you enjoy managing 30 variations of an ad? Do you enjoy having to manually compress your files? Do you enjoy creating your own index files so clients can see your banners? I didn't think so. Ad Builder solves all of those problems. By using ruby to do all of the heavy lifting, you can make ads without breaking a sweat.

## Getting started

To start, you'll need to install all of the dependencies. We're currently using a combination of [Ruby](http://ruby-lang.org) for the back-end and [Node.js](http://nodejs.org) for front-end helpers. Please make sure you have those two packages installed first before diving in.

Once you have both Node and Ruby installed, begin by installing all of dependencies we need to run the server:

    bundle install

Afterwards, install all Node dependencies by running:

    npm install

Finally, you will need to install `gulp` as a global module so that we can use the `gulp` command:

    npm install -g gulp

### Development

Development consists of using gulp for file watching and Sinatra and Sprockets for building files. Simply boot up the server and local environment by running:

    gulp watch -p PROJECT_DIR

The `PROJECT_DIR` would be the your project directory that you'd like to load into the Ad Builder. A project directory exists in the `src/` folder. Since Ad Builder only supports one project at a time, you'll have to reboot your server to switch projects. You can stop the server at any time by pressing <kbd>Ctrl</kbd> + <kbd>C</kbd>.

> **Protip:** If you need help with running the `gulp` tasks, try running `gulp help`.

## The src folder

All development happens within the `src` folder, which isn't tracked by this git repo. Ad Builder assumes a lot of things in your `src` folder:

* Each project is a subdirectory (e.g. `src/my-ads/`)
* Each project contains a `manifest.yml` file.
* Each project contains a template for each size (e.g. `src/my-ads/300x250.erb`)
* Each project contains a directory for assets (e.g. `src/my-ads/assets/`) with three folders:
    * `css/` - for your stylesheets
    * `js/` - for your scripts
    * `images/` - for your images

### manifest.yml

Each project must have a file named `manifest.yml`. This file contains a list of each of the project's `types` and `sizes`. Here's an example manifest file:

```yml
types:
  - earth
  - wind
  - water
  - fire
sizes:
  - 160x600
  - 300x250
  - 300x600
  - 728x90
```

When the Ad Builder parses this file, it assumes that you have N sizes for each type, so in the above example you would have these ads:

    earth - 160x600
    earth - 300x250
    earth - 300x600
    earth - 728x90
    wind - 160x600
    ... etc ...

### Templates

Each size has a template with a name of `<size>.erb` where `<size>` is any of the sizes listed in your `manifest.yml` file. Each template has access to these variables:

* `type` - the type of the template currently being viewed.
* `project` - the name of the project

Each template also has access to [these helpers][asset-helpers].

### Assets

Each project must have their assets (css, js, images, etc) placed into a folder named `assets/`. The directory must have these folders:

    assets/
        css/
        images/
        js/

#### Sprockets

We're using [sprockets][sprockets-homepage] to serve assets. When the server is booted up, Ad Builder looks for the directories above and includes it into sprockets' load path. Since we're using sprockets, you can `require` files into your .css and .js files. [Go here to read more about how to do that.][sprockets-dependencies].

#### Images

All of the images must be placed into your project's `assets/images` folder. Each image must not be in a subdirectory of this folder and they must follow a special naming convention or they won't be exported with the ad. There are three ways you can name an image:

* for all ads - `global_foo_bar.jpg`
    * Images prefixed with `global_` will be included with EVERY ad in the project.
* for a specific size - `300x250_foo_bar.jpg`
    * Images prefixed with `SIZE_` will be included with every ad that is the specified size.
* for a specific type and size - `general_300x250_foo_bar.jpg`
    * Images prefixed with `TYPE_SIZE_` will be included only with the ad that is the specified size and the specified type.

## Rake Tasks

Ad Builder comes with a handful of Rake tasks by default. If a rake command specified below has an argument prepended with an asterisk, that means that the argument is optional.

### rake export[project,*types,*sizes,include_index]

Exports ads into the `dist/` folder. Each ad will be placed into a directory following this pattern: `dist/<project>/<type>/<size>/'. Each ad's assets will be placed into the ad directory. The images will have their prefixes removed and CSS and JS files will be concatenated and minified.

Arguments:

* `project` - The project you'd like to export ads for (e.g. "my-ads").
* `types` - (optional) A space-delimited string of types to export (e.g. "typeA typeB typeC"). **Default:** all of a project's types.
* `sizes` - (optional) A space-delimited string of sizes to export (e.g. "160x600 300x250"). **Default:** all of a project's sizes.

#### Example

Running the command

    $ rake export["my-ads"]

Will result in each ad will be placed into a folder named after its project.

    dist/
        my-ads/
            typeA/
                300x250/
                    index.html
                    image.jpg
                    styles.css
                    scripts.js
                ...
            ...

From here, you can easily hand off your exported ads.

### rake new[project_name,*types,*sizes]

> **Important!** This task hasn't been implemented yet.

Scaffolds a new project in the `src` directory.

Arguments:

* `project_name` - the name of the project. This will be the directory's name.
* `types` - (optional) a space-delimited string of types to support (e.g. "typeA typeB typeC"). **Default:** no types.
* `sizes` - (optional) a space-delimited string of sizes in the format `WxH` to create templates for (e.g. "300x250 160x600"). **Default:** no sizes.

#### Example

Running the command:

    $ rake new["my-ads","general alt","300x250 160x600"]

Will scaffold a new project named `my-ads` with the types `general` and `alt` in the sizes of `300x250` and `160x600`. It will create a working project with a manifest, CSS and JS files and templates that include helpers and variables to give you an example of how a project is structured.

If you run `rake new` with only the project name, then _no_ ad templates, css and etc will be created. Just the bare-minimum folder structure and a `manifest.yml` file.

[asset-helpers]: https://github.com/eleven/ad-builder/blob/master/lib/asset_helpers.rb
[sprockets-homepage]: https://github.com/sstephenson/sprockets
[sprockets-dependencies]: https://github.com/sstephenson/sprockets#managing-and-bundling-dependencies
