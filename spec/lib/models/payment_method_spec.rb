require 'spec_helper'

describe Ronin::PaymentMethod do
  let(:payment_method) {Ronin::PaymentMethod.new}
  it "has attributes" do
    payment_method.attributes = {"foo" => "bar"}
    payment_method.attributes.should == {"foo" => "bar"}
  end

  describe "#id" do
    before do
      payment_method.attributes = {"payment_method_token" => "t0k3n"}
    end

    it "returns token" do
      payment_method.id.should == payment_method.token
    end
  end

  describe "#token" do
    before do
      payment_method.attributes = {"payment_method_token" => "t0k3n"}
    end

    it "returns attributes['payment_method_token']" do
      payment_method.token.should == "t0k3n"
    end
  end
end
