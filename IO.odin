package ramses_odin_sim

import "core:fmt"

clear_scr :: proc() {
	fmt.print("\x1b[2J")
}

clear_line :: proc() {
	fmt.print("\x1b[0K")
}

move_cursor :: proc(x: int, y: int) {
	fmt.printf("\x1b[%v;%vH", y, x)
}

print_usage :: proc() {
	fmt.println("usage: ramses file")
}

print_mem :: proc(mem: [MEM_SIZE][2]byte) {
	fmt.println("MEM|VAL")
	for code, index in mem {
		fmt.printfln("%3v|%2x, %2x", index, code[0], code[1])
	}
}

save_cursor_pos :: proc() {
	fmt.printf("\x1b7")
}

load_cursor_pos :: proc() {
	fmt.printf("\x1b8")
}

print_op :: proc(op: Operation) {
	fmt.printf("OP: %v | ADDR_MOD: %v | REG: %v", op.op_type, op.addr_mod, op.reg)
}

cursor_y := 2
print_ui :: proc(ramses: RAMSES, current_op: Operation) {
	move_cursor(1, 1)

	fmt.printfln(
		"PC:%v\tA:%2x\tB:%2x\tX:%2x\tFLAGS:0b%8b\n",
		ramses.pc,
		ramses.regA,
		ramses.regB,
		ramses.regX,
		ramses.flags,
	)
	move_cursor(1, cursor_y)
	cursor_y += 1
	//clear_line()
	fmt.printf("%v : ", ramses.pc)
	print_op(current_op)
	fmt.println()
}
