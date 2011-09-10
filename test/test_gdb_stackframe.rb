require 'rubug/gdb/stackframe'
require 'test/unit'

class TestStackframe < Test::Unit::TestCase

  def test_constructor_valid
    assert_nothing_raised {
      Rubug::Gdb::Stackframe.new(
        :addr => true,
        :args => true,
        :file => true,
        :from => true,
        :fullname => true,
        :func => true,
        :level => true,
        :line  => true)
    }
  end

  def test_constructor_invalid
    assert_raise(ArgumentError) {
      Rubug::Gdb::Stackframe.new(:invalid => true)
    }
  end

end

