package cfg

import "../bril"

Block :: struct {
    label: string,
    instrs: []bril.Instr,
}

CFG :: map[string][]string
