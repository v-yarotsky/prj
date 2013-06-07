require 'forwardable'

module Prj

  class DirWithScore
    include Comparable
    extend Forwardable

    attr_accessor :dir, :score

    def_delegators :dir, :length, :to_s

    def initialize(dir, score)
      @dir, @score = dir, score
    end

    def <=>(other)
      if score < other.score
        -1
      elsif score > other.score
        1
      else
        if length < other.length
          -1
        elsif  length > other.length
          1
        else
          0
        end
      end
    end
  end

end
