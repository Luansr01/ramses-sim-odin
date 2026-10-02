package ramses_odin_sim

import "core:math/bits"


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

update_flags :: proc(ramses: ^RAMSES, reg : byte, carry : bool, is_carry_mut : bool){
	if is_carry_mut do ramses.flags = 0; else do ramses.flags &= 0b00000001
	if carry do ramses.flags |= Flags[.CARRY]
	if reg == 0 do ramses.flags |= Flags[.ZERO]
	if reg & 0x80 == 1 do ramses.flags |= Flags[.NEG]	
}

is_flag_on :: proc(ramses: RAMSES) -> (neg: bool, zero: bool, carry: bool){
	n, z, c : bool = false, false, false
	if ramses.flags & Flags[.NEG] != 0b00000000 do n = true
	if ramses.flags & Flags[.ZERO] != 0b00000000 do z = true
	if ramses.flags & Flags[.CARRY] != 0b00000000 do c = true
	return n, z, c
}

operations_proctable := #partial #sparse[OperationTypes]proc(ramses: ^RAMSES, op: Operation) {
	.STR = proc(
		ramses: ^RAMSES,
		op: Operation,
	) {ramses.mem[get_reg_ptr(ramses, op.reg)^] = fetch(ramses)},
	.LDR = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = get_val(ramses, op.addr_mod)
		update_flags(ramses, reg^, false, false)
	},
	.ADD = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		result, carry := bits.overflowing_add(reg^, get_val(ramses, op.addr_mod))
		reg^ = result
		update_flags(ramses, result, carry, true)	
	},
	.SUB = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		result, borrow := bits.overflowing_sub(reg^, get_val(ramses, op.addr_mod))
		reg^ = result
		update_flags(ramses, result, !borrow, true)	
	},
	.NEG = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		result, borrow := bits.overflowing_sub(0, reg^)
		reg^ = result
		update_flags(ramses, reg^, !borrow, true)	
	},
	.OR = proc(ramses: ^RAMSES, op: Operation) {
		reg := get_reg_ptr(ramses, op.reg)
		update_flags(ramses, reg^, false, false)
	},
	.AND = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = reg^ & get_val(ramses, op.addr_mod)	
		update_flags(ramses, reg^, false, false)
	},
	.NOT = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		reg^ = ~reg^
		update_flags(ramses, reg^, false, false)
	
	},
	.SHR = proc(ramses: ^RAMSES, op: Operation){
		reg := get_reg_ptr(ramses, op.reg)
		carry := false
		if reg^ & 1 == 1 do carry = true
		reg^ = reg^ >> 1	
	
	},
	.JMP = proc(ramses: ^RAMSES, op: Operation){	
		if op.addr_mod == .IMM {
			get_val(ramses, op.addr_mod)
			return
		}
		ramses.pc = get_val(ramses, op.addr_mod)	
	},
	.JN = proc(ramses: ^RAMSES, op: Operation) {
		if op.addr_mod == .IMM {
			get_val(ramses, op.addr_mod)
			return
		}
		if n, _, _ := is_flag_on(ramses^); n{
			ramses.pc = get_val(ramses, op.addr_mod)
		}
	},
	.JZ = proc(ramses: ^RAMSES, op: Operation) {
		if op.addr_mod == .IMM {
			get_val(ramses, op.addr_mod)
			return
		}
		if _, z, _ := is_flag_on(ramses^); z{
			ramses.pc = get_val(ramses, op.addr_mod)
		}
	},
	.JC = proc(ramses: ^RAMSES, op: Operation) {
		if op.addr_mod == .IMM {
			get_val(ramses, op.addr_mod)
			return
		}
		if _, _, c := is_flag_on(ramses^); c{
			ramses.pc = get_val(ramses, op.addr_mod)
		}
	},
	.JSR = proc(ramses: ^RAMSES, op: Operation){
		if op.addr_mod == .IMM {
			get_val(ramses, op.addr_mod)
			return
		}
		reg := get_reg_ptr(ramses, op.reg)
		val := get_val
		ramses.mem[reg^] = ramses.pc
		ramses.pc = reg^
	},
	.HLT = proc(ramses: ^RAMSES, op: Operation){fetch(ramses);},
}
