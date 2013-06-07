require 'prj/dir_with_score'

module Prj

  class Filter
    def initialize(letters)
      @letters = letters.to_a
    end

    def filter(directories)
      directories.select { |d| filter_dir(d, @letters) }.map { |d| DirWithScore.new(d, distance(d)) }.sort.map(&:to_s)
    end

    def distance(dir)
      return 0 if dir.empty? || @letters.empty?
      indices = []
      d = dir.dup
      @letters.each do |letter|
        idx = d.index(letter)
        indices << idx
        d = d[(idx + 1)..-1]
      end
      indices.inject(0, &:+) - indices.first
    end

    private

    #
    # Returns true if directory path contains all letters (ordered)
    #
    def filter_dir(dir, letters)
      if letters.empty?
        true
      else
        letter = letters.first
        i = dir.index(letter)
        i && filter_dir(dir[(i + 1)..-1], letters[1..-1])
      end
    end
  end

end

