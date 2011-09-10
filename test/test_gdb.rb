require 'rubug/gdb'
require 'test/unit'

class TestGdb < Test::Unit::TestCase

  def test_quit
    assert_nothing_raised {
      gdb = Rubug::Gdb.new
      gdb.quit
    }
  end

  def test_run
    assert_nothing_raised {
      gdb = Rubug::Gdb.new
      gdb.file('/bin/true') # binary on Linux!
      gdb.run
      gdb.quit
    }
  end

  def test_non_command
    gdb = Rubug::Gdb.new
    assert_raise(Rubug::Gdb::CommandError) {
      gdb.command(:foo)
    }
  end

  def test_unexpected_command_result
    gdb = Rubug::Gdb.new
    assert_raise(Rubug::Gdb::CommandError) {
      gdb.command('file /bin/true', :stopped)
    }
  end

end

