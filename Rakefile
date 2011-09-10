
require 'rake'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
require 'find'

EG_DIR = 'examples'
LIB_DIR = 'lib'
PKG_DIR = 'pkg'
RDOC_DIR = 'rdoc'
TEST_DIR = 'test'

GEMSPEC = 'rubug.gemspec'
LICENSE = 'LICENSE'
README = 'README.rdoc'
TT_SRC = File.join( LIB_DIR, 'rubug', 'gdb', 'gdb_response.treetop')
TT_DST = File.join( LIB_DIR, 'rubug', 'gdb', 'gdb_response_parser.rb')
LIB_FILES = Dir.glob( File.join(LIB_DIR, '**', '*.rb') )
TEST_FILES = Dir.glob( File.join(TEST_DIR, '*.rb') )

desc 'Default task (test)'
task :default => [:test]

desc 'Run unit tests'
Rake::TestTask.new('test') do |test|
  test.test_files = TEST_FILES
  test.verbose = true
  test.warning = true
end

desc 'Generate treetop parser grammar'
task :grammar do
  if ( ! File.exists?( TT_DST ) ) ||
    ( File.mtime( TT_SRC ) > File.mtime( TT_DST ) )
    puts "Building treetop grammar #{TT_SRC} -> #{TT_DST}"
    system( 'tt', '-o', TT_DST, TT_SRC )
  end
end

desc 'Generate rdoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'rubug.rb'
  rdoc.options << '--line-numbers'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.options << '--all'
  rdoc.rdoc_files.include(README)
  rdoc.rdoc_files.include(LICENSE)
  rdoc.rdoc_files.include(LIB_FILES)
end

desc 'Clean up rdoc, treetop grammar and gem package'
task :clean do
  puts 'Removing rdoc, treetop grammar, compiled examples and gem'
  FileUtils.rm_r( Dir.glob([ "#{PKG_DIR}/*", "#{RDOC_DIR}/*" ]), :secure => true )
  FileUtils.rm( TT_DST, :force => true )
  system( 'make', '-C', 'examples', 'clean' )
end

desc 'Make example binaries'
task :make do
  system( 'make', '-C', 'examples' )
end

desc 'Set file permissions on lib and examples directories'
task :perms do
  puts "Setting file permissions on #{RDOC_DIR}, #{LIB_DIR}, #{TEST_DIR} and #{EG_DIR}"
  Find.find( RDOC_DIR, LIB_DIR, EG_DIR, TEST_DIR ) do |path|
    perm = FileTest.directory?(path) ? 0755: 0644
    FileUtils.chmod( perm, path ) if File.exists?( path )
  end
  FileUtils.chmod( 0644, LICENSE ) if File.exists?( LICENSE )
  FileUtils.chmod( 0644, README ) if File.exists?( README )
end

spec = eval( File.read GEMSPEC )
task :gem => [ :clean, :grammar, :rdoc, :perms ]
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 

