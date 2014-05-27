require "rubygems"
require "bundler/setup"
require "rakeup"

src_folder = File.join File.dirname(__FILE__), "src"
dist_folder = File.join File.dirname(__FILE__), "dist"

# Add server tasks
RakeUp::ServerTask.new do |t|
  t.port = 9292
  t.pid_file = "tmp/server.pid"
  t.rackup_file = "config.ru"
  t.server = :thin
end

# Splits a space-delimited string into an array if it's a string.
def rake_array_arg(arg, delim = " ")
  return arg.split(delim) if arg.is_a? String
  return arg
end

desc "Boots up the server."
task :serve, [:project] do |t, args|
  ENV["ADBUILDER_PROJECT"] = args.project
  Rake::Task["server"].invoke
end

desc "Exports a project's ad(s) into the dist/ folder.\n\nProtip: use space-delimeted string(s) for multiple types/sizes. Example:\n  rake export[\"project-name\",\"general discovery\", \"300x600 728x90\"]"
task :export, [:project, :compress_assets, :include_indexes] do |t, args|
  args.with_defaults compress_assets: "true", include_indexes: "true"

  Rake::Task["cleanup"].invoke

  ENV["ADBUILDER_PROJECT"] = args.project
  ENV["RACK_ENV"] = "production"

  require_relative "ad_builder"
  require_relative "lib/ad_builder/exporter"

  Rake::Task["server:start"].invoke
  sleep 1

  begin
    exporter = AdBuilder::Exporter.new src_folder, dist_folder, AdBuilderServer, include_indexes: args.include_indexes == "true", verbose: verbose, compress_assets: args.compress_assets == "true"
    exporter.export_project args.project
  rescue Exception => e
    puts e.message
    puts e.backtrace
  ensure
    Rake::Task["server:stop"].invoke
  end
end

desc "Removes all generated content from the dist/ folder."
task :cleanup do
  `rm -rf #{dist_folder}`
end
