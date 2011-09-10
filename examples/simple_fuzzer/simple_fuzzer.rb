#!/usr/bin/env ruby

# Load the simple_fuzzer binary and execute it repeatedly
# with an ever-growing first command-line argument. Exit
# when we receive a signal (don't care which one but it's
# likely to be SIGSEGV!) and show the stack trace.

require 'rubug/gdb'
require 'pp'

EXE = 'simple_fuzzer'

def handle_signal(gdb, event)
  puts 'Signal received'
  puts 'Backtrace:'
  pp gdb.bt.results[:stack]
  gdb.quit
  exit
end

def handle_exit(gdb, event)
  puts 'Normal exit'
  gdb.stop_event_loop
end

gdb = Rubug::Gdb.new
gdb.debug = true
resp = gdb.file EXE # raises if result != :done
puts "File #{EXE} loaded"
gdb.register_callback(method(:handle_signal), :event => :signal)
gdb.register_callback(method(:handle_exit), :event => :exit)
arg = ''
loop do
  arg << 'a'
  puts "Running command: #{EXE} #{arg}"
  resp = gdb.run arg
  gdb.start_event_loop
  break if arg.length > 5
end

