require "yaml"
require "sprockets"
require "fastimage"

require_relative "lib/ad_builder"

class AdBuilderServer < AdBuilder::Server
  set :lazyload, true
  set :root, File.join(File.dirname(__FILE__), "src")
  set :views, [File.join(root), File.join(File.dirname(__FILE__), "lib", "sinatra", "views")]
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_path, File.join(root, "assets")
  set :projects, lambda { Dir["#{root}/*/"].map { |d| File.basename(d) } }

  configure do
    Dir.glob("#{root}/*/").each do |project_folder|
      sprockets.append_path File.join(project_folder, 'assets', 'css')
      sprockets.append_path File.join(project_folder, 'assets', 'js')
      sprockets.append_path File.join(project_folder, 'assets', 'images')
    end
  end

  helpers do
    # Allows us to load views from multiple folders
    def find_template(views, name, engine, &block)
      Array(views).each { |v| super(v, name, engine, &block) }
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
  # Projects

  # Create route handlers for each project
  projects.each do |project|
    get "/#{project}" do
      set_project(project)
      erb :index, locals: { project: project, manifest: manifest(project, File.join(File.dirname(__FILE__), "src")) }, layout: false
    end

    get "/#{project}/:type/:size" do
      set_project(project)
      erb "#{project}/#{params[:size]}".to_sym, locals: { type: params[:type], project: project }, layout: false
    end
  end
end
