This is the repo for the Retail Ad Builder. This project programatically builds out ads via `rake build`.

## Getting started

Make sure you have all dependencies installed by running:

    bundle

### Development

Development consists of using Sinatra and Sprockets for building files. Simply boot up the server by running:

    rake server

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

We're using a custom-built version of jQuery v1.11.0 to save KBs. For reference, here are the flags we're currently building jQuery against:

    -ajax,-deprecated,-event/alias,-offset,-wrap,-core/ready,-exports/amd,-dimensions

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

## Optimization techniques

### Styles

CSS should be clear and concise. You should not have any rules that are unused. You can check for unused styles by running the "Audit" feature found in Chrome's Developer Tools. Try to combine rules if possible to retain wasted bytes.

### JS

JS should be clear and concise. Try not to use external libraries at all if possible. Try to leverage recursive functions whenever possible to reduce byte-size.

### Images

All images with transparency, text, and/or hard edges that need to be sharp should be PNG. All other images should be JPEG. When working in Photoshop, make sure to save the image by using the **File > Save for Web** dialog.

#### JPEG

JPEG is a **lossy** image format, which means that the image data is lost during compression. The more compression used, the lower the quality. Lower quality images tend to have "artifacts" and blurry edges, making it unsuitable for text. For most images, you should be using these Save for Web settings:

* Quality: 60
* Blur: 0
* Optimized: yes

If the image quality is poorer than usual, try increasing the quality incrementally to 80, 90 or 100. Do note that the image may have been compressed previously if you are re-editing a JPEG. The bottom-line target you should be aiming for is a low file size. Smaller images can typically get away with the higher qualities. ~20KB is a typical target to aim for.

#### PNG

PNG is a **lossless** image format, which means that the original image's quality is retained after compression. PNG is optimal for images that have only a few colors or have an emphasis on sharp edges (e.g. text, buttons). PNG also supports transparency. PNG files can be saved into two formats: PNG-8 and PNG-24.

Due to the nature of how PNG works, PNG can be incredibly efficient for some use cases and terribly inefficient for others. If used properly, a PNG can be much more efficient than an equivalent JPEG version.

##### PNG-8

PNG-8 is the "more efficient" version of PNG. PNG-8 is similar to GIF. It only supports up to 256 colors, so use this format for simple images like text. PNG-8 also supports transparency, but only one alpha channel, so that means that you either get 100% opacity or 0% opacity, no in-between. All partially transparent pixels will have a "matte" color saved behind it, so make sure to match the matte with the background color the image will be on top of. Also, like GIF, when you have an image with a transparency, then the transparent "color" takes up one of the 256 colors; matted transparent pixels will each take up a color as well (think of a 50% black pixel on top of a white background as a 50% gray pixel).

##### PNG-24

PNG-24 is what most people refer to as simply PNG. PNG-24 supports full alpha transparency, meaning you can a truly transparent image. The tradeoff is a much larger file size on some images. On other images, it can be the same size as a PNG-8 or slightly larger.

##### Optimizing for PNG

Despite being lossless, PNG includes compression. PNG uses a lossless compression method known as DEFLATE, which essentially "simplifies" the image's data by predicting what the colors will be. Since PNG arranges its data from left-to-right, you can optimize your images for PNG by reducing the amount of colors used adjacently on a row of pixels. An image with alternating horizontal stripes will be much smaller than a similarly-sized image with alternating vertical stripes. Also, wider images tend to be smaller than taller ones.

Knowing when to properly use PNG or JPG will go a long way in keeping file sizes down.

#### Sprites

File sizes and requests can be cut down by combining images into sprites. If your sprite is going to be a PNG, make sure your images are laid out horizontally rather than vertically whenever possible. JPEG is usually not a very good candidate for sprites since sprites rely on hard edges and JPEG cannot provide that.
