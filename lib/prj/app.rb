require 'prj/finder'
require 'prj/filter'

module Prj
  class App
    class << self
      attr_accessor :default_projects_root, :ignore_config
    end
    @default_projects_root = "~/Projects".freeze
    @ignore_config = false

    def initialize(sink, args = [])
      @letters = String(args.first).each_char.to_a
      @sink = sink
    end

    def run
      if @letters.empty?
        @sink.puts projects_root
      else
        finder = Finder.new(projects_root)
        filter = Filter.new(@letters)

        directories = finder.find_project_directories
        filtered_directories = filter.filter(directories)

        target_directory = File.join(projects_root, filtered_directories.first.to_s)

        @sink.puts target_directory
      end

      return 0
    end

    def projects_root
      @projects_root ||= begin
        path = begin
          raise "default config" if self.class.ignore_config
          File.read(File.expand_path("~/.prj")).chomp
        rescue
          self.class.default_projects_root
        end
        File.expand_path(path).freeze
      end
    end
  end
end

