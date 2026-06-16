# ChatGPT 3 constructed this example to the prompt
# "write me a RPN calculator in python" 
# on 2023/6/9

def rpn_calculator(expression):
    stack = []
    operators = {
        '+': lambda x, y: x + y,
        '-': lambda x, y: x - y,
        '*': lambda x, y: x * y,
        '/': lambda x, y: x / y
    }

    for token in expression.split():
        if token.isdigit():
            stack.append(float(token))
        elif token in operators:
            if len(stack) < 2:
                raise ValueError('Invalid expression')
            y = stack.pop()
            x = stack.pop()
            result = operators[token](x, y)
            stack.append(result)
        else:
            raise ValueError('Invalid token: ' + token)

    if len(stack) != 1:
        raise ValueError('Invalid expression')

    return stack[0]

# Example usage:
expression = '3 4 + 5 *'
result = rpn_calculator(expression)
print(f'Result: {result}')
