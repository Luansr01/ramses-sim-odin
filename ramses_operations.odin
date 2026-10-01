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
	.SUB = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.NEG = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.OR = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.AND = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.NOT = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.SHR = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.JMP = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.JN = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.JZ = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.JC = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.JSR = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
	.HLT = proc(ramses: ^RAMSES, op: Operation) {fetch(ramses)},
}
