#!/usr/bin/env ruby

# Load the program disassemble and display the addresses
# of the main() and foo() functions and their disassembly.

require 'pp'
require 'rubug/gdb'

EXE = 'disassemble'

gdb = Rubug::Gdb.new
resp = gdb.file EXE
puts "File #{EXE} loaded"
puts "Address of main(): " + gdb.function_address(:main).to_s
puts "Disassembly:"
pp gdb.disassemble(:main)
puts "Address of foo():  " + gdb.function_address(:foo).to_s
puts "Disassembly:"
pp gdb.disassemble(:foo)
gdb.quit

