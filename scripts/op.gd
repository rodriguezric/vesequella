extends Node

var symbol_map = {
    "+": add,
    "-": sub,
    "*": mul,
    "/": div,
}

func add(a, b):
    return a + b

func sub(a, b):
    return a - b

func mul(a, b):
    return a * b

func div(a, b):
    return a / b


