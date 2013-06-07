module Prj
  version_file = File.expand_path('../VERSION', File.dirname(__FILE__))
  VERSION = File.read(version_file).freeze

  autoload :DirWithScore, 'prj/dir_with_score'
  autoload :Filter,       'prj/filter'
  autoload :Finder,       'prj/finder'
  autoload :App,          'prj/app'
end

