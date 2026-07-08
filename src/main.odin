package main

import "core:os"
import "core:fmt"
import "core:encoding/json"
import "bril"
import "cfg"

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
}


/*
    // Pseudocode for removing unused variables
    used: map[str]bool
    for instr in func {
        if instr is asignement {
            used[instr.dest] = false
        }
        elif instr is call {
            for arg in instr.args {
                used[arg] = true // asuming there are no undeclared used used
            }
        }
    }

    for var in used {
        if not used[var] then eliminate var
    }
*/

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
