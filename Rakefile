require "rubygems"
require "bundler/setup"
require "rakeup"
require "yui/compressor"
require "uglifier"

require "./ad_builder"
include Sinatra::AssetHelpers

ENV["RACK_ENV"] = "production"

RakeUp::ServerTask.new do |t|
  t.port = 9292
  t.pid_file = "tmp/server.pid"
  t.rackup_file = "config.ru"
  t.server = :thin
end

desc "Builds the ads into the dist/ folder.\n\nProtip: use space-dilimeted string(s) for multiple types/sizes. Example:\n  rake build[\"general discovery\", \"300x600 728x90\"]\n\nDefault types: #{AdBuilder::TYPES}\nDefault sizes: #{AdBuilder::SIZES}"
task :build, [:types, :sizes] do |t, args|
  args.with_defaults types: AdBuilder::TYPES, sizes: AdBuilder::SIZES

  Rake::Task["cleanup"].invoke

  # Boot up the server in production mode
  Rake::Task["server:start"].invoke
  sleep 1

  begin
    build_ads rake_array_arg(args.types), rake_array_arg(args.sizes)
  rescue Exception => e
    puts e.message
    puts e.backtrace
  ensure
    Rake::Task["server:stop"].invoke
  end
end

desc "Removes all generated content from the dist/ folder."
task :cleanup do
  folders = AdBuilder::TYPES.map {|t| "dist/#{t}" }
  `rm -rf #{folders.join(' ')}`
end

# Splits a space-delimited string into an array if it's a string.
def rake_array_arg(arg, delim = " ")
  return arg.split(delim) if arg.is_a? String
  return arg
end

# Builds multiple ads with types and sizes.
def build_ads(types, sizes)
  # Enable compression

  types.each do |type|
    sizes.each do |size|
      build_ad type, size
    end
  end
end

# Builds an ad by type and size.
# 
# NOTE: This method requires some sensible defaults.
def build_ad(type, size)
  print "Building #{type} #{size} ad..." if verbose == true

  dest_folder = "dist/#{type}/#{size}"
  css_file = "#{size}.css"
  js_file = "#{size}.js"

  FileUtils.mkdir_p dest_folder

  `curl -o #{dest_folder}/index.html http://localhost:9292/banner/#{type}/#{size}`

  # Compile CSS and JS
  compile_asset css_file, "#{dest_folder}/#{css_file}"
  compile_asset js_file, "#{dest_folder}/#{js_file}"

  # Move images
  images = Dir.glob("src/assets/images/global*")
             .concat(Dir.glob("src/assets/images/#{size}*"))
             .concat(Dir.glob("src/assets/images/#{type}_#{size}*"))

  images.each do |image|
    filename = remove_image_prefix File.basename(image)
    `cp #{image} #{dest_folder}/#{filename}`
  end

  puts "done!" if verbose == true
end

# Compiles an asset from the asset pipeline
def compile_asset(src, dest)
  sprockets = AdBuilder.settings.sprockets
  sprockets.css_compressor = YUI::CssCompressor.new
  sprockets.js_compressor = Uglifier.new(mangle: true, comments: :none)

  asset = sprockets[src]
  FileUtils.mkdir_p Pathname.new(dest).dirname

  asset.write_to dest
end
