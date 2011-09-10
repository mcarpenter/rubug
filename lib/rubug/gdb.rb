
require 'rubug'

module Rubug

  # The GDB machine interface.
  class Gdb

    require 'shellwords'
    require 'rubygems'
    require 'treetop'

    # Choose one of the two following mechanisms:
    #   - If you're hacking on the grammar then use the first
    #   to include it with having to compile after each change.
    #   - If the grammar is stable then use the second to
    #   include the compiled version (without depending on
    #   rubygems, polyglot and treetop).
    # Use the rake task 'rake grammar' to compile the grammar.
    #
    # Load treetop grammar directly without compilation:
    #require 'polyglot'
    #require 'rubug/gdb/gdb_response'
    #
    # Load compiled treetop grammar:
    require 'rubug/gdb/gdb_response_parser'

    require 'rubug/gdb/exception'
    require 'rubug/gdb/parser'
    require 'rubug/gdb/stackframe'
    require 'rubug/gdb/breakpoint'
    require 'rubug/gdb/cli_map'
    require 'rubug/gdb/event'
    include CliMap

    attr_accessor :call_callbacks, :debug, :response_q
    attr_reader :callbacks, :parser, :pid

    # Convenience class method to invoke a simple command-line
    # shell - useful for testing.
    def self::shell(debug=false)
      gdb = Rubug::Gdb.new
      gdb.debug = debug
      gdb.shell
    end

    # Open connection to GDB instance.
    def initialize(interpreter='mi2')
      @callbacks = []
      @call_callbacks = true
      @parser = GdbResponseParser.new
      @gdb = IO.popen("gdb -n -q --interpreter=#{interpreter}", 'w+')
      @pid = @gdb.pid
      @debug = false
      @response_q = []
      raise ParseException, 'GDB returned invalid initial response' unless receive
    end

    # Write debug message to stderr.
    def write_debug(msg, direction=nil)
      return unless @debug
      prefix = 'rubug: '
      prefix << case direction
      when :send
      '->'
      when :receive
      '<-'
      else
      '  '
      end
      msg.split("\n").each do |line|
        $stderr.puts "#{prefix} [#{line}]"
      end
      $stderr.puts if direction == :receive
    end

    # Send command to GDB and return the response. Parameter
    # command is the literal string that will be sent to the
    # GDB/MI: it may be a command line string or a MI command.
    # If we receive async notifications then save them for
    # later reference in @response_q.
    def command(command, expected_result=:done)
      send(command)
      response = receive_command_response
      raise CommandError.new(response), "Command #{command.inspect} returned `#{response.result}: #{response.message}', expected `#{expected_result}'" unless response.result == expected_result
      response
    end

    # Send command to GDB. Note that this overrides Object#send
    # so if you wish to call that method on a Gdb object,
    # use #__send__ (cf private method #cli).
    def send(command)
      write_debug(command, :send)
      @gdb.puts(command)
    end

    # Return a terminated response from GDB. Note that this
    # response may be an asynchronous notification. Blocks until
    # a complete response has been returned (async response or
    # otherwise).
    def receive
      # Wait for pipe to become available
      loop do
        result = IO.select([@gdb], nil, nil, 1)
        break unless result.nil? || result[0].empty?
      end
      # Receive a complete response
      lines = []
      loop do
        #while line = @gdb.readline
        begin
          line = @gdb.readline
        rescue EOFError
          break
        end
        lines << line
        break if [ "(gdb) \n", "^exit\n" ].include?(line)
      end
      # Parse the response
      response = lines.join
      write_debug(response, :receive)
      parsetree = @parser.parse(response)
      raise ParseException, "Failed to parse response:\n#{response}" unless parsetree
      parsetree
    end

    # Wait for a command response from GDB. Asynchronous
    # notifications that are received before the command response
    # are appended to the response queue (@response_q).
    def receive_command_response
      response = nil
      # Check to see if there is a queued command response and if
      # so return that. Otherwise perform a blocking read on the
      # pipe and loop until we receive a command response.
      qed_command_responses = @response_q.select{ |r| r.command_response? }
      if qed_command_responses.empty?
        loop do
          response = receive
          if response.command_response?
            break
          else
            @response_q << response
          end
        end
      else
        response = qed_command_responses.first
        @response_q.delete(response)
      end
      response
    end

    # Register methods (callbacks) to be invoked from the event
    # loop whenever a response is received from GDB. The method
    # registered should take a two arguments: the Rubug::Gdb
    # instance and the calling Rubug::Event.
    #     def mycallback(gdb, event)
    #       ...
    #     gdb.register(method :mycallback)
    #     gdb.register(lambda {|gdb, event| mycallback(gdb, event)})
    def register_callback(method, conditions={})
      @callbacks << Rubug::Callback.new(method, conditions)
    end

    # Call all of the registered callbacks. Returns an array of
    # results, one entry for each registered callback in the
    # order that they were registered.
    def call_registered_callbacks(event)
      if @call_callbacks
        @callbacks.map { |callback| callback.call(self, event) }
      end
    end

    # Start the event loop. Remain in this loop, processing
    # responses by invoking registered callbacks, until one of
    # them throws an EventLoopException (this can be done by
    # calling #stop_event_loop).
    def start_event_loop
      loop do
        response = receive
        event = Event.create_from_response(response)
        begin
          call_registered_callbacks(event)
        rescue Rubug::EventLoopException => exception
          return exception
        end
      end
    end

    # Stop the event loop by throwing an EventLoopException.
    # Typically called from within a registered
    # response-processing callback. See #register.
    def stop_event_loop
      raise Rubug::EventLoopException
    end

    # Invoke a simple command-line shell.
    def shell
      loop do
        print '> '
        break unless line = gets
        tokens = Shellwords.shellwords(line.chomp)
        next if tokens.empty?
        command = tokens.shift.to_sym
        break if command == :quit
        begin
          puts cli(command, tokens)
        rescue ArgumentError => e # invalid command
          puts "Error: #{e}"
          raise
        rescue NoMethodError => e # unrecognized
          puts "Unknown command `#{command}'"
        rescue Rubug::Gdb::CommandError => e # returned error
          puts "GDB error: #{e}"
        end
      end
    end

    # #method_missing is used to respond to messages that look
    # like GDB command line interface commands (dashes in command
    # line commands are converted to underscores in method names).
    # This functionality is defined in CliMap to prevent polluting
    # this class.
    def method_missing(method, *args, &blk)
      if Rubug::Gdb::CliMap::map_exists?(method)
        cli(method, *args, &blk)
      else
        super
      end
    end

    # Override #responsd_to? in accordance with the new methods
    # added by #method_missing.
    def respond_to?(method)
      Rubug::Gdb::CliMap::map_exists?(method) || super
    end

    # Disassemble a function, file segment or memory interval.
    def disassemble(start, stop=nil)
      # Work out if start arg is:
      #   * Function name (+optional offset)
      #   * File & line number
      #   * Memory address
      # And end arg:
      #   * Line number or file and line number vs. number of lines
      #   * Offset vs. memory address
      # and map to memory address.
      # We will re-use this functionality elsewhere (memory read/write!).
      start_addr = function_address(start)
      end_addr = start_addr + 30
      response = command("-data-disassemble -s #{start_addr} -e #{end_addr} -- 0")
    end

    # Return the (decimal integer) address of the given function.
    # Raises CommandError if the function cannot be resolved,
    # RuntimeError if the response from GDB is unparseable.
    def function_address(function)
      response = command("-data-evaluate-expression &#{function}")
      raise RuntimeError, "Invalid response to address request for function `#{function}'" unless
        response.results[:value] =~ /\A0x([\da-f]+)\s+<#{Regexp.escape(function.to_s)}>\Z/
      $1.to_i(16)
    end

    # Returns the value (decimal integer) of a given register.
    def register(register_name)
      # Get the register index in GDB.
      index = registers.index(register_name.to_sym)
      # Get the value of the register.
      response = command("-data-list-register-values x #{index}")
      values = response.results[:register_values]
      raise RuntimeError, "Register `#{register_name}' contains more than one value" unless values.size == 1
    require 'pp'
    pp values.first
      value_s = values.first[:value]
      # XXX BUG
      # why is this value a string, not itself a hash??
      #{:value=>
      #    "{v4_float = {0x0, 0x0, 0x0, 0x0}, v2_double = {0x0, 0x0}, v16_int8 = {0x0 <repeats 16 times>}, v8_int16 = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}, v4_int32 = {0x0, 0x0, 0x0, 0x0}, v2_int64 = {0x0, 0x0}, uint128 = 0x00000000000000000000000000000000}",
      #       :number=>39}

      case value_s
      when String
        pp value_s.to_i(16)
      else
        pp value_s
      end
    end

    # Return a list of names of all registers available for the
    # current target as symbols.
    def registers
      command('-data-list-register-names').
        results[:register_names].
        map { |reg| reg.to_sym }
    end

    private

    # Command line interface. GDB MI responds directly to CLI
    # commands, but in that case the output comes back as
    # unstructured stream output. The CliMap mapping method converts
    # CLI commands (eg "file foo") to their closest MI equivalent
    # ("-exec-file-and-symbols foo") and returns the structured
    # response. Arguments may be passed as a single string or an
    # array of strings (each of which is a separate argument to
    # the command to be run).
    def cli(command, *args, &blk) # XXX &blk
      if Rubug::Gdb::CliMap::map_exists?(command)
        gdb_command = Rubug::Gdb::CliMap::gdb_command(command, *args)
        if [ :run, :cont, :continue, :c ].include? command.to_sym
          expected_result = :running
        else
          expected_result = :done
        end
        command(gdb_command, expected_result)
      elsif true # XXX method is defined in CliMap
        self.__send__(command, *args)
      else
        raise NoMethodError
      end
    end

  end # Gdb

end # Rubug

