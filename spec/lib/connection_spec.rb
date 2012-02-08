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
    context "with a 404 response" do
      it "raises an exception with returned error" do
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

      it "raises an exception with a contact samurai message if the error message cannot be parsed" do
        body = <<-xml
        <html>
          <p>This is a web page or something else I don't want to parse</p>
        </html>
        xml

        response = stub(:code => 404, :body => body)

        foo = Foo.new

        expect {
          foo.process_response(Foo, 'foo', response)
        }.to raise_error(Ronin::ResourceNotFound, "An error occured. Please contact Samurai for more information")
      end
    end
  end
end

