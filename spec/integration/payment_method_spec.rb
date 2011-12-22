require 'spec_helper'

describe "PaymentMethod" do
  let(:gateway) { Ronin::Gateway.new(DEFAULT_OPTIONS.clone) }

  before do
    @params = {
      :first_name   => "FirstName",
      :last_name    => "LastName",
      :address_1    => "123 Main St.",
      :address_2    => "Apt #3",
      :city         => "Chicago",
      :state        => "IL",
      :zip          => "10101",
      :card_number  => "4111-1111-1111-1111",
      :cvv          => "123",
      :expiry_month => '03',
      :expiry_year  => "2015",
    }
  end

  describe 'S2S #create' do
    it 'should be successful' do
      payment_method = gateway.create_payment_method(@params)

      gateway.find_payment_method(payment_method.token).tap do |pm|
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_true
        pm.first_name.should  == @params[:first_name]
        pm.last_name.should   == @params[:last_name]
        pm.address_1.should   == @params[:address_1]
        pm.address_2.should   == @params[:address_2]
        pm.city.should        == @params[:city]
        pm.state.should       == @params[:state]
        pm.zip.should         == @params[:zip]
        pm.last_four_digits.should == @params[:card_number][-4, 4]
        pm.expiry_month.should  == @params[:expiry_month].to_i
        pm.expiry_year.should   == @params[:expiry_year].to_i
      end
    end
  end
 end
