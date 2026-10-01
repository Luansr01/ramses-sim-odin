package ramses_odin_sim

get_val :: proc(ramses: ^RAMSES, addr_mod: AddressingModes) -> byte {
	switch (addr_mod) {
	case .DIR:
		return ramses.mem[fetch(ramses)]
	case .IND:
		addr := ramses.mem[fetch(ramses)]
		return ramses.mem[addr]
	case .IMM:
		return fetch(ramses)
	case .IDX:
		addr := fetch(ramses) + ramses.regX
		return ramses.mem[addr]
	}
	return 0
}

is_flag :: proc(ramses: RAMSES) -> (neg: bool, zero: bool, carry: bool){
	n, z, c : bool = false, false, false
	if ramses.flags & Flags[.NEG] != 0b00000000 do n = true
	if ramses.flags & Flags[.ZERO] != 0b00000000 do z = true
	if ramses.flags & Flags[.CARRY] != 0b00000000 do c = true
	return n, z, c
}

//TODO: implement flag changes
operations_proctable := #partial #sparse[OperationTypes]proc(ramses: ^RAMSES, op: Operation) {
	.STR = proc(
		ramses: ^RAMSES,
		op: Operation,
	) {ramses.mem[get_reg_ptr(ramses, op.reg)^] = fetch(ramses)},
	.LDR = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = get_val(ramses, op.addr_mod)
	},
	.ADD = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		reg^ += get_val(ramses, op.addr_mod)
	},
	.SUB = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		reg^ += get_val(ramses, op.addr_mod)
	},
	.NEG = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = -reg^
	},
	.OR = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
	},
	.AND = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = reg^ & get_val(ramses, op.addr_mod)	
	},
	.NOT = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = ~reg^
	
	},
	.SHR = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = reg^ >> 1	
	
	},
	.JMP = proc(ramses: ^RAMSES, op: Operation){
		ramses.pc = get_val(ramses, op.addr_mod)	
	},
	.JN = proc(ramses: ^RAMSES, op: Operation) {
		if is_flag(ramses, Flags.NEG){
			ramses.pc = get_val(ramses, op.addr_mod)
		}
	},
	.JZ = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
	
	},
	.JC = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
	
	},
	.JSR = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
	
	},
	.HLT = proc(ramses: ^RAMSES, op: Operation){fetch(ramses);},
}
