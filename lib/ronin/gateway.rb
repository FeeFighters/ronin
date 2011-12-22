require 'httparty'
require 'active_support/core_ext/hash'

class Ronin::Gateway
  def initialize(options={})
    @site = options[:site]

    @merchant_auth = {
      :username =>options[:merchant_key],
      :password => options[:merchant_password]
    }

    @processor_token = options[:processor_token]
  end

  def create_payment_method(params={})
    response = post('payment_methods', :payment_method => params)
    from_xml(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  def find_payment_method(token)
    response = get('payment_methods', token)
    from_xml(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  private

  def get(uri, id)
    request = HTTParty::Request.new(Net::HTTP::Get, "#{@site}#{uri}/#{id}.xml", :format => :xml, :basic_auth => @merchant_auth)
    request.perform
  end

  def post(uri, params)
    request = HTTParty::Request.new(Net::HTTP::Post, "#{@site}#{uri}.xml", :body => params, :format => :xml, :basic_auth => @merchant_auth)
    request.perform
  end

  def from_xml(klass, key, attributes)
    attributes = Hash.from_xml(attributes)[key]
    obj = klass.new
    obj.attributes = attributes
    mod = Module.new do
      obj.attributes.keys.each do |k|
        define_method(k) do
          return self.attributes[k]
        end

        define_method("#{k}=") do |val|
          self.attributes[k] = val
        end
      end
    end
    obj.send(:extend, mod)
    obj
  end
end
