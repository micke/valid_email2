# frozen_string_literal: true

module ValidEmail2
  # A list of domains read from a sorted file, one domain per line, and kept as a single String
  # searched by bisection. A Set of the same domains takes several times the memory: each domain
  # becomes a String object of its own, plus its hash table entry.
  class SortedDomainList
    NEWLINE = "\n".b.freeze

    def initialize(path)
      @list = File.binread(path).freeze
    end

    def include?(domain)
      domain = domain.to_s.b
      low = 0
      high = @list.bytesize

      while low < high
        middle = (low + high) / 2
        start = (@list.rindex(NEWLINE, middle - 1) || -1) + 1
        stop = @list.index(NEWLINE, start) || @list.bytesize
        line = @list.byteslice(start, stop - start)
        return true if line == domain

        if line < domain
          low = stop + 1
        else
          high = start
        end
      end

      false
    end
  end
end
