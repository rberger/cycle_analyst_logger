require 'time'
require 'serialport'
require 'phaserunner'

module CycleAnalystLogger
  class CycleAnalyst
    # Cycle Analyst serial port Baudrate
    attr_reader :baudrate

    # Cycle Analyst serial port name
    attr_reader :tty

    # Hash that describes the names, values and units of the Cycle Analyst log data
    attr_reader :dict

    # Handle from the SerialPort object
    attr_reader :serial_io

    # If the phaserunner should be read
    attr_reader :enable_phaserunner

    # Handle of the Phaserunner::Modbus object
    attr_reader :phaserunner

    # If the gps should be read
    attr_reader :enable_gps

    # Handle of the Gps object
    attr_reader :gps

    # Shared data for gps data
    attr_reader :gps_data

    # Hash definition that describes the names, values and units of the Cycle Analyst log data
    CA_DICT = {
      0 => {address: 0, name: "Amp Hours", units: "Ah", scale: 1},
      1 => { address: 1, name: "Volts", units: "V", scale: 1 },
      2 => { address: 2, name: "Current", units: "A", scale: 1},
      3 => { address: 3, name: "Speed", units: "Mph", scale: 1},
      4 => { address: 4, name: "Distance", units: "Miles", scale: 1},
      5 => { address: 5, name: "Motor Temp", units: "DegC", scale: 1},
      6 => { address: 6, name: "Human Cadence", units: "RPM", scale: 1},
      7 => { address: 7, name: "Human Power", units: "W", scale: 1},
      8 => { address: 8, name: "Human Torque", units: "Nm", scale: 1},
      9 => { address: 9, name: "Throttle In", units: "V", scale: 1},
      10 => { address: 10, name: "Throttle Out", units: "V", scale: 1},
      11 => { address: 11, name:  "AuxA", units: "", scale: 1},
      12 => { address: 11, name:  "AuxD", units: "", scale: 1},
      13 => { address: 12, name: "Limit Flags", units: "bit flags", scale: 1}
    }

    # CycleAnalyst New
    def initialize(opts)
      @baudrate = opts[:baud_ca]
      @tty = opts[:tty_ca]
      @dict = CA_DICT
      @serial_io = SerialPort.new @tty, @baudrate, 8, 1
      @enable_phaserunner = opts[:enable_phaserunner]

      if @enable_phaserunner
        @phaserunner = Phaserunner::Modbus.new(
          tty: opts[:tty_pr], baudrate: opts[:baud_pr]
        )
      end

      @enable_gps = opts[:enable_gps]

      if @enable_gps
        @gps_data = {}
        @gps = Gps.new(@gps_data, {tty: opts[:tty_gps], baudrate: opts[:baud_gps]})
      end
    end

    # Forms the proper header line
    # @return [String] of a printable CSV header line
    def log_header
      hdr = dict.map do |(address, node)|
        "#{node[:name]} (#{node[:units]})"
      end
      if enable_phaserunner
        hdr += phaserunner.bulk_log_header.map { |name| "PR #{name}" }
      end

      if enable_gps
        hdr += gps.log_header
      end

      hdr.join(',')
    end

    # Converts a TSV string into an array
    def tsv2array(line)
      line.strip.split("\t")
    end

    # Get line from Cycle Analyst serial port, optionally also the Phaserunner and send to stdout and file
    # @param output_fd [File] File Descriptor of the output file to write to. Don't write to file if nil
    # @param loop_count [Integer, Symbol] Number of lines to output, or forever if :forever
    # @param quite [Boolean] Don't output to stdout if true
    def get_logs(loop_count, quiet)
      filename = "cycle_analyst.#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.csv"
      output_fd = File.open(filename, 'w')

      gps_thread = Thread.new { gps.run } if enable_gps

      line_number = 0
      hdr = %Q(Timestamp,#{log_header})

      puts hdr if not quiet
      output_fd.puts hdr if output_fd

      serial_io.each_line.with_index do |line, idx|
        output = (
          [Time.now.utc.round(10).iso8601(6)] +
          tsv2array(line)
        )

        output += phaserunner.bulk_log_data if enable_phaserunner
        #puts "gps_data: #{gps.log_data.inspect}"
        output += gps.log_data if enable_gps

        output_line = output.flatten.join(',')

        puts output_line unless quiet
        output_fd.puts output_line if output_fd

        break if idx >= loop_count
      end
    end
  end
end
