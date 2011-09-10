module Rubug

  # Callback objects are lambdas with an associated set of conditions.
  class Callback

    attr_reader :conditions, :method

    # Create a callback object. The method is a lambda and conditions
    # is an optional hash of method (symbol) and result (single value
    # or array) pairs that determines whether or not the callback
    # should be called for the given event: the method will be sent
    # to the event object (see #call) and the result of this should
    # be equal to or included in the condition for it to hold. All
    # conditions must hold (ie a conjunction) for the callback to be
    # called.
    def initialize(method, conditions={})
      # Ensure method is callable
      raise ArgumentError, 'Callback method is not callable' unless method.respond_to? :call
      raise ArgumentError, 'Callback method is not arity 2' unless method.arity == 2
      @method = method
      @conditions = conditions
    end

    # Invoke the callback with the given debugger and event instances
    # if the conditions all hold. If one or more conditions do not
    # hold then return nil.
    def call(gdb, event)
      should_call = true
      @conditions.each do |property, value|
        should_call &&= [ value ].flatten.include?( event.send(property) )
        break unless should_call
      end
      should_call ? @method.call(gdb, event) : nil
    end

  end # Callback

end # Rubug

