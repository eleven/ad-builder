require "fastimage"

module Sinatra
  module AssetHelpers
    attr_accessor :banner_type, :banner_size

    class FileNotFoundError < StandardError
    end

    def set_banner_type(type)
      @banner_type = type
    end

    def set_banner_size(size)
      @banner_size = size
    end

    # Public: Creates image src, width and height attributes by an image src.
    # 
    # image - The String image filename. Do not include the prefix in the
    #         filename, as we'll be using #try_image to figure out the correct
    #         prefix.
    # opts  - The Hash options used to refine the output (default: {}):
    #         :lazy_load     - A Boolean indicating whether the image should be
    #                          lazy loded or not (default: true).
    #         :parent_folder - A String path to the image's parent folder
    #                          (default: "/assets/images").
    #         :trim_prefixes - A Boolean indicating whether the prefixes should
    #                          be trimmed from the image filename or not
    #                          (default: false).
    # 
    # Returns a String with three HTML attributes: src, width and height.
    def image_src(src, opts = {})
      options = {
        lazy_load: true,
        parent_folder: ENV["RACK_ENV"] == "production" ? "" : "/assets/images/"
      }.merge(opts)

      img_path = try_image(src)
      img_url = image_url(src, options)
      # img_size = FastImage.size(img_path)

      if options[:lazy_load]
        lazyload_url = img_url
        img_url = image_url("blank.gif", options)
      end

      html = "src=\"#{img_url}\"" # width=\"#{img_size[0]}\" height=\"#{img_size[1]}\""
      html = "#{html} data-lazyload-src=\"#{lazyload_url}\"" if options[:lazy_load]
      html
    end

    def image_url(file, opts = {})
      options = {
        parent_folder: ENV["RACK_ENV"] == "production" ? "" : "/assets/images/",
        trim_prefixes: ENV["RACK_ENV"] == "production"
      }.merge(opts)

      begin
        image = File.basename try_image(file)
      rescue TypeError
        raise FileNotFoundError.new("#{file} not recognized by Sprockets.")
      end

      yield image if block_given?

      if options[:trim_prefixes]
        image = remove_image_prefix(image)
      end

      "#{options[:parent_folder]}#{image}"
    end

    # Public: Builds a path to a JS file. 
    # 
    # file - The String filename.
    # opts - The Hash options used to refine the output (default: {}).
    #        :parent_folder - A String path to the file's parent folder
    #                         (default: "/assets/js").
    # 
    # Returns the String path to the JS file.
    def js_path(file, opts = {})
      options = {
        parent_folder: ENV["RACK_ENV"] == "production" ? "" : "/assets/js/",
      }.merge(opts)

      "#{options[:parent_folder]}#{file}"
    end

    # Public: Builds a path to a CSS file. 
    # 
    # file - The String filename.
    # opts - The Hash options used to refine the output (default: {}).
    #        :parent_folder - A String path to the file's parent folder
    #                         (default: "/assets/css").
    # 
    # Returns the String path to the CSS file.
    def css_path(file, opts = {})
      options = {
        parent_folder: ENV["RACK_ENV"] == "production" ? "" : "/assets/css/",
      }.merge(opts)

      "#{options[:parent_folder]}#{file}"
    end

    def banner_url(type, size)
      path = "#{type}/#{size}"
      if ENV["RACK_ENV"] == "production"
        "#{path}/index.html"
      else
        "#{path}"
      end
    end

    private

    # Private: Removes the prefix from an image filename.
    # 
    # filename - The String filename of the image.
    # 
    # Returns the String filename of the image without the prefix.
    def remove_image_prefix(filename)
      filename.gsub(/^(global|\d+x\d+|[a-zA-Z]+_\d+x\d+)_/, '')
    end

    # Private: Finds an image based off of the filename by checking through the
    # prefix order.
    # 
    # It tries it in this order:
    #   1. type_size_image_name
    #   2. size_image_name
    #   3. global_image_name
    #
    # Returns the String path of the image that was found.
    def try_image(image_name)
      file = image_name

      ["#{@banner_type}_#{@banner_size}", "#{@banner_size}", "global"].each do |prefix|
        file = settings.sprockets["#{prefix}_#{image_name}"]
        unless file.nil?
          file = file.pathname
          break if File.exists? file
        end
      end

      file
    end

    # Private: Loads either the scss or css version of the file depending on
    # what's available. It tries to load the file in this order:
    # 
    # 1. filename.css.scss
    # 2. filename.css
    # 
    # Returns the file referenced in sprockets.
    def try_css(css)
      file = css

      ["#{css}.scss", css].each do |filename|
        file = settings.sprockets[filename]
        unless file.nil?
          pathname = file.pathname
          break if File.exists? pathname
        end
      end

      file
    end
  end

  helpers AssetHelpers
end
