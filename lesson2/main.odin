package main

import "core:slice"
import "core:os"
import "core:fmt"
import "core:encoding/json"

Argument :: struct {
    name: string,
    type: json.Value,
}

Instr :: struct {
    label:  string,
    op:     string,
    dest:   string,
    type:   json.Value,  // optional; absent on effect ops and labels
    value:  json.Value,  // only on const
    args:   []string,
    funcs:  []string,
    labels: []string,
}

Function :: struct {
    name:   string,
    args:   []Argument,
    type:   json.Value,  // optional return type
    instrs: []Instr,
}

Program :: struct {
    functions: []Function,
}

Block :: struct {
    label: string,
    instrs: []Instr,
}

TERMINATORS : []string = {"jmp", "br", "ret"}

main :: proc() {
    data, err := os.read_entire_file_from_file(os.stdin, context.allocator)
    if err != nil {
        return
    }

    program: Program
    if jerr := json.unmarshal(data, &program); jerr != nil {
        fmt.eprintln("json error:", jerr)
        return
    }

    fmt.println(program)
}

get_blocks :: proc(instrs: []Instr) -> []Block {
    blocks := make([dynamic]Block)
    curr_instrs := make([dynamic]Instr)
    curr_label := fmt.aprintf("block-%d", len(curr_instrs))

    for instr in instrs {
        if instr.label != "" { 
            // label instruction
        }
        if slice.contains(TERMINATORS, instr.op) {
            // terminal instruction
        }
    }

    return blocks[:]
}
