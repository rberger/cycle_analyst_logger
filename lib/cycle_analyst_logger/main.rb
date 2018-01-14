require 'gli'

module CycleAnalystLogger
  # Handle Ctl-C exit
  trap "SIGINT" do
    puts "Exiting"
    exit 130
  end

  class Cli
    attr_reader :cycle_analyst
    attr_reader :enable_phaserunner
    attr_reader :pr
    attr_reader :quiet
    attr_reader :loop_count

    include GLI::App

    def main
      program_desc 'Store the streaming data log output of a Grin Cycle Analyst V3 and optionally a Phaserunner'

      version CycleAnalystLogger::VERSION

      subcommand_option_handling :normal
      arguments :strict
      sort_help :manually

      desc 'Cycle Analyst Serial (USB) device'
      default_value '/dev/ttyUSB1'
      arg 'tty', :optional
      flag [:t, :tty_ca]

      desc 'Cycle Analyst Serial port baudrate'
      default_value 9600
      arg 'baudrate', :optional
      flag [:b, :baud_ca]

      desc 'Get PhaseRunner Logs also'
      default_value true
      arg 'enable_phaserunner', :optional
      flag [:enable_phaserunner]

      desc 'Phaserunner Serial (USB) device'
      default_value '/dev/ttyUSB0'
      arg 'tty', :optional
      flag [:tty_pr]

      desc 'Phaserunner Serial port baudrate'
      default_value 115200
      arg 'baudrate', :optional
      flag [:baud_pr]

      desc "How many lines to read"
      default_value :forever
      flag [:l, :loop_count]

      desc 'Do not output to stdout'
      switch [:q, :quiet]

      desc 'Capture the logging output of the Cycle Analyst and optionally Phaserunner to a file'
      command :log do |log|
        log.action do |global_options, options, args|
          filename = "cycle_analyst.#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.csv"
          output_fd = File.open(filename, 'w')
          cycle_analyst.get_logs(output_fd, loop_count, quiet)
        end
      end

      pre do |global,command,options,args|
        # Pre logic here
        # Return true to proceed; false to abort and not call the
        # chosen command
        # Use skips_pre before a command to skip this block
        # on that command only
        @quiet = global[:quiet]
        # Handle that loop_count can be :forever or an Integer
        @loop_count = if global[:loop_count] == :forever
                        Float::INFINITY
                      else
                        global[:loop_count].to_i
                      end
        @enable_phaserunner = global[:enable_phaserunner]
        @cycle_analyst = CycleAnalyst.new(global)
      end

      post do |global,command,options,args|
        # Post logic here
        # Use skips_post before a command to skip this
        # block on that command only
      end

      on_error do |exception|
        # Error logic here
        # return false to skip default error handling
        true
      end

      exit run(ARGV)
    end
  end
end
