package cfg

import "core:slice"
import "core:fmt"
import "../bril"

flush :: proc(blocks: ^[dynamic]Block, curr_instrs: ^[dynamic]bril.Instr, curr_label: ^string) {
    if len(curr_instrs^) == 0 { return }
    if curr_label^ == "" {
        curr_label^ = fmt.aprintf("block-%d", len(blocks^))
    }
    append(blocks, Block{curr_label^, slice.clone(curr_instrs[:])})
    curr_label^ = ""
    clear(curr_instrs)
}

get_blocks :: proc(instrs: []bril.Instr) -> []Block {
    blocks := make([dynamic]Block)
    curr_instrs := make([dynamic]bril.Instr)
    curr_label := ""

    for instr in instrs {
        if instr.label != "" {
            flush(&blocks, &curr_instrs, &curr_label)
            curr_label = instr.label
            continue
        }
        append(&curr_instrs, instr)
        if slice.contains(bril.TERMINATORS, instr.op) {
            flush(&blocks, &curr_instrs, &curr_label)
        }
    }

    flush(&blocks, &curr_instrs, &curr_label)

    return blocks[:]
}

compute_cfg :: proc(blocks: []Block) -> CFG {
    cfg := make(CFG)

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
