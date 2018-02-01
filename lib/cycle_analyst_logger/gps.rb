require 'nmea_plus'
require 'pp'

module CycleAnalystLogger

  class Gps
    DEFAULTS = {
      tty: '/dev/gps',
      baudrate: 115200
    }

    GPS_DICT = {
      0 => {address: 0, name: 'Time', key: :time, units: nil, scale: 1},
      1 => {address: 1, name: 'Latitude', key: :latitude, units: 'degrees', scale: 1},
      2 => {address: 2, name: 'Longitude', key: :longitude, units: 'degrees', scale: 1},
      3 => {address: 3, name: 'Altitude', key: :altitude, units: 'meters', scale: 1},
      4 => {address: 4, name: 'Speed', key: :speed, units: 'kph', scale: 1},
      5 => {address: 5, name: 'Fix Quality', key: :fix_quality, units: nil, scale: 1},
      6 => {address: 6, name: 'Satellites', key: :satellites, units: nil, scale: 1},
      7 => {address: 7, name: 'Geoid Height', key: :geoid_height, units: nil, scale: 1},
      8 => {address: 8, name: 'Horizontal Dilution', key: :horizontal_dilution, units: nil, scale: 1},
      9 => {address: 9, name: 'Faa Mode', key: :faa_mode, units: nil, scale: 1}
    }

    attr_reader :tty
    attr_reader :baudrate
    attr_reader :serial_io
    attr_reader :dict
    attr_reader :pre_data
    attr_reader :shared_data
    attr_reader :source_decoder

    def initialize(shared_data, opts = {})
      final_opts = DEFAULTS.merge(opts)
      @tty = final_opts[:tty]
      @baudrate = final_opts[:baudrate]
      @serial_io = SerialPort.new @tty, @baudrate, 8, 1
      @dict = GPS_DICT
      @pre_data = {}
      @shared_data = shared_data
      @source_decoder = NMEAPlus::SourceDecoder.new(@serial_io)
    end

    def run(fd = nil, disable_nmea_out = false)
      source_decoder.each_complete_message do |message|
        fd.puts message.original.strip unless disable_nmea_out
        case message.data_type[2..-1] # Ignore the first two letters
        when 'GGA'
          pre_data[:time] = message.fix_time
          pre_data[:latitude] = message.latitude
          pre_data[:longitude] = message.longitude
          pre_data[:altitude] = message.altitude
          pre_data[:dgps_station_id] = message.dgps_station_id
          pre_data[:fix_quality] = message.fix_quality
          pre_data[:geoid_height] = message.geoid_height
          pre_data[:horizontal_dilution] = message.horizontal_dilution
          pre_data[:satellites] = message.satellites
          pre_data[:seconds_since_last_update] = message.seconds_since_last_update
        when 'VTG'
          pre_data[:speed_kmh] = message.speed_kmh
          pre_data[:speed_knots] = message.speed_knots
          pre_data[:faa_mode] = message.faa_mode
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

    def log_header
      dict.map do |(address, node)|
        node[:name] + (node[:units] ? " (#{node[:units]})" : '')
      end
    end

    def log_data
     dict.map do |address, node|
        shared_data[node[:key]]
      end
    end
  end
end
