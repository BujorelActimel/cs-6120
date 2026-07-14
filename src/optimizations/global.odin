package optimizations

import "core:slice"
import "../bril"

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

remove_unused_vars_multi_pass :: proc(instrs: []bril.Instr) -> []bril.Instr {
    curr_instr := instrs
    new_instrs := remove_unused_vars(curr_instr)
    for len(new_instrs) != len(curr_instr) {
        curr_instr = slice.clone(new_instrs)
        new_instrs = remove_unused_vars(curr_instr)
    }
    return new_instrs
}
