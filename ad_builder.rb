require "yaml"
require "sinatra/base"
require "sprockets"
require "fastimage"

require "./lib/asset_helpers"

class AdBuilder < Sinatra::Application
  set :lazyload, true
  set :root, File.join(File.dirname(__FILE__), "src")
  set :views, [File.join(root), File.join(File.dirname(__FILE__), "lib", "views")]
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_path, File.join(root, "assets")
  set :manifest, Proc.new { YAML.load_file File.join(root, 'manifest.yml') }

  TYPES = manifest["types"]
  SIZES = manifest["sizes"]

  configure do
    sprockets.append_path File.join(assets_path, "css")
    sprockets.append_path File.join(assets_path, "js")
    sprockets.append_path File.join(assets_path, "images")
  end

  helpers do
    def find_template(views, name, engine, &block)
      Array(views).each { |v| super(v, name, engine, &block) }
    end
  end

  ##############################################################################
  # Routes

  get "/" do
    erb :index, locals: { manifest: settings.manifest }, layout: false
  end

  get "/banner/:type/:size" do
    erb params[:size].to_sym, locals: { type: params[:type] }, layout: false
  end

  ##############################################################################
  # Assets

  get "/assets/css/:stylesheet" do
    content_type "text/css"
    settings.sprockets["#{params[:stylesheet]}"]
  end

  get "/assets/js/:javascript" do
    content_type "application/javascript"
    settings.sprockets["#{params[:javascript]}"]
  end

  %w{jpg png gif}.each do |format|
    get "/assets/images/:image.#{format}" do
      content_type "image/#{format}"
      settings.sprockets["#{params[:image]}.#{format}"]
    end
  end
end
