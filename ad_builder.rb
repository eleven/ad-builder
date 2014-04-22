require "json"
require "yaml"
require "sprockets"
require "fastimage"

require_relative "lib/ad_builder"

class AdBuilderServer < AdBuilder::Server
  set :project, ENV["ADBUILDER_PROJECT"]
  set :root, File.join(File.dirname(__FILE__), "src", project)
  set :core_assets, File.join(File.dirname(__FILE__), "lib", "ad_builder", "assets")

  set :views, [File.join(root), File.join(File.dirname(__FILE__), "lib", "sinatra", "views")]
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })

  set :manifest, lambda { YAML.load_file File.join(root, 'manifest.yml') }

  configure do
    # Load in global assets
    Dir["#{core_assets}/*/"].each do |core_asset_dir|
      sprockets.append_path core_asset_dir
    end

    # Load in the project's assets
    sprockets.append_path File.join(root, 'assets', 'css')
    sprockets.append_path File.join(root, 'assets', 'js')
    sprockets.append_path File.join(root, 'assets', 'images')
  end

  helpers do
    # Allows us to load views from multiple folders
    def find_template(views, name, engine, &block)
      Array(views).each { |v| super(v, name, engine, &block) }
    end

    def local_get(url)
      call(env.merge("PATH_INFO" => url)).last.join
    end
  end

  ##############################################################################
  # Routes
  ##############################################################################

  # ============================================================================
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

  # ============================================================================
  # API

  # Gets the images used on a template
  get "/api/images/:type/:size.json" do
    content_type :json

    @rendered_images = []

    # Extend the image_src method so that we can extract the images used in the template
    def image_url(*args)
      super do |img|
        @rendered_images.push(img)
      end
    end

    local_get("/#{params[:type]}/#{params[:size]}")

    # "Reset" the image_src method
    def image_url(*args)
      super
    end

    { images: @rendered_images.uniq }.to_json
  end

  get "/api*" do
    content_type :json
    { error: "method not found" }.to_json
  end

  # ============================================================================
  # Projects

  # Create route handlers for each project
  get "/" do
    erb :index, locals: { manifest: settings.manifest }, layout: false
  end

  get "/:type/:size" do
    set_banner_type params[:type]
    set_banner_size params[:size]

    erb params[:size].to_sym, locals: {
      type: params[:type],
      size: params[:size],
      manifest: settings.manifest
    }, layout: false
  end
end
