module Prj
  version_file = File.expand_path('../VERSION', File.dirname(__FILE__))
  VERSION = File.read(version_file).freeze
end

require 'prj/filter'
require 'prj/finder'

