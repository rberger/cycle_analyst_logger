require 'nmea_plus'
require 'pp'

module CycleAnalystLogger

  class Gps
    DEFAULTS = {
      tty: '/dev/ttyUSB0',
      baudrate: 115200
    }

    attr_reader :tty
    attr_reader :baudrate
    attr_reader :serial_io
    attr_reader :pre_data
    attr_reader :shared_data
    attr_reader :source_decoder

    def initialize(shared_data, opts = {})
      final_opts = DEFAULTS.merge(opts)
      @tty = final_opts[:tty]
      @baudrate = final_opts[:baudrate]
      @serial_io = SerialPort.new @tty, @baudrate, 8, 1
      @pre_data = {}
      @shared_data = shared_data
      @source_decoder = NMEAPlus::SourceDecoder.new(@serial_io)
    end

    def run
      source_decoder.each_complete_message do |message|
        case message.data_type
        when 'GNGGA'
          pre_data[:time] = message.fix_time
          pre_data[:altitude] = message.altitude
          pre_data[:dgps_station_id] = message.dgps_station_id
          pre_data[:fix_quality] = message.fix_quality
          pre_data[:geoid_height] = message.geoid_height
          pre_data[:horizontal_dilution] = message.horizontal_dilution
          pre_data[:latitude] = message.latitude
          pre_data[:longitude] = message.longitude
          pre_data[:satellites] = message.satellites
          pre_data[:seconds_since_last_update] = message.seconds_since_last_update
        when 'GNVTG'
          pre_data[:faa_mode] = message.faa_mode
          pre_data[:speed_kmh] = message.speed_kmh
          pre_data[:speed_knots] = message.speed_knots
          pre_data[:track_degrees_magnetic] = message.track_degrees_magnetic
          pre_data[:track_degrees_true] = message.track_degrees_true
          # Has to be a copy since shared_data is really a reference to an
          # instance variable in the outer thread.
          pre_data.each_pair { |k,v| shared_data[k] = v}
        else
          next
        end
      end
    end
  end
end
