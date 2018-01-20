module CycleAnalystLogger

  class Gps
    DEFAULTS = {
      tty: '/dev/ttyUSB0',
      baudrate: 115200
    }

    attr_reader :tty
    attr_reader :baudrate
    attr_reader :serial_io

    def initialize(opts={})
      final_opts = DEFAULTS.merge(opts)
      @tty = final_opts[:tty]
      @baudrate = final_opts[:baudrate]
      @serial_io = SerialPort.new @tty, @baudrate, 8, 1
    end

    def run
      serial_io.each_line.with_index do |line, idx|
        shared_data = line.strip
      end

    end
  end
end
