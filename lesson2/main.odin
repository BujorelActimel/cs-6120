package main

import "core:slice"
import "core:os"
import "core:fmt"
import "core:encoding/json"

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

    for function in program.functions {
        fmt.printfln("For function %s", function.name)

        blocks := get_blocks(function.instrs)
        cfg := compute_cfg(blocks)

        for block in blocks {
            fmt.printfln("%s ---> %v", block.label, cfg[block.label])
        }
    }
}

flush :: proc(blocks: ^[dynamic]Block, curr_instrs: ^[dynamic]Instr, curr_label: ^string) {
    if len(curr_instrs^) == 0 { return }
    if curr_label^ == "" {
        curr_label^ = fmt.aprintf("block-%d", len(blocks^))
    }
    append(blocks, Block{curr_label^, slice.clone(curr_instrs[:])})
    curr_label^ = ""
    clear(curr_instrs)
}

get_blocks :: proc(instrs: []Instr) -> []Block {
    blocks := make([dynamic]Block)
    curr_instrs := make([dynamic]Instr)
    curr_label := ""

    for instr in instrs {
        if instr.label != "" {
            flush(&blocks, &curr_instrs, &curr_label)
            curr_label = instr.label
            continue
        }
        append(&curr_instrs, instr)
        if slice.contains(TERMINATORS, instr.op) {
            flush(&blocks, &curr_instrs, &curr_label)
        }
    }

    flush(&blocks, &curr_instrs, &curr_label)

    return blocks[:]
}

compute_cfg :: proc(blocks: []Block) -> map[string][]string {
    cfg := make(map[string][]string)

    for block, i in blocks {
        last_instr := block.instrs[len(block.instrs)-1]
        
        if last_instr.op == "jmp" || last_instr.op == "br" {
            cfg[block.label] = last_instr.labels
        }
        else {
            if i == len(blocks)-1 {
                cfg[block.label] = []string{}
                break
            }
            next := make([]string, 1)
            next[0] = blocks[i+1].label
            cfg[block.label] = next
        }
    }
    return cfg
}
