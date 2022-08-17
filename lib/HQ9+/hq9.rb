class HQ9Plus
  def initialize(src)
    @src = src
    @cnt = 0
  end

  def run
    @src.each_char do |char|
      case char
      when 'H'
        hello
      when 'Q'
        p_src
      when '9'
        p_99_bottles
      when '+'
        inc
      end
    end
  end

  private

  def hello
    puts 'Hello, world!'
  end

  def p_src
    print @src
  end

  def p_99_bottles
    99.downto(0) do |i|
      case i
      when 0
        before = 'no more bottles'
        after = '99 bottles'
      when 1
        before = '1 bottle'
        after = 'no more bottles'
      else
        before = "#{i} bottles"
        after = "#{i - 1} bottles"
      end

      action = if i.zero?
                 'Go to the store and buy some more'
               else
                 'Take one down and pass it around'
               end

      puts "#{before.capitalize} of beer on the wall, #{before} of beer."
      puts "#{action}, #{after} of beer on the wall."
      puts '' unless i.zero?
    end
  end

  def inc
    @cnt += 1
  end
end

hq9plus = HQ9Plus.new(ARGF.read)
hq9plus.run
