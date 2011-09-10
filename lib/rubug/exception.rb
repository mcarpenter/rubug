
# Exception raised by Rubug::Gdb.stop_event_loop to break out of loop.
class Rubug::EventLoopException < Exception

  attr_reader :reason

  def initialize(reason=nil)
    @reason = reason
  end

end
