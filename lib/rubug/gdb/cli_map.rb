
# Module to map GDB command line commands to MI commands.
module Rubug

  class Gdb

    module CliMap

      # Leave the GDB session.
      # XXX Kill running subordinate process.
      def quit
        response = command('-gdb-exit', :exit)
        Process.waitpid(@pid) if @pid
        @gdb.close
        response
      end

      def info(command, *args)
        subcommand = args.shift.to_sym
        case subcommand
        when :break # information about single breakpoint
          '-break-info' # alternatively, -break-list
        when :frame # information about current stack frame
          cli(:frame)
        when :locals # local variables and values for the this frame
          '-stack-list-locals 1'
        when :thread # current threads
          '-thread-info'
        when :locals # local variables and function arguments and their values for the selected frame
          '-stack-list-variables 1'
        else
          raise ArgumentError, "Unknown subcommand #{subcommand.inspect} for #{command.inspect}"
        end
      end

      def set(command, *args)
        subcommand = args.shift.to_sym
        case subcommand
        when :args
          command("-exec-arguments #{args.shift}")
        else
          raise ArgumentError, "Unknown subcommand #{subcommand.inspect} for #{command.inspect}"
        end
      end

      def show(command, *args)
        raise ArgumentError, "Unimplemented command show"
        # version -> -gdb-version
      end

      # XXX what about flags? (eg -r reverse?)
      CLI_MAP = {
        :+ => { }, # TUI
        :- => { }, # TUI
        :< => { }, # TUI
        :> => { }, # TUI
        :actions => { :* => nil },
        :add_shared_symbol_files => { :* => nil },
        :add_symbol_file => { :* => nil },
        :add_symbol_file_from_memory => { :* => nil },
        :advance => { :* => nil },
        :append => { :* => nil },
        :apropos => { :* => nil },
        :assf => { :* => nil },
        :attach => { :+ => '-target-attach' },
        :awatch => { :* => '-break-watch -a' },
        :backtrace => { 0 => '-stack-list-frames' },
        :break => { :* => '-break-insert' },
        :bt => { 0 => '-stack-list-frames' },
        :c => { :* => '-exec-continue' },
        :call => { :* => nil },
        :catch => { :* => nil },
        :cd => { :* => '-environment-cd' },
        :checkpoint => { :* => nil },
        :clear => { :* => nil },
        :collect => { :* => nil },
        :commands => { :* => '-break-commands' },
        :compare_sections => { :* => nil },
        :complete => { :* => nil },
        :condition => { :* => '-break-condition' },
        :continue => { :* => '-exec-continue' },
        :core => { :* => nil },
        :core_file => { :* => nil },
        :define => { :* => nil },
        :delete => { :* => nil },
        :detach => { :* => '-target-detach' },
        :dir => { 0 => '-environment-directory -r',
          :+ => '-environment-directory' },
        :directory => { :* => nil },
        :disable => { :* => '-break-disable' },
        :disassemble => { :* => nil },
        :disconnect => { 0 => '-target-disconnect' },
        :display => { :* => nil },
        :document => { :* => nil },
        :dont_repeat => { :* => nil },
        :down => { :* => nil },
        :down_silently => { :* => nil },
        :dump => { :* => nil },
        :echo => { :* => nil },
        :edit => { :* => nil },
        :enable => { :* => '-break-enable' },
        :end => { :* => nil },
        :exec_file => { :* => '-file-exec-file' },
        :fg => { :* => '-exec-continue' },
        :file => { 0 => '-file-exec-and-symbols',
          1 => '-file-exec-and-symbols' },
        :finish => { :* => '-exec-finish' },
        :flushregs => { :* => nil },
        :focus => { :* => nil },
        :fork => { :* => nil },
        :forward_search => { :* => nil },
        :frame => { :* => '-stack-info-frame' },
        :fs => { }, # TUI
        :gcore => { :* => nil },
        :generate_core_file => { :* => nil },
        :handle => { :* => nil },
        :hbreak => { :* => '-break-insert -h' },
        :help => { },
        :if => { :* => nil },
        :ignore => { :* => '-break-after' },
        :init_if_undefined => { :* => nil },
        :inspect => { :* => nil },
        :interpreter_exec => { :* => nil },
        :interrupt => { :* => '-exec-interrupt' },
        :jump => { :+ => '-exec-jump' },
        :kill => { :* => nil },
        :layout => { :* => nil },
        :list => { :* => nil },
        :load => { :* => nil },
        :macro => { :* => nil },
        :maintenance => { :* => nil },
        :make => { :* => nil },
        :mem => { :* => nil },
        :monitor => { :* => nil },
        :next => { :* => '-exec-next' },
        :nexti => { :* => '-exec-next-instruction' },
        :ni => { :* => nil },
        :nosharedlibrary => { :* => nil },
        :output => { :* => nil },
        :overlay => { :* => nil },
        :passcount => { :* => '-break-passcount' },
        :path => { 0 => '-environment-path -r', :+ => 'environment-path' },
        :print => { :* => nil },
        :print_object => { :* => nil },
        :printf => { :* => nil },
        :process => { :* => nil },
        :ptype => { :* => nil },
        :pwd => { :* => '-environment-pwd' },
        :rbreak => { :* => nil },
        :refresh => { :* => nil },
        :remote => { :* => nil },
        :restart => { :* => nil },
        :restore => { :* => '-exec-return' },
        :return => { :* => nil },
        :reverse_search => { :* => nil },
        :run => { :* => '-exec-run' }, # :running
        :rwatch => { :* => '-break-watch -r' },
        :save_tracepoints => { :* => nil },
        :search => { :* => nil },
        :section => { :* => nil },
        :select_frame => { :* => nil },
        :sharedlibrary => { :* => nil },
        :shell => { },
        :si => { :* => nil },
        :signal => { :* => nil },
        :source => { :* => nil },
        :start => { :* => nil },
        :step => { :* => '-exec-step' },
        :stepi => { :* => '-exec-step-instruction' },
        :stepping => { :* => nil },
        :stop => { :* => nil },
        :symbol_file => { :* => nil },
        :tabset => { :* => nil },
        :target => { :* => nil },
        :tbreak => { :* => '-break-insert -t' },
        :tcatch => { :* => nil },
        :tdump => { :* => nil },
        :tfind => { :* => nil },
        :thbreak => { :* => '-break-insert -h -t' },
        :thread => { :* => '-thread-select' },
        :tp => { :* => nil },
        :trace => { :* => nil },
        :tstart => { :* => nil },
        :tstatus => { :* => nil },
        :tstop => { :* => nil },
        :tty => { :* => nil },
        :tui => { }, # TUI
        :undisplay => { :* => nil },
        :unset => { :* => nil },
        :until => { :* => '-exec-until' },
        :up => { :* => nil },
        :up_silently => { :* => nil },
        :update => { :* => nil },
        :watch => { :* => '-break-watch' },
        :wh => { :* => nil },
        :whatis => { :* => nil },
        :where => { 0 => '-stack-list-frames' },
        :while => { :* => nil },
        :while_stepping => { :* => nil },
        :winheight => { :* => nil },
        :ws => { :* => nil },
        :x => { :* => nil }
      }

      # Map a GDB command line interface command to its machine
      # interface equivalent.
      def self.gdb_command(command, *args)
        arg_str = args.map(&:to_s).join(' ')
        # NoMethodError: undefined method `foo' for 5:Fixnum
        raise NoMethodError, "undefined method `#{command}' for Rubug::Gdb" unless arg_map = CLI_MAP[command.to_sym]
        if arg_map.empty?
          raise NoMethodError, "method `#{command}' not exported by Rubug::Gdb"
        elsif arg_map[:*]
          cmd = arg_map[:*]
        elsif args.size > 0 && arg_map[:+]
          cmd = arg_map[:+]
        elsif arg_map[args.size]
          cmd = arg_map[args.size]
        else
          # ArgumentError: wrong number of arguments (2 for 0)
          raise ArgumentError, "wrong number of arguments (#{args.size}) for `#{command}'"
        end
        case cmd
        when String
          "#{cmd} #{arg_str}"
        when Method
          cmd.call(command, *args)
        else
          raise RuntimeError, "unknown type #{cmd}"
        end
      end

      # Returns true if the given GDB command line command is
      # recognized, false otherwise.
      def self.map_exists?(command)
        !! CLI_MAP[command.to_sym]
      end

    end # CliMap

  end # Gdb

end # Rubug

