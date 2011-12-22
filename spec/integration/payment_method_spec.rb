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

    describe 'fail on input.card_number' do
      it 'should return is_blank' do
        payment_method = gateway.create_payment_method(@params.merge(:card_number => ''))
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was blank.' ]
      end
      it 'should return too_short' do
        payment_method = gateway.create_payment_method(@params.merge(:card_number => '4111-1'))
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was too short.' ]
      end
      it 'should return too_long' do
        payment_method = gateway.create_payment_method(@params.merge(:card_number => '4111-1111-1111-1111-11'))
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was too long.' ]
      end
      it 'should return failed_checksum' do
        payment_method = gateway.create_payment_method(@params.merge(:card_number => '4111-1111-1111-1234'))
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was invalid.' ]
      end
    end

    describe 'fail on input.cvv' do
      it 'should return too_short' do
        pm = gateway.create_payment_method @params.merge(:cvv => '1')
        pm.is_sensitive_data_valid.should be_false
        pm.errors['input.cvv'].should == [ 'The CVV was too short.' ]
      end
      it 'should return too_long' do
        pm = gateway.create_payment_method @params.merge(:cvv => '111111')
        pm.is_sensitive_data_valid.should be_false
        pm.errors['input.cvv'].should == [ 'The CVV was too long.' ]
      end
      it 'should return not_numeric' do
        pm = gateway.create_payment_method @params.merge(:cvv => 'abcd1')
        pm.is_sensitive_data_valid.should be_false
        pm.errors['input.cvv'].should == [ 'The CVV was invalid.' ]
      end
    end

    describe 'fail on input.expiry_month' do
      it 'should return is_blank' do
        pm = gateway.create_payment_method @params.merge(:expiry_month => '')
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_false
        pm.errors['input.expiry_month'].should == [ 'The expiration month was blank.' ]
      end
      it 'should return is_invalid' do
        pm = gateway.create_payment_method @params.merge(:expiry_month => 'abcd')
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_false
        pm.errors['input.expiry_month'].should == [ 'The expiration month was invalid.' ]
      end
    end

    describe 'fail on input.expiry_year' do
      it 'should return is_blank' do
        pm = gateway.create_payment_method @params.merge(:expiry_year => '')
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_false
        pm.errors['input.expiry_year'].should == [ 'The expiration year was blank.' ]
      end
      it 'should return is_invalid' do
        pm = gateway.create_payment_method @params.merge(:expiry_year => 'abcd')
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_false
        pm.errors['input.expiry_year'].should == [ 'The expiration year was invalid.' ]
      end
    end
  end
end
