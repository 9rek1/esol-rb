module Whitespace
  class VM
    class ProgramError < StandardError; end

    def self.run(insns)
      new(insns).run
    end

    def initialize(insns)
      @insns = insns
      @stack = []
      @heap = {}
      @labels = find_labels(@insns)
    end

    def run
      # todo
    end

    private

    def find_labels(insns)
      labels = {}
      insns.each_with_index do |(insn, arg), _i|
        labels[arg] ||= i if insn == :label
      end
      labels
    end
  end
end
