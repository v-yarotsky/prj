require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"

    add_filter do |f|
      f.lines.count < 5
    end
  end
end

require 'rspec'
require 'rspec/autorun'

$:.unshift File.expand_path('../../lib', __FILE__)

