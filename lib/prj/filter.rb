module Prj
  class Filter
    def initialize(letters)
      @letters = letters.to_a
    end

    def filter(directories)
      sort(directories.select { |d| filter_dir(d, @letters) })
    end

    def dispersion(dir)
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

    def filter_dir(dir, letters)
      if letters.empty?
        true
      else
        letter = letters.first
        i = dir.index(letter)
        i && filter_dir(dir[(i + 1)..-1], letters[1..-1])
      end
    end

    def sort(directories)
      directories.sort do |d1, d2|
        disp1 = dispersion(d1)
        disp2 = dispersion(d2)
        if disp1 < disp2
          -1
        elsif disp1 > disp2
          1
        else
          if d1.length < d2.length
            -1
          elsif d1.length > d2.length
            1
          else
            0
          end
        end
      end
    end
  end
end

