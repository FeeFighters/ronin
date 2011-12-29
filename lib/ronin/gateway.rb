require 'httparty'
require 'active_support/core_ext/hash'

class Ronin::Gateway
  include Ronin::Connection

  def initialize(options={})
    @site = options[:site] || 'https://api.samurai.feefighters.com/v1/'

    @merchant_auth = {
      :username =>options[:merchant_key],
      :password => options[:merchant_password]
    }
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

  def processor(processor_token)
    Ronin::Processor.new(:processor_token => processor_token, :gateway=>self)
  end

  def find_transaction(reference_id)
    response = get('transactions', reference_id)
    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::Transaction, 'transaction', response.body)
  end

  def gateway
    self
  end

  def site
    @site
  end

  def merchant_auth
    @merchant_auth
  end
end
