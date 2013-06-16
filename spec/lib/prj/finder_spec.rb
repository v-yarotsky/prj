require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require 'prj/finder'

describe "Prj::Finder" do
  around(:each) do |example|
    Dir.mktmpdir("projects") do |root|
      @root = root
      example.run
    end
  end

  it "finds directories containing .git/ scoped to given root and returns their relative paths" do
    make_directories(root, "/foo/.git", "/bar/qux", "/baz/.git")
    finder(:vcs_directories => [".git"]).find_project_directories.should =~ ["/foo", "/baz"]
  end

  it "does not find nested repos unless :search_nested_repositories" do
    make_directories(root, "/foo/.git", "/foo/bar", "/foo/baz/.git")
    finder(:vcs_directories => [".git"]).find_project_directories.should =~ ["/foo"]
  end

  it "finds nested repos if :search_nested_repositories option is true" do
    make_directories(root, "/foo/.git", "/foo/bar", "/foo/baz/.git")
    finder(:vcs_directories => [".git"], :search_nested_repositories => true).find_project_directories.should =~ ["/foo", "/foo/baz"]
  end

  it "does support other vcs repos" do
    make_directories(root, "/foo/.git", "/bar/.svn", "/foo/baz/.unknown")
    finder(:vcs_directories => [".git", ".svn"]).find_project_directories.should =~ ["/foo", "/bar"]
  end

  def make_directories(root, *directories)
    directories.each { |d| FileUtils.mkdir_p(File.join(root, d)) }
  end

  def finder(options = {})
    Prj::Finder.new(root, options)
  end

  def root
    @root
  end
end

