require 'gli'

module CycleAnalystLogger

  class Cli
    attr_reader :ca

    include GLI::App

    def main
      program_desc 'Store the streaming data log output of a Grin Cycle Analyst V3'

      version CycleAnalystLogger::VERSION

      subcommand_option_handling :normal
      arguments :strict
      sort_help :manually

      desc 'Serial (USB) device'
      default_value '/dev/ttyUSB1'
      arg 'tty', :optional
      flag [:t, :tty]

      desc 'Serial port baudrate'
      default_value 9600
      arg 'baudrate', :optional
      flag [:b, :baudrate]

      desc 'Do not output to stdout'
      switch [:q, :quiet]

      desc 'Capture the logging output of the CA to a file'
      command :log do |log|
        log.desc "How many lines to read"
        log.default_value :forever
        log.flag [:l, :line_count]

        log.action do |global_options, options, args|
          quiet = global_options[:quiet]
          line_count = options[:line_count]
          output_fd = File.open("cycle_analyst.#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.csv", 'w')
          ca.get_logs(output_fd, line_count, quiet)
        end
      end

      pre do |global,command,options,args|
        # Pre logic here
        # Return true to proceed; false to abort and not call the
        # chosen command
        # Use skips_pre before a command to skip this block
        # on that command only
        @ca = CycleAnalyst.new(global)
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
