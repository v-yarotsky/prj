require 'find'

module Prj
  class Finder
    def initialize(root)
      @root = File.expand_path(root)
    end

    ##
    # Returns directories containing .git/ directory, relative to @root
    #
    def find_project_directories
      subdirectories = []
      Find.find(@root) do |d|
        subdirectories << d && Find.prune if File.exists?(File.join(d, ".git/"))
      end
      subdirectories.map { |r| r.gsub(@root, "") }
    end
  end
end
