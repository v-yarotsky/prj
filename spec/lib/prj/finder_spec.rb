require 'spec_helper'
require 'fakefs/spec_helpers'
require 'fileutils'
require 'prj/finder'

describe "Prj::Finder" do
  include FakeFS::SpecHelpers

  let(:root) { "~/projects" }

  it "finds directories containing .git/ scoped to given root and returns their relative paths" do
    make_directories(root, "/foo/.git", "/bar/qux", "/baz/.git")
    finder(".git").find_project_directories.should =~ ["/foo", "/baz"]
  end

  it "does not find directories nested under directory containing .git/" do
    make_directories(root, "/foo/.git", "/foo/bar", "/foo/baz/.git")
    finder(".git").find_project_directories.should =~ ["/foo"]
  end

  it "does support other vcs repos" do
    make_directories(root, "/foo/.git", "/bar/.svn", "/foo/baz/.unknown")
    finder(".git", ".svn").find_project_directories.should =~ ["/foo", "/bar"]
  end

  def make_directories(root, *directories)
    directories.each { |d| FileUtils.mkdir_p(File.join(root, d)) }
  end

  def finder(*vcs_directories)
    Prj::Finder.new(root, vcs_directories)
  end
end

