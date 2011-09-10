#!/usr/bin/env ruby

# Load the program function_address and display the addresses
# of the main() and foo() functions. Function foo() prints
# the value of global (external) variable errno to stdout,
# yet we cannot obtain its address.

require 'rubug/gdb'

EXE = 'function_address'

gdb = Rubug::Gdb.new
resp = gdb.file EXE
puts "File #{EXE} loaded"
puts "Address of main(): " + gdb.function_address(:main).to_s
puts "Address of foo():  " + gdb.function_address(:foo).to_s
puts "Address of errno:  " + gdb.function_address(:errno).to_s # oops!
gdb.quit

