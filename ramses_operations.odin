package ramses_odin_sim

import "core:fmt"

operations_proctable := #partial #sparse[OperationTypes]proc(ramses: ^RAMSES, op: Operation) {
	.STR = proc(
		ramses: ^RAMSES,
		op: Operation,
	) {ramses.mem[get_reg_ptr(ramses, op.reg)^] = fetch(ramses)},
	.LDR = proc(ramses: ^RAMSES, op: Operation) {},
	.ADD = proc(ramses: ^RAMSES, op: Operation) {},
	.SUB = proc(ramses: ^RAMSES, op: Operation) {},
	.NEG = proc(ramses: ^RAMSES, op: Operation) {},
	.OR = proc(ramses: ^RAMSES, op: Operation) {},
	.AND = proc(ramses: ^RAMSES, op: Operation) {},
	.NOT = proc(ramses: ^RAMSES, op: Operation) {},
	.SHR = proc(ramses: ^RAMSES, op: Operation) {},
	.JMP = proc(ramses: ^RAMSES, op: Operation) {},
	.JN = proc(ramses: ^RAMSES, op: Operation) {},
	.JZ = proc(ramses: ^RAMSES, op: Operation) {},
	.JC = proc(ramses: ^RAMSES, op: Operation) {},
	.JSR = proc(ramses: ^RAMSES, op: Operation) {},
}
