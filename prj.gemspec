# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib/', __FILE__)

require 'prj'
require 'date'

Gem::Specification.new do |s|
  s.name = "prj"
  s.summary = "Fuzzy-matching project finder"
  s.description = <<-DESC
    Prj is an utility to quickly go to project directory using fuzzy matching
  DESC

  s.version = Prj::VERSION.dup
  s.authors = ["Vladimir Yarotsky"]
  s.date = Date.today.to_s
  s.email = "vladimir.yarotksy@gmail.com"
  s.homepage = "http://github.com/v-yarotsky/prj"
  s.licenses = ["MIT"]

  s.rubygems_version = "1.8.21"
  s.required_rubygems_version = ">= 1.3.6"
  s.specification_version = 3

  s.extensions = Dir.glob("ext/**/extconf.rb")
  s.executables = ["prj"]
  s.files = Dir.glob("{bin,lib,ext,spec}/**/*") + %w[Gemfile Gemfile.lock Rakefile LICENSE.txt README.md VERSION]
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec", "~> 2.11")
  s.add_development_dependency("rake",  "~> 0.9")
  s.add_development_dependency("simplecov", "~> 0.6")
end


