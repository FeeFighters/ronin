require 'spec_helper'


describe "Ronin::Connection" do
  before do
    class Foo
      include Ronin::Connection

      def process_response(*args)
        super(*args)
      end
    end
  end

  after do
    Object.send(:remove_const, :Foo)
  end

  describe "#process_response" do
    it "raises an exception on a 404 response" do
      body = <<-xml
        <error>
          <echo>
            <url>/v1/transactions/foo/reverse.xml</url>
            <request_method>POST</request_method>
            <payload>
              <transaction>
                <amount>88.88</amount>
              </transaction>
            </payload>
          </echo>
          <messages type="array">
            <message subclass="error" context="system.general" key="default">Couldn't find Transaction with token = foo</message>
          </messages>
        </error>
      xml

      response = stub(:code => 404, :body => body)

      foo = Foo.new

      expect {
        foo.process_response(Foo, 'foo', response)
      }.to raise_error(Ronin::ResourceNotFound, "Couldn't find Transaction with token = foo")
    end
  end
end
