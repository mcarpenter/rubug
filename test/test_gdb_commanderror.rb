require 'rubug/gdb/exception'
require 'test/unit'

class TestCommandError < Test::Unit::TestCase

  def test_constructor_with_response
    e = Rubug::Gdb::CommandError.new('oops')
    assert_equal('oops', e.response)
  end

  def test_constructor_without_response
    assert_raise(ArgumentError) {
      Rubug::Gdb::CommandError.new
    }
  end

end

