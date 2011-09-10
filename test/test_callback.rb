require 'rubug/callback'
require 'test/unit'

class TestCallback < Test::Unit::TestCase

  def test_method_argument_not_callable
    non_callable_object = Object.new
    assert_raise(ArgumentError) {
      Rubug::Callback.new(non_callable_object)
    }
  end

  def test_method_arity_1
    arity_1_method = lambda{ |x| nil }
    assert_raise(ArgumentError) {
      Rubug::Callback.new(arity_1_method)
    }
  end

  def test_no_conditions_always_called
    cb = Rubug::Callback.new(lambda { |gdb, event| :was_called })
    result = cb.call(nil, nil)
    assert_equal(:was_called, result)
  end

  def test_condition_valid_called
    # Test: ( 'event'.to_sym == :event )
    cb = Rubug::Callback.new(lambda { |gdb, event| :was_called },
                            :to_sym => :event)
    result = cb.call(nil, 'event')
    assert_equal(:was_called, result)
  end

  def test_condition_invalid_not_called
    # Test: ( 'non_event'.to_sym != :event )
    cb = Rubug::Callback.new(lambda { |gdb, event| :was_called },
                            :to_sym => :event)
    result = cb.call(nil, 'non_event')
    assert_nil(result)
  end

  def test_conditions_valid_called
    cb = Rubug::Callback.new(lambda { |gdb, event| :was_called },
                            :to_sym => :event, :upcase => 'EVENT')
    result = cb.call(nil, 'event')
    assert_equal(:was_called, result)
  end

  def test_conditions_invalid_not_called
    cb = Rubug::Callback.new(lambda { |gdb, event| :was_called },
                            :to_sym => :event, :upcase => 'oops')
    result = cb.call(nil, 'event')
    assert_nil(result)
  end

end

