require 'find'

module Prj

  class Finder
    def initialize(root, vcs_directories)
      @root = File.expand_path(root)
      @vcs_directories = Array(vcs_directories)
    end

    ##
    # Returns directories containing .git/ directory, relative to @root
    #
    def find_project_directories
      subdirectories = []
      Find.find(@root) do |d|
        if @vcs_directories.any? { |vcs_dir| Dir.exists?(File.join(d, vcs_dir)) }
          subdirectories << d && Find.prune
        end
      end
      subdirectories.map { |r| r.gsub(@root, "") }
    end
  end

end
