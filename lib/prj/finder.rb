require 'prj/fast_traverse'

module Prj

  class Finder
    def initialize(projects_root, options = {})
      @root = File.expand_path(projects_root)
      @vcs_directories = Array(options[:vcs_directories])
      @search_nested_repositories = !!options[:search_nested_repositories]
      @result = []
    end

    def find_project_directories
      return @result unless @result.empty?
      FastTraverse.traverse(@root, @search_nested_repositories) do |parent_path, child_name|
        next false unless vcs_directory?(child_name)
        @result << normalize_path(parent_path)
      end
      @result
    end

    private

    def vcs_directory?(directory_name)
      @vcs_directories.include? directory_name
    end

    def normalize_path(path)
      path.sub(@root, "").chomp("/")
    end
  end

end

