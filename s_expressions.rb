#-------------------------------------------------------------------------------
# Symbolic Expressions
#
# Paul Griffioen 2008
#-------------------------------------------------------------------------------

def parse (string)
  tokens = string.gsub("(", " ( ").gsub(")", " ) ").split
  if tokens.empty? then
    throw "nothing to parse"
  elsif tokens.size == 1 then
    if tokens[0] == "(" or tokens[0] == ")" then
      throw "invalid s-expression: #{string}"
    else
      return tokens[0]
    end
  else
    stack = []
    tokens.each do |x|
      if x == "(" then
        stack.push([])
      elsif x == ")" then
        if stack.empty? then 
          throw "too many closing delimiters"
        else
          nested = stack.pop
          if stack.empty? then 
            return nested
          else
            stack.last << nested
          end
        end
      elsif stack.empty? then 
        throw "opening delimiter expected, not #{x}"
      else
        stack.last << x
      end 
    end
    throw "too few closing delimiters"
  end
end

def pretty (s_exp)
  if s_exp.is_a? Array then 
    "(#{ s_exp.map{|x| pretty(x)}.join(" ") })"
  else
    s_exp
  end
end

