module AdBuilder
  module ManifestReader
    def manifest(project, root)
      @manifests = {} unless @manifests

      if @manifests[project]
        @manifests[project]
      else
        if Dir.exists? File.join(root, project)
          @manifests[project] = YAML.load_file File.join(root, project, 'manifest.yml')
        end
      end
    end
  end
end
