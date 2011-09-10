
# A GDB stack frame.
module Rubug

  class Gdb

    class Stackframe

      ATTRS = [ :addr, :args, :file, :from, :fullname, :func, :level, :line ]
      attr_accessor(*ATTRS)

      def initialize(opts={})
        @args = []
        opts.each do |k, v|
          raise ArgumentError, "Invalid attibute #{k.inspect} for #{self.class}" unless ATTRS.include?(k)
          instance_variable_set("@#{k}", v) 
        end
      end

    end # Stackframe

  end # Gdb

end # Rubug

