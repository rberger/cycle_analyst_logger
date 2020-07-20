
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cycle_analyst_logger/version"

Gem::Specification.new do |spec|
  spec.name          = "cycle_analyst_logger"
  spec.version       = CycleAnalystLogger::VERSION
  spec.authors       = ["Robert J. Berger"]
  spec.email         = ["rberger@ibd.com"]

  spec.summary       = %q{Read and store log output from the Grin Cycle Analyst and Phaserunner}
  spec.description   = %q{Read and store log output from the Grin Cycle Analyst and optionally Phaserunner}
  spec.homepage      = "https://github.com/rberger/cycle_analyst_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2'
  
  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README.md']
  spec.rdoc_options << '--title' << 'cycle_analyst_logger' << '--main' << 'README.md' << '-ri'

  spec.add_runtime_dependency 'gli', '~> 2.17'
  spec.add_runtime_dependency 'serialport', '~> 1.3'
  spec.add_runtime_dependency 'phaserunner', '>= 0.2.3'
  spec.add_runtime_dependency 'haversine', '~> 0.3.2'
  spec.add_runtime_dependency 'gpx', '~> 0.9.0'
  spec.add_runtime_dependency 'nmea_plus', '~> 1.0', '>= 1.0.20'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rdoc', '>= 5.0.0'
  spec.add_development_dependency 'aruba', '~> 0.14'
  spec.add_development_dependency 'yard', '~> 0.9'
end
