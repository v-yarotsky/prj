require 'prj/dir_with_score'
require 'strscan'

module Prj

  class Filter
    def initialize(letters)
      @letters = letters.to_a
    end

    def filter(directories)
      wrapped_with_score(directories).sort.map(&:to_s)
    end

    def distance(dir)
      scanner = StringScanner.new(dir)
      @letters.each do |letter|
        scanner.scan(/.*?[#{letter}]/) or return :no_score
      end
      scanner.pos - @letters.length
    end

    def wrapped_with_score(directories)
      directories.map { |d| DirWithScore.new(d, distance(d)) }.reject { |d| d.score == :no_score }
    end
    private :wrapped_with_score
  end

end

