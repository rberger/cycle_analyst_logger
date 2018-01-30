require 'fileutils'

# simple camelize in ruby
class String
  def camelize
    split("_").map(&:capitalize).join
  end
end


module CycleAnalystLogger

  # Stuff to ensure udev is setup with correct symlinks to the right USB tty ports
  # Based on http://hintshop.ludvig.co.nz/show/persistent-names-usb-serial-devices/
  class UdevSetup
    include FileUtils

    # UdevSetup.new
    # @params devices [Array<Symbol>] List of devices to setup
    #   Symbols must map to Class names of the devices
    def initialize(devices = [:cycle_analyst, :phaserunner, :gps])
      @device_paths[:cycle_analyst] = File.join('/', 'dev', 'cycle_analyst')
      @rule_paths[:cycle_analyst] = File.join('/', 'etc', 'udev', 'rules.d', '99-cycle_analyst-usb.rules')
      @device_class[:cycle_analyst] = CycleAnalystLogger::CycleAnalyst

      @device_paths[:phaserunner] = File.join('/', 'dev', 'phaserunner')
      @rule_paths[:phaserunner] = File.join('/', 'etc', 'udev', 'rules.d', '99-phaserunner-usb.rules')
      @device_class[:phaserunner] = Phaserunner::Modbus

      @device_paths[:gps] = File.join('/', 'dev', 'gps')
      @rule_paths[:gps] = File.join('/', 'etc', 'udev', 'rules.d', '99-gps-usb.rules')
      @device_class[:gps] = CycleAnalystLogger::Gps

      devices.each do |device|
        unless File.exist? @device_paths[device] && @rule_paths[device]
          # Remove if ether are there
          rm_f [@device_paths[device], @rule_paths[device]]
          current_device = @device_class[device].determine_serialport(Dir.glob('/dev/ttyUSB*'))
        end
      end
    end
  end
end
