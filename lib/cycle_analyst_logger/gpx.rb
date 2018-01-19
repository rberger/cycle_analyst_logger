require 'haversine'
require 'gpx'

module CycleAnalystLogger
  class Gpx
    attr_reader :gpx
    # The clean info needed from the gpx
    # @return [Hash<Time, Hash>] points The points organized by Timestamp.
    # * :time (Hash<Symbol, Float) The Point Atrributes
    #   * :timestamp (Time) in seconds resolution
    #   * :lattitude (Float)
    #   * :longitude (Float)
    #   * :elevation (Float)
    #   * :speed (Float)
    attr_reader :points

    def initialize(filename)
      @gpx = GPX::GPXFile.new(gpx_file: filename)
      @points = gpx.tracks.flat_map(&:points).each_with_object({}) do |point, memo|
        memo[point.time] = {
          timestamp: point.time,
          lattitude: point.lat,
          longitude: point.lon,
          elevation: point.elevation,
          speed: point.speed
        }
      end
    end

    # Checks if the input is a valid Time String
    # @param input [String] Potential Time Stamp or invalid string
    # @return [Time, nil] Returns a Time object based on the input if it was valid. Otherwise returns nil
    def valid_timestamp(input)
      begin
        Time.parse(input)
      rescue ArgumentError
        nil
      end
    end

    # Finds the point that is close to the timestamp input.
    #   If there is no point with the same time, it returns the last point
    #   Also calculates the speed between the last point and this point and adds it to the response hash
    # @param timestamp [Time] Timestamp to find. Will round to nearest second
    def closest_point_in_time(timestamp)
      point = if (point = points[timestamp.round(0)])
                # Handle initial case
                @last_point = point unless @last_point

                if point[:timestamp] == @last_point[:timestamp]
                  @last_point 
                else # Its a new point so calculate speed and return the new point
                  duration = point[:timestamp] - @last_point[:timestamp]
                  distance = Haversine.distance(@last_point[:lattitude], @last_point[:longitude], point[:lattitude], point[:longitude]).to_miles
                  speed_mph = (distance / duration) * 3600 # Convert miles / second to miles per hour
                  @last_point = point.merge(speed: speed_mph)
                end

              else # Could not find a point with a matching timestamp so use the last_point (were probably not moving or Strava not recording)
                @last_point.merge(speed: 0.0)
              end
    end

    def merge_location(log_filename, output_filename = nil)
      # Get the proper output File descriptor
      out_fd = if output_filename
                 File.open(output_filename, 'w')
               else
                 $stdout.dup
               end

      File.readlines(log_filename).each.with_index do |log_line, idx|
        log_record = log_line.split(',')
        if idx == 0
          out_fd.puts 'Timestamp,Lattitude,Longitude,Elevation (feet),Speed (mph),' +
                      log_record[1..-1].join(',')
          next
        end

        # Check that the line has a valid timestamp, skip this line if it isn't
        next unless (timestamp = valid_timestamp log_record[0])

        # Get the point from GPX that is closest to the timestamp from the log
        if (point = closest_point_in_time(timestamp))
          lattitude = point[:lattitude]
          longitude = point[:longitude]
          elevation = point[:elevation]
          speed = point[:speed]
        else
          lattitude = longitude = elevation = speed = nil
        end
        out_fd.puts "#{log_record[0]},#{lattitude},#{longitude},#{elevation},#{speed}," +
                    log_record[1..-1].join(',')
      end
    end
  end
end
