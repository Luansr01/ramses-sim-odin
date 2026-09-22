package main

import "core:os"
import "core:fmt"
import "core:bufio"

MEM_SIZE :: 256

RAMSES :: struct {
	mem : [MEM_SIZE]byte,
	regA : byte,
	regB : byte,
	regX : byte,
	ri : byte,
	pc : byte,
	states : byte
}

Error :: enum {
	Invalid_Arguments,
	File_Not_Found,
	File_Not_Valid,
}

error_strings := [Error]string {
	Error.Invalid_Arguments = "Error: Invalid Arguments.",
	Error.File_Not_Found = "Error: file not found.",
	Error.File_Not_Valid = "Error: file specified is not valid.",
}

throw_err :: proc(err : Error){
	fmt.eprintln(error_strings[err])
}

print_usage :: proc(){
	fmt.println("usage: ramses file")
}

read_mem_file :: proc(buf : ^[MEM_SIZE]byte, filepath : string) -> bool{
	memfile, err := os.open(filepath)
	if(err != nil) {
		throw_err(Error.File_Not_Found)
		return false
	}
	defer os.close(memfile)

	reader : bufio.Reader
	bufio.reader_init_with_buf(&reader, os.to_stream(memfile), buf[:]) 
	bufio.reader_read(&reader, buf[:])

	return true
}

main :: proc(){
	if(len(os.args) < 2) {
		throw_err(Error.Invalid_Arguments)
		print_usage()
		return 
	}	


	ramses : RAMSES

	read_mem_file(&ramses.mem, os.args[1]) 

	return 
}
