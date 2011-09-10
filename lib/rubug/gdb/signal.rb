
# A signal.
# XXX Not sure this will ever be used since signals aren't a separate data
# structure in a GDB response, there's just a couple of params, name
# and meaning, at the top level.
class Rubug::Gdb::Signal

  ATTRS = [ :signal_meaning, :signal_name ]
  attr_accessor *ATTRS

  def initialize(opts={})
    @args = []
    opts.each do |k, v|
      raise RuntimeError, "Invalid attibute #{k.inspect} for #{self.class}" unless ATTRS.include?(k)
      instance_variable_set("@#{k}", v) 
    end
  end

  def name
    @signal_name
  end

  def name=(name)
    @signal_name = name
  end

  def meaning
    @signal_meaning
  end

  def meaning=(meaning)
    @signal_meaning = meaning
  end

end

