require 'spec_helper'
require 'fakefs/spec_helpers'
require 'prj/finder'

describe "Prj::Finder" do
  include FakeFS::SpecHelpers

  let(:root) { "~/projects" }

  it "finds directories containing .git/ scoped to given root and returns their relative paths" do
    make_directories(root, "/foo/.git", "/bar/qux", "/baz/.git")
    Prj::Finder.new(root).find_project_directories.should =~ ["/foo", "/baz"]
  end

  it "does not find directories nested under directory containing .git/" do
    make_directories(root, "/foo/.git", "/foo/bar", "/foo/baz/.git")
    Prj::Finder.new(root).find_project_directories.should =~ ["/foo"]
  end

  def make_directories(root, *directories)
    directories.each do |d|
      FakeFS::FileSystem.add(File.join(root, d))
    end
  end
end

