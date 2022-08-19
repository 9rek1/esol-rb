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
      return_to = []
      pc = 0
      while pc < @insns.size
        insn, arg = *@insns[pc]

        case insn
        when :push then push(arg)
        when :dup then push(@stack[-1])
        when :copy then push(@stack[-(arg + 1)])
        when :swap
          x = pop
          y = pop
          push(x)
          push(y)
        when :discard then pop
        when :slide
          x = pop
          arg.times do
            pop
          end
          push(x)

        when :add
          y = pop
          x = pop
          push(x + y)
        when :sub
          y = pop
          x = pop
          push(x - y)
        when :mul
          y = pop
          x = pop
          push(x * y)
        when :div
          y = pop
          x = pop
          push(x / y)
        when :mod
          y = pop
          x = pop
          push(x % y)

        when :heap_write
          value = pop
          address = pop
          @heap[address] = value
        when :heap_read
          address = pop
          value = @heap[address]
          raise ProgramError, "heapのアドレス#{address}は値がなく読み出せません" if value.nil?

          push(value)

        when :label
          # 何もしない
        when :jump then pc = jump_to(arg)
        when :jump_zero then pc = jump_to(arg) if pop.zero?
        when :jump_negative then pc = jump_to(arg) if pop.negative?
        when :call
          return_to.push(pc)
          pc = jump_to(arg)
        when :return
          pc = return_to.pop
          raise ProgramError, 'サブルーチンの外からreturnしようとしました' if pc.nil?
        when :exit then return

        when :char_out then print pop.chr
        when :num_out then print pop
        when :char_in
          address = pop
          @heap[address] = $stdin.getc.ord
        when :num_in
          address = pop
          @heap[address] = $stdin.getc.to_i
        end
        pc += 1
      end
      raise ProgramError, 'プログラムがexitで終了していません'
    end

    private

    def find_labels(insns)
      labels = {}
      insns.each_with_index do |(insn, arg), _i|
        labels[arg] ||= i if insn == :label
      end
      labels
    end

    def push(item)
      raise ProgramError, "（#{item}）は整数ではないのでpushできません" unless item.is_a?(Integer)

      @stack.push(item)
    end

    def pop
      item = @stack.pop
      raise ProgramError, '空のスタックをpopできません' if item.nil?

      item
    end

    def jump_to(name)
      pc = @labels[name]
      raise ProgramError, "ジャンプ先#{name.inspect}が見つかりません" if pc.nil?

      pc
    end
  end
end

Whitespace::VM.run([[:push, 1], [:num_out], [:exit]]) if $PROGRAM_NAME == __FILE__
