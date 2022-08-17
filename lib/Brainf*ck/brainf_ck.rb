class Brainf_ck
  class ProgramError < StandardError; end

  def initialize(src)
    @tokens = src.chars.to_a
  end

  def run
    tape = []
    pc = 0
    cur = 0

    while pc < @tokens.size
      case @tokens[pc]
      when '+'
        tape[cur] ||= 0
        tape[cur] += 1
      when '-'
        tape[cur] ||= 0
        tape[cur] -= 1
      when '>'
        cur += 1
      when '<'
        cur -= 1
        raise ProgramError, 'ポインタをこれ以上左に移動できません' if cur.zero?
      when '.'
        n = (tape[cur] || 0)
        print n.chr
      when ','
        tape[cur] = $stdin.getc.ord
      when '['
        pc = @jumps[pc] if tape[cur].zero?
      when ']'
        pc = @jumps[pc] unless tape[cur].zero?
      end

      pc += 1
    end
  end

  private

  def analyze_jumps(tokens)
    jumps = {}
    starts = []

    tokens.each_with_index do |c, i|
      case c
      when '['
        starts.push(i)
      when ']'
        raise ProgramError, ']が余分に含まれています' if starts.empty?

        from = starts.pop
        to = i
        jumps[from] = to
        jumps[to] = from
      end
    end
    raise ProgramError, '[が余分に含まれています' unless starts.empty?

    jumps
  end
end

begin
  Brainf_ck.new(ARGF.read).run
rescue Brainf_ck::ProgramError
  puts 'プログラムの実行に失敗しました'
end
