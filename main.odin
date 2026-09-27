package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:reflect"

MEM_SIZE :: 256

RAMSES :: struct {
	mem:    [MEM_SIZE]byte,
	regA:   byte,
	regB:   byte,
	regX:   byte,
	ri:     u16,
	pc:     u16,
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

valid_operations: [256]bool

init_opcode_table :: proc() {
	enum_info := type_info_of(OperationTypes).variant.(reflect.Type_Info_Enum)
	for val in enum_info.values {
		valid_operations[val] = true
	}
}

Registers :: enum {
	A,
	B,
	X,
}

AddressingModes :: enum byte {
	DIR = 0b0000,
	IND = 0b0001,
	IMM = 0b0010,
	IDX = 0b0011,
}

Operation :: struct {
	op:       OperationTypes,
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

decode :: proc(raw_code: byte) -> Operation {
	new_op: Operation
	new_op.addr_mod = parse_addr_mode(raw_code)

	//TODO: add opcode and register parsing

	return new_op
}

main :: proc() {
	init_opcode_table()

	if (len(os.args) < 2) {
		throw_err(Error.Invalid_Arguments)
		print_usage()
		return
	}


	ramses: RAMSES
	read_mem_file(&ramses.mem, os.args[1])


	return
}
