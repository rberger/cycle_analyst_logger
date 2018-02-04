require 'gli'

module CycleAnalystLogger
  # Handle Ctl-C exit
  trap "SIGINT" do
    puts "Exiting"
    exit 130
  end

  class Cli
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
      default_value '/dev/cycle_analyst'
      arg 'tty', :optional
      flag [:t, :tty_ca]

      desc 'Cycle Analyst Serial port baudrate'
      default_value 9600
      arg 'baudrate', :optional
      flag [:b, :baud_ca]

      desc 'Get PhaseRunner Logs also'
      default_value true
      switch [:enable_phaserunner]

      desc 'Phaserunner Serial (USB) device'
      default_value '/dev/phaserunner'
      arg 'tty', :optional
      flag [:tty_pr]

      desc 'Phaserunner Serial port baudrate'
      default_value 115200
      arg 'baudrate', :optional
      flag [:baud_pr]

      desc 'Get Gps Logs also'
      default_value true
      switch [:enable_gps]

      desc 'Gps Serial (USB) device'
      default_value '/dev/gps'
      arg 'tty', :optional
      flag [:tty_gps]

      desc 'Gps Serial port baudrate'
      default_value 115200
      arg 'baudrate', :optional
      flag [:baud_gps]

      desc "How many lines to read"
      default_value :forever
      flag [:l, :loop_count]

      desc 'Do not output to stdout'
      switch [:q, :quiet]

      desc 'Log the Cycle Analyst and optionally GPS and Phaserunner to a file'
      command :log do |log|
        log.desc 'Disable writing raw nmea to its own file'
        log.default_value false
        log.switch [:disable_nmea_out]
        log.action do |global_options, options, args|
          cycle_analyst = CycleAnalyst.new(global_options)
          cycle_analyst.get_logs(loop_count, quiet, options[:disable_nmea_out])
        end
      end

      desc 'Transform logs to CA format'
      arg_name 'log_filename'
      command :to_ca_file do |to_ca_file|
        to_ca_file.action do |global_options, options, args|
          log_filename = args[0]
          CycleAnalyst.log_to_ca_file(log_filename)
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
        @enable_gps = global[:enable_gps]
        true
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
