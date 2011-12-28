require 'rspec'
require 'pp'
# require 'net-http-spy'
# Net::HTTP.http_logger_options = {:verbose => true}

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SITE = ENV['site'] || 'https://api.samurai.feefighters.com/v1/'
USE_MOCK = !ENV['site']

RSpec.configure do |c|
  c.before :each do
  end
end

include Samurai::Helpers

# uncomment below to see requests
# require 'net-http-spy'

require 'ronin'

DEFAULT_OPTIONS = {
  :site => SITE,
  :merchant_key => ENV['merchant_key'] || 'a1ebafb6da5238fb8a3ac9f6',
  :merchant_password => ENV['merchant_password'] || 'ae1aa640f6b735c4730fbb56',
  :processor_token => ENV['processor_token'] || '5a0e1ca1e5a11a2997bbf912'
}
