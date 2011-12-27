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

  describe 'S2S #update' do
    before do
      @new_params = {
        :first_name   => "FirstNameX",
        :last_name    => "LastNameX",
        :address_1    => "123 Main St.X",
        :address_2    => "Apt #3X",
        :city         => "ChicagoX",
        :state        => "IL",
        :zip          => "10101",
        :card_number  => "5454-5454-5454-5454",
        :cvv          => "456",
        :expiry_month => '05',
        :expiry_year  => "2016",
      }
      token = gateway.create_payment_method(@params).token
      @pm = gateway.find_payment_method(token)
    end

    it 'should be successful' do
      payment_method = gateway.update_payment_method @pm.token, @new_params
      gateway.find_payment_method(payment_method.token).tap do |pm|
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_true
        pm.token.should_not == @pm.token #there is a new id/token returned, even with an update
        pm.first_name.should  == @new_params[:first_name]
        pm.last_name.should   == @new_params[:last_name]
        pm.address_1.should   == @new_params[:address_1]
        pm.address_2.should   == @new_params[:address_2]
        pm.city.should        == @new_params[:city]
        pm.state.should       == @new_params[:state]
        pm.zip.should         == @new_params[:zip]
        pm.last_four_digits.should == @new_params[:card_number][-4, 4]
        pm.expiry_month.should  == @new_params[:expiry_month].to_i
        pm.expiry_year.should   == @new_params[:expiry_year].to_i
      end
    end
    it 'should be successful preserving sensitive data' do
      _params = @new_params.merge({
        :card_number => '****************',
        :cvv => '***',
      })
      payment_method = gateway.update_payment_method @pm.token, _params
      gateway.find_payment_method(payment_method.token).tap do |pm|
        pm.is_sensitive_data_valid.should be_true
        pm.is_expiration_valid.should be_true
        pm.first_name.should  == @new_params[:first_name]
        pm.last_name.should   == @new_params[:last_name]
        pm.address_1.should   == @new_params[:address_1]
        pm.address_2.should   == @new_params[:address_2]
        pm.city.should        == @new_params[:city]
        pm.state.should       == @new_params[:state]
        pm.zip.should         == @new_params[:zip]
        pm.last_four_digits.should == '1111'
        pm.expiry_month.should  == @new_params[:expiry_month].to_i
        pm.expiry_year.should   == @new_params[:expiry_year].to_i
      end
    end
    describe 'fail on input.card_number' do
      it 'should return too_short' do
        payment_method = gateway.update_payment_method @pm.token, @new_params.merge(:card_number => '4111-1')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was too short.' ]
      end
      it 'should return too_long' do
        payment_method = gateway.update_payment_method @pm.token, @new_params.merge(:card_number => '4111-1111-1111-1111-11')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was too long.' ]
      end
      it 'should return failed_checksum' do
        payment_method = gateway.update_payment_method @pm.token, @new_params.merge(:card_number => '4111-1111-1111-1234')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.card_number'].should == [ 'The card number was invalid.' ]
      end
    end
    describe 'fail on input.cvv' do
      it 'should return too_short' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:cvv => '1')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.cvv'].should == [ 'The CVV was too short.' ]
      end
      it 'should return too_long' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:cvv => '111111')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.cvv'].should == [ 'The CVV was too long.' ]
      end
      it 'should return not_numeric' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:cvv => 'abcd1')
        payment_method.is_sensitive_data_valid.should be_false
        payment_method.errors['input.cvv'].should == [ 'The CVV was invalid.' ]
      end
    end
    describe 'fail on input.expiry_month' do
      it 'should return is_blank' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:expiry_month => '')
        payment_method.is_sensitive_data_valid.should be_true
        payment_method.is_expiration_valid.should be_false
        payment_method.errors['input.expiry_month'].should == [ 'The expiration month was blank.' ]
      end
      it 'should return is_invalid' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:expiry_month => 'abcd')
        payment_method.is_sensitive_data_valid.should be_true
        payment_method.is_expiration_valid.should be_false
        payment_method.errors['input.expiry_month'].should == [ 'The expiration month was invalid.' ]
      end
    end
    describe 'fail on input.expiry_year' do
      it 'should return is_blank' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:expiry_year => '')
        payment_method.is_sensitive_data_valid.should be_true
        payment_method.is_expiration_valid.should be_false
        payment_method.errors['input.expiry_year'].should == [ 'The expiration year was blank.' ]
      end
      it 'should return is_invalid' do
        payment_method = gateway.update_payment_method @pm.token, @params.merge(:expiry_year => 'abcd')
        payment_method.is_sensitive_data_valid.should be_true
        payment_method.is_expiration_valid.should be_false
        payment_method.errors['input.expiry_year'].should == [ 'The expiration year was invalid.' ]
      end
    end
  end

  describe '#find' do
    before do
      @token =  gateway.create_payment_method(@params).token
    end
    it 'should be successful' do
      gateway.find_payment_method(@token).tap do |pm|
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
    it 'should fail on an invalid token' do
      lambda do
        gateway.find_payment_method('abc123')
      end.should raise_error(Ronin::ResourceNotFound)
    end
  end
end
