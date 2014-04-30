require "json"
require "open-uri"
require "sprockets"
require "yui/compressor"
require "uglifier"

require_relative "../sinatra/asset_helpers"

module AdBuilder
  class Exporter
    attr_accessor :src_folder, :dist_folder, :sprockets

    include Sinatra::AssetHelpers

    def initialize(src_folder, dist_folder, server, options = {})
      @src_folder = src_folder
      @dist_folder = dist_folder
      @server = server
      @options = options.merge include_indexes: true, verbose: false
    end

    def export_project(project, types, sizes)
      export_banners project, types, sizes
    end

    def export_banners(project, types, sizes)
      if Dir["#{@src_folder}/#{project}/"]
        unless types || sizes
          mani = @server.settings.manifest

          types = mani["types"] if types.nil?
          sizes = mani["sizes"] if sizes.nil?
        end

        # Create the project folder
        FileUtils.mkdir_p "#{@dist_folder}/#{project}/"

        # Download the index
        if @options[:include_indexes]
          `curl -o #{@dist_folder}/#{project}/index.html http://localhost:9292/`
        end

        # Build each banner
        types.each do |type|
          sizes.each do |size|
            export_banner project, type, size
          end
        end
      end
    end

    def export_banner(project, type, size)
      print "Building #{type} #{size} ad..." if @options[:verbose] == true

      banner_folder = "#{@dist_folder}/#{project}/#{type}/#{size}"
      css_file = "#{size}.css"
      js_file = "#{size}.js"

      # Create the banner folder
      FileUtils.mkdir_p banner_folder

      # Download the banner's html
      `curl -o #{banner_folder}/index.html http://localhost:9292/#{type}/#{size}`


      # Compile CSS and JS
      compile_asset css_file, "#{banner_folder}/#{css_file}"
      compile_asset js_file, "#{banner_folder}/#{js_file}"

      # Fetch images used in this banner from the API and then move them into the folder
      puts "http://localhost:9292/api/images/#{type}/#{size}.json"
      images = JSON.load(open("http://localhost:9292/api/images/#{type}/#{size}.json"))["images"]
      images.map! { |image| "#{@src_folder}/#{project}/assets/images/#{image}" }

      # Also, get any files that happen to be specific to that banner: TYPE_SIZE_name.ext
      Dir.glob("#{@src_folder}/#{project}/assets/images/#{type}_#{size}_*").each do |image|
        images.push image
      end

      # Resolve any duplicates
      images.uniq!

      images.each do |image|
        trimmed_image_filename = remove_image_prefix File.basename(image)
        `cp #{image} #{banner_folder}/#{trimmed_image_filename}`
      end

      puts "done!" if @options[:verbose] == true
    end

    def compile_asset(src, destination)
      sprockets = @server.settings.sprockets
      sprockets.css_compressor = YUI::CssCompressor.new
      sprockets.js_compressor = Uglifier.new mangle: true, comments: :none

      asset = sprockets[src]
      FileUtils.mkdir_p Pathname.new(destination).dirname

      asset.write_to destination
    end
  end
end
