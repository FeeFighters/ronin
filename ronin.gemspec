# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "ronin"
  s.version     = "0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ticket Evolution"]
  s.email       = ["dev@ticketevolution.com"]
  s.homepage    = "http://rubygems.org/gems/samurai"
  s.summary     = "Integration gem for samurai.feefighters.com"
  s.description = "If you are an online merchant and using samurai.feefighters.com, this gem will make your life easy. Integrate with the samurai.feefighters.com portal and process transaction."

  s.required_rubygems_version = ">= 1.3.5"

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'
  s.add_dependency 'httparty'

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_dependency "net-http-spy"

  if RUBY_VERSION =~ /^1\.9/
    s.add_development_dependency 'ruby-debug19'
  else
    s.add_development_dependency 'ruby-debug'
  end

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
