# Cycle_analyst_logger

Log the streaming data log output of a Grin Cycle Analyst V3 and optionally a Phaserunner and GPS

[![Gem Version Badge](https://badge.fury.io/rb/cycle_analyst_logger.svg)](https://badge.fury.io/rb/cycle_analyst_logger)

## Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes on
how to deploy the project on a live system.

### Prerequisites

* Ruby ~2.4 or ~2.5
* Bundler

Bundler / Gemspec automatically pulls in all the dependencies

### Installing for doing development

The usual Ruby install from github

```
git clone git@github.com:rberger/phaserunner.git
cd phaserunner
bundle install
```

### Notes

* Delegates all Phaserunner operations to [rberger/phaserunner](https://github.com/rberger/phaserunner) [phaserunner ruby gem](https://rubygems.org/gems/phaserunner)
* Only tested with [Navspark-BD GPS](http://navspark.mybigcommerce.com/navspark-bd-arduino-compatible-development-board-with-gps-beidou/)
* Now applies scaling factors to the Phaserunner data
* Log output file is CSV with CA, Phaserunner and GPS Data per line
* Also outputs the raw NMEA GPS file so that it can be read into [Grin Trip Analyzer](http://www.ebikes.ca/tools/trip-analyzer.html)
* The `to_ca_file` command  converts the default log output file to a CALog file suitable for inputing to [Grin Trip Analyzer](http://www.ebikes.ca/tools/trip-analyzer.html)
* Sometimes the Trip Analyzer barfs on the NMEA file

## Usage

### Help

Shows a list of commands or help for one command

```
> cycle_analyst_logger help
NAME
    cycle_analyst_logger - Store the streaming data log output of a Grin Cycle Analyst V3 and optionally a Phaserunner

SYNOPSIS
    cycle_analyst_logger [global options] command [command options] [arguments...]

VERSION
    0.4.0

GLOBAL OPTIONS
    -t, --tty_ca=arg          - Cycle Analyst Serial (USB) device (default: /dev/cycle_analyst)
    -b, --baud_ca=arg         - Cycle Analyst Serial port baudrate (default: 9600)
    --tty_pr=arg              - Phaserunner Serial (USB) device (default: /dev/phaserunner)
    --baud_pr=arg             - Phaserunner Serial port baudrate (default: 115200)
    --tty_gps=arg             - Gps Serial (USB) device (default: /dev/gps)
    --baud_gps=arg            - Gps Serial port baudrate (default: 115200)
    -l, --loop_count=arg      - How many lines to read (default: forever)
    --version                 - Display the program version
    --[no-]enable_phaserunner - Get PhaseRunner Logs also (default: enabled)
    --[no-]enable_gps         - Get Gps Logs also (default: enabled)
    -q, --[no-]quiet          - Do not output to stdout
    --help                    - Show this message

COMMANDS
    help       - Shows a list of commands or help for one command
    log        - Log the Cycle Analyst and optionally GPS and Phaserunner to a file
    to_ca_file - Transform logs to CA format
```

### Log

Capture the logging output of the Cycle Analyst and optionally Phaserunner to a file

```
> cycle_analyst_logger help log
NAME
    log - Log the Cycle Analyst and optionally GPS and Phaserunner to a file

SYNOPSIS
    cycle_analyst_logger [global options] log [command options] [tty] [baudrate] [tty] [baudrate] [tty] [baudrate]

COMMAND OPTIONS
    --[no-]disable_nmea_out - Disable writing raw nmea to its own file
```

#### Attributes that are Logged

* Timestamp
* Cycle Analyst Amp Hours (Ah)
* Cycle Analyst Volts (V)
* Cycle Analyst Current (A)
* Cycle Analyst Speed (Mph)
* Cycle Analyst Distance (Miles)
* Cycle Analyst Motor Temp (DegC)
* Cycle Analyst Human Cadence (RPM)
* Cycle Analyst Human Power (W)
* Cycle Analyst Human Torque (Nm)
* Cycle Analyst Throttle In (V)
* Cycle Analyst Throttle Out (V)
* Cycle Analyst AuxA ()
* Cycle Analyst AuxD ()
* Cycle Analyst Limit Flags (bit flags)
* Cycle Analyst Faults
* Phaserunner Faults ()
* Phaserunner Controller Temperature (deg Celsius)
* Phaserunner Vehicle Speed (Km/hour)
* Phaserunner Motor Temperature (deg Celsius)
* Phaserunner Motor Current (Amps)
* Phaserunner Motor RPM (RPM)
* Phaserunner Motor Speed (% of rated rpm)
* Phaserunner Battery Voltage (Volts)
* Phaserunner Battery Current (Amps)
* Phaserunner Battery State of Charge (%)
* Phaserunner Battery Power (Watts)
* Phaserunner Last Fault ()
* Phaserunner Throttle Voltage (Volts)
* Phaserunner Brake 1 Voltage (Volts)
* Phaserunner Brake 2 Voltage (Volts)
* Phaserunner Raw Controller Temperature Sensor Voltage (Volts)
* Phaserunner Digital Inputs (Bitmap)
* Phaserunner Warnings (Bitmap)
* Phaserunner Phase A Current (Amps)
* Phaserunner Phase B Current (Amps)
* Phaserunner Phase C Current (Amps)
* Phaserunner Phase A Voltage (Volts)
* Phaserunner Phase B Voltage (Volts)
* Phaserunner Phase C Voltage (Volts)
* Phaserunner Motor Input Power (W)
* Phaserunner Torque Command (pu)
* Phaserunner Torque Reference (pu)
* Phaserunner Speed (Ref/Limit) Command (pu)
* GPS Time
* GPS Latitude
* GPS Longitude
* GPS Altitude
* GPS Speed
* GPS Fix Quality
* GPS Satellites
* GPS Geoid Height
* GPS Horizontal Dilution
* GPS FAA Mode

### to_ca_file

Transform logs to CA format
    
```
> cycle_analyst_logger help to_ca_file
NAME
    to_ca_file - Transform logs to CA format

SYNOPSIS
    cycle_analyst_logger [global options] to_ca_file log_filename
```
## Deployment

Deploy as usual. If you are not doing it from a git clone just want to install from Rubygems:

```
gem install phaserunner
```

### Udev set up

A sample udev rules file is in `resources/99-cycle_analyst.rules`. It is based on
the information from [Persistent names for usb-serial
devices](http://hintshop.ludvig.co.nz/show/persistent-names-usb-serial-devices/)

This one assumes we have the TTL to USB Cable based on the FTDI chipset like the
[USB Cables from Grin Tech](http://www.ebikes.ca/ca-usb.html) We have one for
the Cycle Analyst (CA) and one for the Phaserunner. If you always use the same
cable with the CA and the other cable always for the Phaserunner (Label them).
Then you can get away with using the serial numbers that the UDEV system sees to
automatically link whatever USB port the cable is plugged into to the right
`/dev` name.

The Navspark-BD GPS I used has a built in PL2303 chipset and doesn't seem to
have a serial number like the FTDI chipsets does. So the setup assumes there is
only one PL2303 USB and its the GPS.

### Systemd startup

There is a working systemd service unit file
`resources/cycle_analyst_logger.service`. You can copy it into
`/lib/systemd/system` and do a

`systemctl daemon-reload` to load it into systemd

* If you want it to start when the system is booted say:

  `systemctl enable cycle_analyst_logger.service`

* To disable:

  `systemctl disable cycle_analyst_logger.service`

* To start it manually (have to do this also the first time you do an enable and
  want it to run then):

  `systemctl start cycle_analyst_logger.service`

* You can check the status:

  `systemctl status cycle_analyst_logger.service`

* To see the logs:

  `journalctl -u cycle_analyst_logger.service`

This file assumed that rvm was installed in my home directory and an rvm wrapper
was created so it the service unit file could just exec it. I am currently using
Ruby 2.4.1.

The command used to create the wrapper was run as my normal user:

`rvm alias create cycle_analyst_logger 2.4.1`

## Built With

* [Ruby](https://www.ruby-lang.org/) - Language
* [Bundler](http://bundler.io) - Package / Dependency Management
* [asi_bod](https://rubygems.org/gems/asi_bod) - Grin Phaserunner / [Accelerated System](http://accelerated-systems.com) Register Defs
* [Grin Tech Phaserunner](http://www.ebikes.ca/product-info/phaserunner.html) - Controller were interfacing to

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rberger/cycle_analyst_logger.


### Code of Conduct in Contriubing

This project is intended to be a safe, welcoming space for collaboration.

Everyone interacting in this project’s codebases, issue trackers, chat rooms and
mailing lists is expected to follow the [Contributor Code of Conduct](CODE-OF-CONDUCT.md).

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/rberger/cycle_analyst_logger/tags). 

## Authors

* **[Robert Berger](https://github.com/rberger)**

## License and Copyright

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details

* Copyright (c) 2018 Robert J. Berger
* License: MIT

