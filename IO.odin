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

print_mem :: proc(mem: [MEM_SIZE]byte) {
	fmt.println("MEM|VAL")
	for code, index in mem {
		fmt.printfln("%3v|%v", index, code)
	}
}

save_cursor_pos :: proc() {
	fmt.printf("\x1b7")
}

load_cursor_pos :: proc() {
	fmt.printf("\x1b8")
}

print_op :: proc(op: Operation) {
	fmt.println(op)
}

cursor_y := 2
print_ui :: proc(ramses: RAMSES, current_op: Operation) {
	move_cursor(1, 1)

	fmt.printfln(
		"PC:%v|A:%v|B:%v|X:%v|STATES:%v\n",
		ramses.pc,
		ramses.regA,
		ramses.regB,
		ramses.regX,
		ramses.states,
	)
	move_cursor(1, cursor_y)
	cursor_y += 1
	//clear_line()
	print_op(current_op)
}
