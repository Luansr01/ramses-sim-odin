package ramses_odin_sim

import "base:runtime"
import "core:bufio"
import "core:fmt"
import "core:io"
import "core:os"
import "core:reflect"
import "core:time"

MEM_SIZE :: 256

RAMSES :: struct {
	mem:    [MEM_SIZE]byte,
	regA:   byte,
	regB:   byte,
	regX:   byte,
	ri:     u8,
	pc:     u8,
	flags: byte,
}

OperationTypes :: enum byte {
	NOP = 0b00000000,
	HLT = 0b11110000,
	STR = 0b00010000,
	LDR = 0b00100000,
	ADD = 0b00110000,
	SUB = 0b01110000,
	NEG = 0b11010000,
	OR  = 0b01000000,
	AND = 0b01010000,
	NOT = 0b01100000,
	SHR = 0b11100000,
	JMP = 0b10000000,
	JN  = 0b10010000,
	JZ  = 0b10100000,
	JC  = 0b10110000,
	JSR = 0b11000000,
}

FlagID :: enum byte{
	NEG,
	ZERO,
	CARRY,
}

Flags :: [FlagID]byte{
	.NEG 	= 0b00000001,
	.ZERO 	= 0b00000010,
	.CARRY	= 0b00000100,
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
	A = 0b00000000,
	B = 0b00000100,
	X = 0b00001000,
}

AddressingModes :: enum byte {
	DIR = 0b00000000,
	IND = 0b00000001,
	IMM = 0b00000010,
	IDX = 0b00000011,
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


read_mem_file :: proc(mem: ^[MEM_SIZE]byte, filepath: string) -> bool {
	memfile, err := os.open(filepath)
	if (err != nil) {
		throw_err(Error.File_Not_Found)
		return false
	}
	defer os.close(memfile)

	buf: [MEM_SIZE]byte

	reader: bufio.Reader
	bufio.reader_init_with_buf(&reader, os.to_stream(memfile), buf[:])

	bufio.reader_discard(&reader, 4)

	for i in 0 ..< MEM_SIZE {
		mem[i], _ = bufio.reader_read_byte(&reader)
		//fmt.println(i, mem[i])
		bufio.reader_discard(&reader, 1)
	}

	//bufio.reader_read(&reader, buf[:])

	return true
}

fetch :: proc(ramses: ^RAMSES) -> byte {
	if (cast(int)ramses.pc >= MEM_SIZE) {ramses.pc = 0}
	mem := ramses.mem[ramses.pc]
	ramses.pc += 1
	//fmt.printfln("%v, %#b, %v", decode(ramses^, mem), mem, mem)
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
	case 0b00000001:
		return AddressingModes.IND
	case 0b00000010:
		return AddressingModes.IMM
	case 0b00000011:
		return AddressingModes.IDX
	case 0b00000000:
		return AddressingModes.DIR
	}
	return nil
}

validate_op :: proc(raw_code: byte) -> bool {
	opcode: byte = raw_code & 0b11110000
	return valid_operations[opcode]
}

parse_op :: proc(raw_code: byte) -> OperationTypes {
	opcode: byte = raw_code & 0b11110000
	return OperationTypes(opcode)
}

parse_register :: proc(raw_code: byte) -> Registers {
	reg_code: byte = raw_code & 0b00001100
	switch reg_code {
	case 0b00000100:
		return Registers.B
	case 0b00001000:
		return Registers.X
	case 0b00001100:
		return nil
	case 0b00000000:
		return Registers.A
	}
	return nil
}

decode :: proc(ramses: RAMSES, test: byte = 0) -> Operation {
	raw_code := ramses.ri
	if !validate_op(raw_code) do return Operation{OperationTypes.NOP, nil, nil}

	new_op: Operation
	new_op.op_type = parse_op(raw_code)
	new_op.addr_mod = parse_addr_mode(raw_code)
	new_op.reg = parse_register(raw_code)

	return new_op
}

exec :: proc(ramses: ^RAMSES, op: Operation) {
	operations_proctable[op.op_type](ramses, op)
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

	clear_scr()

	current_op: Operation
	for (current_op.op_type != .HLT) {
		fetch_instruction(&ramses)
		current_op = decode(ramses)
		print_ui(ramses, current_op)
		if (current_op.op_type != OperationTypes.NOP) {
			exec(&ramses, current_op)
		}
		time.sleep(50 * time.Millisecond)
	}


	return
}
