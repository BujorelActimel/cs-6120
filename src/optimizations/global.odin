package optimizations

import "../cfg"
import "../bril"

/*
    // Pseudocode for removing unused variables
    used: map[str]bool
    for instr in func {
        if instr is asignement {
            used[instr.dest] = false
        }
        elif instr is call {
            for arg in instr.args {
                used[arg] = true // asuming there are no undeclared used vars
            }
        }
    }

    for var in used {
        if not used[var] then eliminate var
    }
*/
remove_unused_vars :: proc(instrs: []bril.Instr) -> []bril.Instr {
    used := make_map(map[string]bool)
    for instr in instrs {
        if instr.dest != "" { // is assignment
            used[instr.dest] = false
        }
        if len(instr.args) > 0 {
            for arg in instr.args {
                used[arg] = true
            }
        }
    }

    new_instructions := make([dynamic]bril.Instr)
    for instr in instrs {
        if instr.dest != "" && !used[instr.dest] {
            continue
        }
        append(&new_instructions, instr)
    }

    return new_instructions[:]
}
