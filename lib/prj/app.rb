require 'yaml'

module Prj

  class App
    class << self
      attr_accessor :config_path
    end
    @config_path = File.expand_path("~/.prj.yml").freeze

    def initialize(output, args = [])
      @letters = String(args.first).each_char.to_a
      @output = output
    end

    def run
      if @letters.empty?
        @output.puts File.expand_path(config.fetch("projects_root"))
        return 0
      end
      finder = Finder.new(config.fetch("projects_root"), symbolize_keys(config))
      filter = Filter.new(@letters, config.fetch("case_sensitive"))
      directories = finder.find_project_directories
      filtered_directories = filter.filter(directories)
      target_directory = File.expand_path(File.join(config.fetch("projects_root"), filtered_directories.first.to_s))
      @output.puts target_directory
      0
    end

    def config
      @config ||= begin
        config = File.exist?(self.class.config_path) ? YAML.load(File.read(self.class.config_path)) : {}
        default_config.merge(config)
      end
    end

    private

    def default_config
      default_config = {
        "projects_root"   => File.expand_path("~/Projects"),
        "vcs_directories" => [".git"],
        "case_sensitive"  => true
      }
    end

    def symbolize_keys(hash)
      Hash[hash.map { |k, v| [k.to_sym, v] }]
    end
  end

end

