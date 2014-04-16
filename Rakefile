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

desc "Exports the ads into the dist/ folder.\n\nProtip: use space-delimeted string(s) for multiple types/sizes. Example:\n  rake build[\"general discovery\", \"300x600 728x90\"]"
task :export, [:projects, :types, :sizes, :include_indexes] do |t, args|
  args.with_defaults projects: nil, types: nil, sizes: nil, include_indexes: true

  require_relative "ad_builder"
  require_relative "lib/ad_builder/exporter"

  Rake::Task["cleanup"].invoke

  ENV["RACK_ENV"] = "production"
  Rake::Task["server:start"].invoke
  sleep 1

  begin
    exporter = AdBuilder::Exporter.new src_folder, dist_folder, AdBuilderServer, include_indexes: args.include_indexes, verbose: verbose
    exporter.build_projects rake_array_arg(args.projects), rake_array_arg(args.types), rake_array_arg(args.sizes)
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
