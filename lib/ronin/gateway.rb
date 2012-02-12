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
    response = post('payment_methods', params.to_xml(:root=>'payment_method'))
    process_response(Ronin::PaymentMethod, 'payment_method', response)
  end

  def find_payment_method(token)
    response = get('payment_methods', token)
    process_response(Ronin::PaymentMethod, 'payment_method', response)
  end

  def processor(processor_token)
    Ronin::Processor.new(:processor_token => processor_token, :gateway=>self)
  end

  def find_transaction(reference_id)
    response = get('transactions', reference_id)
    process_response(Ronin::Transaction, 'transaction', response)
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
