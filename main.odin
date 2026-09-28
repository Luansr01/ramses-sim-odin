package ramses_odin_sim

import "base:runtime"
import "core:bufio"
import "core:fmt"
import "core:os"
import "core:reflect"
import "core:time"

MEM_SIZE :: 255

RAMSES :: struct {
	mem:    [MEM_SIZE]byte,
	regA:   byte,
	regB:   byte,
	regX:   byte,
	ri:     u8,
	pc:     u8,
	states: byte,
}

OperationTypes :: enum byte {
	NOP = 0b0000,
	HLT = 0b1111,
	STR = 0b0001,
	LDR = 0b0010,
	ADD = 0b0011,
	SUB = 0b0111,
	NEG = 0b1101,
	OR  = 0b0100,
	AND = 0b0101,
	NOT = 0b0110,
	SHR = 0b1110,
	JMP = 0b1000,
	JN  = 0b1001,
	JZ  = 0b1010,
	JC  = 0b1011,
	JSR = 0b1100,
}

valid_operations: [256]bool = false

init_opcode_table :: proc() {
	ti := type_info_of(OperationTypes)
	base_ti := runtime.type_info_base(ti)

	enum_info := base_ti.variant.(reflect.Type_Info_Enum)


	for val in enum_info.values {
		valid_operations[val] = true
	}
	valid_operations[0b0000] = false
	valid_operations[0b1111] = false
}

Registers :: enum byte {
	A = 0b0000,
	B = 0b0001,
	X = 0b0010,
}

AddressingModes :: enum byte {
	DIR = 0b0000,
	IND = 0b0001,
	IMM = 0b0010,
	IDX = 0b0011,
}

Operation :: struct {
	op_type:  OperationTypes,
	addr_mod: AddressingModes,
	reg:      Registers,
}

Error :: enum {
	Invalid_Arguments,
	File_Not_Found,
	File_Not_Valid,
}

error_strings := [Error]string {
	Error.Invalid_Arguments = "Error: Invalid Arguments.",
	Error.File_Not_Found    = "Error: file not found.",
	Error.File_Not_Valid    = "Error: file specified is not valid.",
}

throw_err :: proc(err: Error) {
	fmt.eprintln(error_strings[err])
}

print_usage :: proc() {
	fmt.println("usage: ramses file")
}

read_mem_file :: proc(buf: ^[MEM_SIZE]byte, filepath: string) -> bool {
	memfile, err := os.open(filepath)
	if (err != nil) {
		throw_err(Error.File_Not_Found)
		return false
	}
	defer os.close(memfile)

	reader: bufio.Reader
	bufio.reader_init_with_buf(&reader, os.to_stream(memfile), buf[:])
	bufio.reader_read(&reader, buf[:])

	return true
}

fetch :: proc(ramses: ^RAMSES) -> byte {
	if (ramses.pc >= MEM_SIZE) {ramses.pc = 0}
	mem := ramses.mem[ramses.pc]
	ramses.pc += 1
	return mem
}

fetch_instruction :: proc(ramses: ^RAMSES) {
	ramses.ri = fetch(ramses)
}

get_reg_ptr :: proc(ramses: ^RAMSES, reg: Registers) -> ^byte {
	switch (reg) {
	case .A:
		return &ramses.regA
	case .B:
		return &ramses.regB
	case .X:
		return &ramses.regX
	}

	return nil
}

parse_addr_mode :: proc(raw_code: byte) -> AddressingModes {
	addr_code := raw_code & 0b00000011
	switch (addr_code) {
	case addr_code & 0b00000001:
		return AddressingModes.IND
	case addr_code & 0b00000010:
		return AddressingModes.IMM
	case addr_code & 0b00000011:
		return AddressingModes.IDX
	case:
		return AddressingModes.DIR
	}
}

validate_op :: proc(raw_code: byte) -> bool {
	opcode: byte = raw_code & 0b11110000
	opcode = opcode >> 4
	return valid_operations[opcode]
}

//TODO:
parse_op :: proc(raw_code: byte) -> OperationTypes {
	opcode: byte = raw_code & 0b11110000
	opcode = opcode >> 4
	return OperationTypes(opcode)
}

parse_register :: proc(raw_code: byte) -> (reg: Registers, ok: bool) {
	reg_code: byte = raw_code & 0b00001100
	switch reg_code {
	case reg_code & 0b00000001:
		return Registers.B, true
	case reg_code & 0b00000010:
		return Registers.X, true
	case reg_code & 0b00000011:
		return nil, false
	case reg_code:
		return Registers.A, true
	}
	return nil, false
}

decode :: proc(ramses: RAMSES) -> (op: Operation, ok: bool) {
	raw_code := ramses.ri
	if !validate_op(raw_code) do return Operation{OperationTypes.NOP, nil, nil}, true

	new_op: Operation
	new_op.op_type = parse_op(raw_code)
	new_op.addr_mod = parse_addr_mode(raw_code)
	new_op.reg = parse_register(raw_code) or_return

	return new_op, true
}

exec :: proc(ramses: ^RAMSES, op: Operation) {
	operations_proctable[op.op_type](ramses, op)
}

print_mem :: proc(mem: [MEM_SIZE]byte) {
	fmt.println("MEM|VAL")
	for code, index in mem {
		fmt.printfln("%3v|%v", index, code)
	}
}

main :: proc() {
	init_opcode_table()

	fmt.println("Checking arguments...")
	if (len(os.args) < 2) {
		throw_err(Error.Invalid_Arguments)
		print_usage()
		return
	}


	fmt.println("Reading .mem file...")
	ramses: RAMSES
	read_mem_file(&ramses.mem, os.args[1])

	//print_mem(ramses.mem)

	current_op: Operation
	for (current_op.op_type != OperationTypes.HLT) {
		fetch_instruction(&ramses)
		current_op, _ = decode(ramses)
		fmt.println(current_op)
		if (current_op.op_type != OperationTypes.NOP) {
			exec(&ramses, current_op)
		}
		time.sleep(500 * time.Millisecond)
	}


	return
}
