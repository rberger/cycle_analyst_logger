require 'rubyserial'

module CycleAnalystLogger
  class CycleAnalyst
    attr_reader :baudrate
    attr_reader :tty
    attr_reader :dict
    attr_reader :serial_io
    
    CA_DICT = {
      0 => {address: 0, name: "Amp Hours", units: "Ah", scale: 1},
      1 => { address: 1, name: "Volts", units: "V", scale: 1 },
      2 => { address: 2, name: "Current", units: "A", scale: 1},
      3 => { address: 3, name: "Speed", units: "Kph", scale: 1},
      4 => { address: 4, name: "Distance", units: "Km", scale: 1},
      5 => { address: 5, name: "Motor Temp", units: "DegC", scale: 1},
      6 => { address: 6, name: "Human Cadence", units: "RPM", scale: 1},
      7 => { address: 7, name: "Human Power", units: "W", scale: 1},
      8 => { address: 8, name: "Human Torque", units: "Nm", scale: 1},
      9 => { address: 9, name: "Throttle In", units: "V", scale: 1},
      10 => { address: 10, name: "Throttle Out", units: "V", scale: 1},
      11 => { address: 11, name:  "Acceleration", units: "", scale: 1},
      12 => { address: 12, name: "Limit Flags", units: "preset #, Thr Fault, Ebrake, LVC, Limit flags", scale: 1}
    }

    def initialize(opts)
      @baudrate = opts[:baudrate]
      @tty = opts[:tty]
      @dict = CA_DICT
      @serial_io = Serial.new @tty, @baudrate
    end

    # Get line from serial port and send to file
    # @param output_fd [File] File Descriptor of the output file to write to. Don't write to file if nil
    # @param line_count [Integer, Symbol] Number of lines to output, or forever if :forever
    # @param quite [Boolean] Don't output to stdout if true
    def get_logs(output_fd, line_count, quiet)
      line_number = 0
      serial_io.each_line do |line|
        puts line if not quiet
        output_fd.puts line if output_fd

        # Determine if we go forever
        if not (line_count != :forever)
          # If not, then quit when we reach count lines
          line_number +=1
          break if line_number >= line_count
        end
      end
    end
  end
end
