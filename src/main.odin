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
    
    new := opt.remove_unused_vars(program.functions[0].instrs)

    fmt.println("After opt: ")
    for instr in new {
        fmt.println(instr)
    }
}

/*
    // Pseudocode for removing dead assignments (in the context of a single simple block)
    used: map[str]bool
    for instr in block {
        if instr is asignement {
            var = instr.dest
            if var not in used or used[var]:
                used[var] = false
            else:
                eliminate prev assingnment
        }
    }

*/
