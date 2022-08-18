require 'strscan'

module Whitespace
  class Compiler
    class ProgramError < StandardError; end

    NUM = /([ \t]+)\n/.freeze
    LABEL = NUM

    def self.compile(src)
      new(src).compile
    end

    def initialize(src)
      @src = src
      @s = nil
    end

    def compile
      @s = StringScanner.new(bleach(@src))
      insns = []
      insns.push(step) until @s.eos?
      insns
    end

    private

    def bleach(src)
      src.gsub(/[^ \t\n]/, '')
    end

    def step
      if @s.scan(/  #{NUM}/) then [:push, num(@s[1])]
      elsif @s.scan(/ \n /) then [:dup]
      elsif @s.scan(/ \t #{NUM}/) then [:copy, num(@s[1])]
      elsif @s.scan(/ \n\t/) then [:swap]
      elsif @s.scan(/ \n\n/) then [:discard]
      elsif @s.scan(/ \t\n#{NUM}/) then [:slide, num(@s[1])]

      elsif @s.scan(/\t  /) then [:add]
      elsif @s.scan(/\t  \t/) then [:sub]
      elsif @s.scan(/\t  \n/) then [:mul]
      elsif @s.scan(/\t \t/) then [:div]
      elsif @s.scan(/\t \t\t/) then [:mod]

      elsif @s.scan(/\t\t/) then [:heap_write]
      elsif @s.scan(/\t\t\t/) then [:heap_read]

      elsif @s.scan(/\n  #{LABEL}/) then [:label, label(@s[1])]
      elsif @s.scan(/\n \t#{LABEL}/) then [:call, label(@s[1])]
      elsif @s.scan(/\n \n#{LABEL}/) then [:jump, label(@s[1])]
      elsif @s.scan(/\n\t #{LABEL}/) then [:jump_zero, label(@s[1])]
      elsif @s.scan(/\n\t\t#{LABEL}/) then [:jump_negative, label(@s[1])]
      elsif @s.scan(/\n\t\n/) then [:return]
      elsif @s.scan(/\n\n\n/) then [:exit]

      elsif @s.scan(/\t\n  /) then [:char_out]
      elsif @s.scan(/\t\n \t/) then [:num_out]
      elsif @s.scan(/\t\n\t /) then [:char_in]
      elsif @s.scan(/\t\n\t\t/) then [:num_in]
      else
        raise ProgramError, 'マッチする命令がありません'
      end
    end

    def num(str)
      raise ArgumentError "数値はタブとスペースで指定してください(#{str.inspect})" if str !~ /\A[ \t]+\z/

      num = str.sub(/\A /, '+')
               .sub(/\A\t/, '-')
               .gsub(/ /, '0')
               .gsub(/\t/, '1')
      num.to_i(2)
    end

    def label(str)
      str
    end
  end
end

p Whitespace::Compiler.compile("   \t\n\t\n \t\n\n\n") if $PROGRAM_NAME == __FILE__
