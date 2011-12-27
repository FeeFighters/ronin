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
    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  def find_payment_method(token)
    response = get('payment_methods', token)
    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  def update_payment_method(token, params={})
    response = put('payment_methods', token, :payment_method => params)
    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  # create transactions
  def authorize(token, amount, processor_token, params={})
    transaction_params = params.merge(:payment_method_token => token, :amount => amount)
    response = post("processors/#{processor_token}/authorize", :transaction => transaction_params)

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::Transaction, 'transaction', response.body)
  end

  def purchase(token, amount, processor_token, params={})
    transaction_params = params.merge(:payment_method_token => token, :amount => amount)
    response = post("processors/#{processor_token}/purchase", :transaction => transaction_params)

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::Transaction, 'transaction', response.body)
  end

  #transaction methods
  def capture(transaction_token, amount=nil)
    transaction_method('capture', transaction_token, amount)
  end

  def reverse(transaction_token, amount=nil)
    transaction_method('capture', transaction_token, amount)
  end

  def void(transaction_token, amount=nil)
    transaction_method('capture', transaction_token, amount)
  end

  def credit(transaction_token, amount=nil)
    transaction_method('capture', transaction_token, amount)
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

  def put(uri, id, params)
    request = HTTParty::Request.new(Net::HTTP::Put, "#{@site}#{uri}/#{id}.xml", :body => params, :format => :xml, :basic_auth => @merchant_auth)
    request.perform
  end

  def transaction_method(method, token, amount=nil)
    transaction_params = {:amount => amount}
    response = post("transactions/#{token}/#{method}", :transaction => transaction_params)

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::Transaction, 'transaction', response.body)
  end

  def process_response(klass, key, attributes)
    attributes = Hash.from_xml(attributes)[key]
    obj = klass.new
    obj.attributes = attributes
    mod = Module.new do
      obj.attributes.keys.each do |k|
        next if k == "messages"

        define_method(k) do
          return self.attributes[k]
        end

        define_method("#{k}=") do |val|
          self.attributes[k] = val
        end
      end
    end
    obj.send(:extend, mod)
    obj.process_response_errors(obj.attributes)
    obj
  end
end
