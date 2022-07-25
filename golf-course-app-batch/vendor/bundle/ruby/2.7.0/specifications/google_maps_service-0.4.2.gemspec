# -*- encoding: utf-8 -*-
# stub: google_maps_service 0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "google_maps_service".freeze
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Edward Samuel Pasaribu".freeze]
  s.date = "2016-08-26"
  s.email = ["edwardsamuel92@gmail.com".freeze]
  s.homepage = "https://github.com/edwardsamuel/google-maps-services-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Ruby gem for Google Maps Web Service APIs".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.11"])
    s.add_runtime_dependency(%q<hurley>.freeze, ["~> 0.1"])
    s.add_runtime_dependency(%q<retriable>.freeze, ["~> 2.0"])
  else
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.11"])
    s.add_dependency(%q<hurley>.freeze, ["~> 0.1"])
    s.add_dependency(%q<retriable>.freeze, ["~> 2.0"])
  end
end
