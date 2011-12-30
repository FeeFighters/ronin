module Ronin::Connection
  private

  def get(uri, id)
    request = HTTParty::Request.new(Net::HTTP::Get, "#{self.gateway.site}#{uri}/#{id}.xml", :format => :xml, :basic_auth => self.gateway.merchant_auth)
    request.perform
  end

  def post(uri, params)
    request = HTTParty::Request.new(Net::HTTP::Post, "#{self.gateway.site}#{uri}.xml", :body => params, :format => :xml, :basic_auth => self.gateway.merchant_auth)
    request.perform
  end

  def put(uri, id, params)
    request = HTTParty::Request.new(Net::HTTP::Put, "#{self.gateway.site}#{uri}/#{id}.xml", :body => params, :format => :xml, :basic_auth => self.gateway.merchant_auth)
    request.perform
  end

  def process_response(klass, key, attributes)
    attributes = Hash.from_xml(attributes)[key]
    obj = klass.new
    obj.attributes = {'gateway' => self.gateway}.merge(attributes)
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
