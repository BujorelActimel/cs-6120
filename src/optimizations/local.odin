package optimizations

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
