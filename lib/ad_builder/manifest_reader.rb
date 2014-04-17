module AdBuilder
  module ManifestReader
    def manifest(project, root)
      @manifests = {} unless @manifests

      if @manifests[project]
        @manifests[project]
      else
        if Dir.exists? File.join(root, project)
          @manifests[project] = 
        end
      end
    end
  end
end
