#Load s_expressions for pretty(array) & parse(string)
require_relative 's_expressions'

#constants defined by the assignment
$rule_pattern = parse('(?lhs -> ?rhs)')


#----------------------------------------------------------------------
# Author
# A quick and dirty term rewriting system by Kevin Bankersen
# The term rewriting system, run-assignment calls these functions.
#----------------------------------------------------------------------


#A1 - Assignment

#Reverse an input string
def reverse_s_exp(exp_to_reverse)

  #Parse the expression and apply .reverse to the returned array
  reversed_expression = parse(exp_to_reverse).reverse

  #return a pretty string
  return pretty(reversed_expression)

end

#A2 - Assignment

#Reverse an input string using recursion
def reverse_s_exp_rec(exp_to_reverse)

  #Parse the input string to an array
  parsed_expression = parse(exp_to_reverse)

  #Check if the parsed array is valid
  if parsed_expression.is_a? Array

    #Parse every element of the array
    parsed_expression.each do |expression|

      #Recursive call
      pretty(reverse_s_exp_rec(pretty(expression)))
    end

    #Reverse the expression then return it pretty printed
    return pretty(parsed_expression.reverse)

    #parsed_expression is not an array (end of parse)
  else

    #Return the input string
    return exp_to_reverse

  end
end

#B1 - Assignment

#Test if symbol is a substitution variable
def variable?(s_exp)

  if s_exp.is_a? String

    #Returns true if the first character of the string is a "?"
    s_exp[0] == ??

  end

end

#Replaces parts of an expression with data from a hash-map
def substitute (s_exp, map)

  #Check if the parsed array is valid
  if s_exp.is_a? Array

    #Map every element of the array
    s_exp.map! do |selected_expression|

      #Trying to parse the element of the array again
      selected_expression = (substitute (selected_expression), map)


    end


    #Return the substituted expression to the caller.
    #return pretty(s_exp)
    return s_exp

  elsif variable? (s_exp)
    return map[s_exp]

  else

    #Return the original string
    return s_exp

  end
end

#C1 - Assignment

def match(x, s_exp)

  #start matching
  match_rec(x, s_exp, {})

end

def match_rec(x, s_exp, m)

  #check for arrays
  if x.is_a? Array and s_exp.is_a? Array

    #Match the array
    match_array(x, s_exp, m)

    #test if x is a variable (starts with ?*)
  elsif variable?(x)

    #check variable or add a new one to the hash-map
    match_var(x, s_exp, m)

    #if x and s_exp have the same value
  elsif x==s_exp

    #return the hash-map
    return m

    #if non of the above the input is invalid
  else
    return nil
  end
end

def match_var(x, s_exp, m)

  #Check if the key x is present in the hash-map
  if m.has_key?(x)

    #Return the value associated with the key x.
    match_rec(m[x], s_exp, m)

    #Key x is not present in the hash-map
  else

    #Add key x with the value of s_exp to the hash map
    m[x] = s_exp

    #return the new hash-map
    return m
  end
end

def match_array(x, s_exp, m)

  #filter out empty arrays
  if x.empty? and s_exp.empty?

    #return the hash-map
    return m

  else

    #match the first element of the array
    map = match_rec(x.first, s_exp.first, m)


    #if map is valid
    if map

      #recursive call with processed elements dropped
      match_array(x.drop(1), s_exp.drop(1), map)
    else
      return nil
    end
  end
end

#D1 - Assignment

def parse_rules (file_name)

  #read every rule in the file
  File.open(file_name).readlines.map do |x|

    #match the rules with the pattern
    m=match($rule_pattern, parse(x.chomp))

    #if match is successful
    if m

      #return an array with a left- & right-hand side
      [m['?lhs'], m['?rhs']]

    else
      throw "Invalid rule: #{pretty(x)}"
    end
  end
end

def try_rules(expr, rules)

    #if there are still rules present
    if !rules.empty?

      #match left-hand side (rules[0][0]) with the expression
      m = match(rules[0][0], expr)

      #if left-hand side and expression match
      if m

        #substitute right-hand side (rules[0][1]) with the hash-map
        return substitute(rules[0][1], m)

      #if there is no match try next rule
      else

        #call recursively without the recently used rule
        try_rules(expr, rules.drop(1))
      end
    #if there are no rules left, none of the rules matched the expression
    else
      return nil
    end
end

#D2 - Assignment
def rewrite_parts(exp, rules)

  unary_term = parse('(?op ?x)')
  binary_term = parse('(?x ?op ?y)')

  m = match(unary_term, exp)
  if m
    x_result = rewrite(m['?x'],rules)
    return substitute(unary_term, m.merge({'?x' => x_result}))

  else
    m = match(binary_term, exp)
    if m
      #recursion sometimes breaks the rules on deep levels.
      rules = parse_rules('Leibniz.rules')
      x_result = rewrite(m['?x'],rules)
      y_result = rewrite(m['?y'],rules)
      return substitute(binary_term, m.merge({'?x' => x_result, '?y' => y_result}))
    else
      exp
    end
  end
end

def rewrite(exp, rules)

  if exp.is_a? Array and exp.length > 0

    reddex = rewrite_parts(exp, rules)

    nn = try_rules(reddex, rules)

    if nn.is_a? Array
    return rewrite(nn, rules)
    elsif nn.is_a? String
    return  nn
    end

    return reddex
    end

  return exp
end


#D3 - Assignment

def deriv(s_exp)
  pretty(rewrite(parse(s_exp), parse_rules('Leibniz.rules')))
end