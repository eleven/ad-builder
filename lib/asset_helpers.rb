module Sinatra
  module AssetHelpers
    # Public: Creates image src, width and height attributes by an image src.
    # 
    # image - The String image filename.
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
    def image_src(image, opts = {})
      options = {
        lazy_load: true,
        parent_folder: ENV["RACK_ENV"] == "production" ? "" : "/assets/images/",
        trim_prefixes: ENV["RACK_ENV"] == "production"
      }.merge(opts)

      size = FastImage.size("#{File.dirname(__FILE__)}/../src/assets/images/#{image}")
      image_src = if options[:lazy_load] then "global_blank.gif" else image end

      if options[:trim_prefixes]
        image_src = remove_image_prefix(image_src)
        image = remove_image_prefix(image)
      end

      html = "src=\"#{options[:parent_folder]}#{image_src}\" width=\"#{size[0]}\" height=\"#{size[1]}\""
      html = "#{html} data-lazyload-src=\"#{options[:parent_folder]}#{image}\"" if options[:lazy_load]
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

    def banner_url(path)
      if ENV["RACK_ENV"] == "production"
        "#{path}/index.html"
      else
        "/banner/#{path}"
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
  end

  helpers AssetHelpers
end
