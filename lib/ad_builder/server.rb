require "sinatra/base"

require_relative "../sinatra"
require_relative "manifest_reader"

module AdBuilder
  class Server < Sinatra::Application
    include AdBuilder::ManifestReader
  end
end
