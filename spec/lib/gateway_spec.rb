require 'spec_helper'

describe Ronin::Gateway do
  describe "initialize" do
    it "accepts options" do
      lambda do
        Ronin::Gateway.new({})
      end.should_not raise_error
    end
  end
end
