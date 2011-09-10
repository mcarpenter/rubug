require 'rubug/gdb/breakpoint'
require 'test/unit'

class TestBreakpoint < Test::Unit::TestCase

  def test_constructor_valid
    assert_nothing_raised {
      Rubug::Gdb::Breakpoint.new(
        :addr => true,
        :at => true,
        :disp => true,
        :enabled => true,
        :file => true,
        :fullname => true,
        :func => true,
        :line => true,
        :number => true,
        :times => true,
        :type => true)
    }
  end

  def test_constructor_invalid
    assert_raise(ArgumentError) {
      Rubug::Gdb::Breakpoint.new(:invalid => true)
    }
  end

end

