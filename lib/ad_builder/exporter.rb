require "sprockets"
require "yui/compressor"
require "uglifier"

require_relative "manifest_reader"
require_relative "../sinatra/asset_helpers"

module AdBuilder
  class Exporter
    attr_accessor :src_folder, :dist_folder, :sprockets

    include AdBuilder::ManifestReader
    include Sinatra::AssetHelpers

    def initialize(src_folder, dist_folder, server, options = {})
      @src_folder = src_folder
      @dist_folder = dist_folder
      @server = server
      @options = options.merge include_indexes: true, verbose: false
    end

    def build_projects(projects, types, sizes)
      unless projects
        projects = Dir["#{@src_folder}/*/"].map { |d| File.basename(d) }
      end

      projects.each do |project|
        build_banners project, types, sizes
      end
    end

    def build_banners(project, types, sizes)
      if Dir["#{@src_folder}/#{project}/"]
        unless types || sizes
          mani = manifest(project, @src_folder)

          types = mani["types"] if types.nil?
          sizes = mani["sizes"] if sizes.nil?
        end

        # Create the project folder
        FileUtils.mkdir_p "#{@dist_folder}/#{project}/"

        # Download the index
        if @options[:include_indexes]
          `curl -o #{@dist_folder}/#{project}/index.html http://localhost:9292/#{project}`
        end

        # Build each banner
        types.each do |type|
          sizes.each do |size|
            build_banner project, type, size
          end
        end
      end
    end

    def build_banner(project, type, size)
      print "Building #{type} #{size} ad..." if @options[:verbose] == true

      banner_folder = "#{@dist_folder}/#{project}/#{type}/#{size}"
      css_file = "#{size}.css"
      js_file = "#{size}.js"

      # Create the banner folder
      FileUtils.mkdir_p banner_folder

      # Download the banner's html
      `curl -o #{banner_folder}/index.html http://localhost:9292/#{project}/#{type}/#{size}`

      # Compile CSS and JS
      compile_asset css_file, "#{banner_folder}/#{css_file}"
      compile_asset js_file, "#{banner_folder}/#{js_file}"

      # Move images
      images = Dir.glob("#{@src_folder}/#{project}/assets/images/global*")
                 .concat(Dir.glob("#{@src_folder}/#{project}/assets/images/#{size}*"))
                 .concat(Dir.glob("#{@src_folder}/#{project}/assets/images/#{type}_#{size}*"))

      # Remove prefix from each image filename
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

      puts src

      asset = sprockets[src]
      FileUtils.mkdir_p Pathname.new(destination).dirname

      asset.write_to destination
    end
  end
end