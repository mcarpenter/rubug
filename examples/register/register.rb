#!/usr/bin/env ruby

# Load the program register and display the registers.

require 'rubug/gdb'

EXE = 'register'

gdb = Rubug::Gdb.new
resp = gdb.file EXE
puts "File #{EXE} loaded"
gdb.break(:main)
gdb.run

puts 'Registers:'
registers = gdb.registers
puts registers.inspect
registers.each do |reg|
  puts "#{reg}: #{gdb.register(reg)}"
end
gdb.quit

