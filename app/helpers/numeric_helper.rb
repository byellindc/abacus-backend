module NumericHelper
  def simplify_number(num)
    if !num.is_a? Numeric
      return num
    elsif num == num.to_i
      return num.to_i
    else
      return num.to_f
    end
  end

  def strip_non_numeric(input)
    input.gsub(/[^[:digit:]]/, '')
  end
end