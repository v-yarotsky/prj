require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require 'prj'
require 'stringio'
require 'yaml'

describe "Prj::App" do
  let(:output) { StringIO.new }
  let(:subdirectories) do
    [
      "foo/.git/",
      "foo/baz/.git/",
      "bar/",
      "baz/qux/crisp/.git/",
      "baz/craps/poops/.git/",
      "any/thing/here/"
    ].map { |d| File.join(root, d) }
  end

  around(:each) do |example|
    Dir.mktmpdir("Projects") do |root|
      @root = root
      subdirectories.each { |d| FileUtils.mkdir_p(d) }
      example.run
    end
  end

  context "within projcts root" do
    it "prints matching directory and returns 0" do
      with_config("projects_root" => root) do
        Prj::App.new(output, ["ap"]).run.should == 0
        output.string.chomp.should == File.join(root, "baz/craps/poops")
      end
    end

    it "prints projects root and returns 0 if directory not found" do
      with_config("projects_root" => root) do
        Prj::App.new(output, ["nothingtofind"]).run.should == 0
        output.string.chomp.should == root
      end
    end

    it "allows case-insensitive search if option specified in config" do
      with_config("projects_root" => root, "case_sensitive" => false) do
        Prj::App.new(output, ["Fo"]).run.should == 0
        output.string.chomp.should == File.join(root, "foo")
      end
    end

    it "does not search nested repos by default" do
      with_config("projects_root" => root) do
        Prj::App.new(output, ["fob"]).run.should == 0
        output.string.chomp.should_not == File.join(root, "foo/baz")
      end
    end

    it "can search nested repos if 'search_nested_repositories' option is true" do
      with_config("projects_root" => root, "search_nested_repositories" => true) do
        Prj::App.new(output, ["fob"]).run.should == 0
        output.string.chomp.should == File.join(root, "foo/baz")
      end
    end
  end

  it "uses ~/.prj.yml as config file" do
    Prj::App.config_path.should == File.expand_path("~/.prj.yml")
  end

  it "defaults to ~/Projects as default projects root" do
    with_config do
      Prj::App.new(output, ["asdf"]).config.fetch("projects_root").should == File.expand_path("~/Projects")
    end
  end

  def with_config(config = {})
    tmp = Prj::App.config_path
    config_path = File.join(Dir.tmpdir, ".prj.yml")
    File.open(config_path, "w") { |f| f.write YAML.dump(config) }
    Prj::App.config_path = config_path
    yield
  ensure
    Prj::App.config_path = tmp
  end

  def root
    @root
  end
end

