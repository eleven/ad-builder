require "sinatra/base"
require "sprockets"
require "fastimage"

module Sinatra
  module AssetHelpers
    def image_src(src, lazy_load = true)
      size = FastImage.size("#{File.dirname(__FILE__)}/src/assets/images/#{src.gsub(/\/?assets\//, '')}")
      image_src = if lazy_load then "assets/global_blank.gif" else src end
      html = "src=\"#{image_src}\" width=\"#{size[0]}\" height=\"#{size[1]}\""
      html = "#{html} data-lazyload-src=\"#{src}\"" if lazy_load
    end
  end

  helpers AssetHelpers
end

class AdBuilder < Sinatra::Application
  TYPES = ["general", "discovery", "leadership", "passion", "service", "general_alt", "leadership_alt", "passion_alt"]
  SIZES = ["160x600", "300x250", "300x600", "728x90"]

  set :lazyload, true
  set :root, File.join(File.dirname(__FILE__), "src")
  set :views, Proc.new { File.join(root) }
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_path, File.join(root, "assets")

  configure do
    sprockets.append_path File.join(assets_path, "css")
    sprockets.append_path File.join(assets_path, "js")
    sprockets.append_path File.join(assets_path, "images")
  end

  ##############################################################################
  # Routes
  get "/:type/:size" do
    erb params[:size].to_sym, locals: { type: params[:type] }, layout: false
  end

  ##############################################################################
  # Assets
  get "/:type/assets/:stylesheet.css" do
    content_type "text/css"
    settings.sprockets["#{params[:stylesheet]}.css"]
  end

  get "/:type/assets/:javascript.js" do
    content_type "application/javascript"
    settings.sprockets["#{params[:javascript]}.js"]
  end

  %w{jpg png gif}.each do |format|
    get "/:type/assets/:image.#{format}" do
      content_type "image/#{format}"
      settings.sprockets["#{params[:image]}.#{format}"]
    end
  end
end
