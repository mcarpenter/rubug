
# GDB MI exceptions.

module Rubug

  class Gdb

    # Exception for response parsing error.
    class ParseException < Exception ; end

    # Command result was not as expected.
    class CommandError < Exception

      attr_reader :response

      # @response contains the unparseable MI response from GDB.
      def initialize(response)
        @response = response
      end

    end

  end # Gdb

end # Rubug

