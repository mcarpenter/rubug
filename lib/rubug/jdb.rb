
require 'rubug'

module Rubug

  # Java debugger
  # See the Java Platform Debugger Architecture:
  # http://java.sun.com/j2se/1.3/docs/guide/jpda/index.html
  #
  # Could use the Java Debug Interface via jruby:
  # http://java.sun.com/j2se/1.3/docs/guide/jpda/jdi/index.html
  #
  # Or re-write wire-protocol classes, Java Debug Wire Protocol:
  # http://java.sun.com/j2se/1.3/docs/guide/jpda/jdwp-spec.html

  class Jdb

    attr_accessor :debug
    attr_reader :jdb

    def initialize(host, port=8000)
      @jdb = nil
      @debug = false
    end

  end # Jdb

end # Rubug

