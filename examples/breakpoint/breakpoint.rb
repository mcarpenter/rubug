#!/usr/bin/env ruby

# Load the factorial program and set a breakpoint on entry to the
# factorial() function (naive tail-recursive implementation).
# Run the program and display the events generated by hitting the
# breakpoint as they occur.

require 'rubug/gdb'
require 'pp'

EXE = 'factorial'

def check_for_crash(gdb, event)
  case event.type
  when :command_response
    raise RuntimeError, 'oops' unless [ :done, :running ].include? event.response.result
  when :breakpoint
    puts 'Breakpoint reached'
    pp event
    gdb.continue
  when :exit
    puts 'Exit'
    gdb.stop_event_loop
    exit
  when :signal
    puts "Signal received:"
    puts event.response
    gdb.stop_event_loop
    exit
  else
    raise RuntimeError, "Unexpected event type #{event.type.inspect}"
  end
end

gdb = Rubug::Gdb.new
#gdb.debug = true
resp = gdb.file EXE # raises if result != :done
puts "File #{EXE} loaded"
gdb.register_callback(method :check_for_crash)
gdb.break(:fac)
gdb.run '5 > /dev/null'
gdb.start_event_loop

