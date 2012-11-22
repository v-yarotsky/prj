require 'spec_helper'
require 'prj/app'
require 'stringio'
require 'tmpdir'
require 'fileutils'

describe "Prj::App" do
  around(:each) do |example|
    Dir.mktmpdir do |root|
      @root = root
      @subdirectories = [
        "foo/.git/",
        "bar/",
        "baz/qux/crisp/.git/",
        "baz/craps/poops/.git/",
        "any/thing/here/"
      ].map { |d| File.join(@root, d) }
      @subdirectories.each { |d| FileUtils.mkdir_p(d) }
      @sink = StringIO.new
      example.run
    end
  end

  context "with default projcts root" do
    around(:each) do |example|
      with_projects_root(@root) do
        example.run
      end
    end

    it "prints matching directory and returns 0" do
      Prj::App.new(@sink, ["ap"]).run.should == 0
      @sink.string.chomp.should == File.join(@root, "baz/craps/poops")
    end

    it "prints projects root and returns 0 if directory not found" do
      Prj::App.new(@sink, ["nothingtofind"]).run.should == 0
      @sink.string.chomp.should == @root + "/"
    end

  end

  it "Uses project root from config if available" do
    File.should_receive(:read).with(File.expand_path("~/.prj"))
    Prj::App.new(@sink, ["something"]).run.should == 0
  end

  def with_projects_root(root)
    tmp = Prj::App.default_projects_root
    Prj::App.default_projects_root = root
    Prj::App.ignore_config = true
    yield
    Prj::App.default_projects_root = tmp
    Prj::App.ignore_config = false
  end
end


