Gem::Specification.new do |s| 
  s.add_dependency('treetop')
  s.authors = [ 'Martin Carpenter' ]
  s.date = Time.now.strftime('%Y-%m-%d')
  s.description = s.summary # XXX
  s.email = 'mcarpenter@free.fr'
  s.extra_rdoc_files = %w{ LICENSE Rakefile README }
  s.files = FileList[ 'examples/**/*', 'lib/**/*', 'test/**/*' ].to_a
  s.has_rdoc = true
  s.homepage = 'http://mcarpenter.org/projects/rubug'
  s.licenses =  [ 'BSD' ]
  s.name = 'rubug'
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = nil
  s.summary = 'A programmatic debugger interface'
  s.test_files = FileList[ "{test}/**/*test.rb" ].to_a
  s.version = '0.0.1'
end
 
