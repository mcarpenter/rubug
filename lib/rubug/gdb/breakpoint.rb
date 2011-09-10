
module Rubug

  class Gdb

    # A GDB breakpoint.
    class Breakpoint

      ATTRS = [
        :addr,
        :at,
        :disp,
        :enabled,
        :file,
        :fullname,
        :func,
        :line,
        :number,
        :times,
        :type
      ]
      attr_accessor(*ATTRS)

      def initialize(opts={})
        @times = 0
        opts.each do |k, v|
          raise ArgumentError, "Invalid attibute #{k.inspect} for #{self.class}" unless ATTRS.include?(k)
          instance_variable_set("@#{k}", v) 
        end
      end

    end

  end # Gdb

end # Rubug
