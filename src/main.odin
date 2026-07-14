package main

import "core:os"
import "core:fmt"
import "core:encoding/json"
import "bril"
import "cfg"
import opt "optimizations"

main :: proc() {
    data, err := os.read_entire_file_from_file(os.stdin, context.allocator)
    if err != nil {
        return
    }

    program: bril.Program
    if jerr := json.unmarshal(data, &program); jerr != nil {
        fmt.eprintln("json error:", jerr)
        return
    }

    for function in program.functions {
        fmt.printfln("For function %s", function.name)

        blocks := cfg.get_blocks(function.instrs)
        cfg_map := cfg.compute_cfg(blocks)

        for block in blocks {
            fmt.printfln("%s ---> %v", block.label, cfg_map[block.label])
        }
    }

    fmt.println("Before opt: ")
    for instr in program.functions[0].instrs {
        fmt.println(instr)
    }
    
    fmt.println("After one pass: ")
    new := opt.remove_unused_vars(program.functions[0].instrs)
    for instr in new {
        fmt.println(instr)
    }

    fmt.println("After multi pass: ")
    new = opt.remove_unused_vars_multi_pass(program.functions[0].instrs)
    for instr in new {
        fmt.println(instr)
    }
}
