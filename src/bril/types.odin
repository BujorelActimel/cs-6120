package bril

Argument :: struct {
    name: string,
    type: string,
}

Value :: union {
    string,
    bool,
    int,
    f64,
}

Instr :: struct {
    label:  string,
    op:     string,
    dest:   string,
    type:   string,
    value:  Value,
    args:   []string,
    funcs:  []string,
    labels: []string,
}

Function :: struct {
    name:   string,
    args:   []Argument,
    type:   string,
    instrs: []Instr,
}

Program :: struct {
    functions: []Function,
}

TERMINATORS : []string = {"jmp", "br", "ret"}
