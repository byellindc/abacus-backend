class VariableProcessor
  attr_reader :store, :lines

  def initialize(lines = [])
    @store = {}
    @lines = lines
    
    process_lines
    @store.each do |var, value| 
      yield(var, value)
    end
  end
  
  def add_line(line)
    @lines << line
    process_line(line)
    return line
  end

  private

  # if input matches `[VAR] = [EXPRESSION]`
  # extract variable name and expression
  def process_line(line)
    regex = %r{(?<name>\w+)( = )(?<expression>.*$)}
    match = line.input.match(regex)

    if match
      line.name = match.named_captures["name"]
      line.expression = match.named_captures["expression"]
    else
      line.name = line.default_name
    end

    @store[line.name] = line
  end

  def process_lines
    @lines.each {|l| process_line(l)}
  end
end