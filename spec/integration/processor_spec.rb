require 'spec_helper'

describe "Creating transactions" do
  let(:gateway) { Ronin::Gateway.new(DEFAULT_OPTIONS.clone) }
  let(:processor_token) {DEFAULT_OPTIONS[:processor_token]}

  before :each do
    @rand = rand(1000)
    @payment_method_token = gateway.create_payment_method(payment_method_attributes).token
    @processor = gateway.processor(processor_token)
  end

  describe "find_transaction" do
    it "should be successful" do
      purchase = @processor.purchase(@payment_method_token, 100.0, {
        :descriptor => "descriptor",
        :custom => "custom_data",
        :billing_reference => "ABC123#{@rand}",
        :customer_reference => "Customer (123)",
      })

      transaction = gateway.find_transaction(purchase.reference_id)
      transaction.token.should == purchase.token
    end
  end

  describe 'purchase' do
    it 'should be successful' do
      purchase = @processor.purchase(@payment_method_token, 100.0, {
        :descriptor => "descriptor",
        :custom => "custom_data",
        :billing_reference => "ABC123#{@rand}",
        :customer_reference => "Customer (123)",
      })
      purchase.success.should be_true
      purchase.description.should == 'descriptor'
      purchase.custom.should == 'custom_data'
      purchase.billing_reference.should == "ABC123#{@rand}"
      purchase.customer_reference.should == "Customer (123)"
    end

    describe 'failures' do
      it 'should return processor.transaction - declined' do
        purchase = @processor.purchase(@payment_method_token, 1.02, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end

      it 'should return input.amount - invalid' do
        purchase = @processor.purchase(@payment_method_token, 1.10, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end

      it 'should raise Ronin::ResourceNotFound on invalid token' do
        lambda {
          @processor.purchase('bad_token', 1.10, :billing_reference=>rand(1000))
        }.should raise_error(Ronin::ResourceNotFound, "Couldn't find PaymentMethod with token = bad_token")
      end
    end

    describe 'cvv responses' do
      it 'should return processor.cvv_result_code = M' do
        params = payment_method_attributes.merge(:cvv=>'111')
        payment_method_token = gateway.create_payment_method(params).token

        purchase = @processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['cvv_result_code'].should == 'M'
      end

      it 'should return processor.cvv_result_code = N' do
        params = payment_method_attributes.merge(:cvv=>'222')
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['cvv_result_code'].should == 'N'
      end
    end

    describe 'avs responses' do
      it 'should return processor.avs_result_code = Y' do
        params = payment_method_attributes.merge({
          :address_1  => '1000 1st Av',
          :address_2  => '',
          :zip        => '10101',
        })
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'Y'
      end

      it 'should return processor.avs_result_code = Z' do
        params = payment_method_attributes.merge({
          :address_1  => '',
          :address_2  => '',
          :zip        => '10101',
        })

        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'Z'
      end

      it 'should return processor.avs_result_code = N' do
        params = payment_method_attributes.merge({
          :address_1  => '123 Main St',
          :address_2  => '',
          :zip        => '60610',
        })
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))

        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'N'
      end
    end
  end


  describe 'authorize' do
    it 'should be successful' do
      purchase = @processor.authorize(@payment_method_token, 100.0, {
        :descriptor => "descriptor",
        :custom => "custom_data",
        :billing_reference => "ABC123#{@rand}",
        :customer_reference => "Customer (123)",
      })
      purchase.success.should be_true
      purchase.description.should == 'descriptor'
      purchase.custom.should == 'custom_data'
      purchase.billing_reference.should == "ABC123#{@rand}"
      purchase.customer_reference.should == "Customer (123)"
    end

    describe 'failures' do
      it 'should return processor.transaction - declined' do
        authorize = @processor.authorize(@payment_method_token, 1.02, :billing_reference=>rand(1000))
        authorize.success.should be_false
        authorize.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end
      it 'should return input.amount - invalid' do
        authorize = @processor.authorize(@payment_method_token, 1.10, :billing_reference=>rand(1000))
        authorize.success.should be_false
        authorize.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end

    describe 'cvv responses' do
      it 'should return processor.cvv_result_code = M' do
        params = payment_method_attributes.merge(:cvv=>'111')
        payment_method_token = gateway.create_payment_method(params).token

        purchase = @processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['cvv_result_code'].should == 'M'
      end

      it 'should return processor.cvv_result_code = N' do
        params = payment_method_attributes.merge(:cvv=>'222')
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['cvv_result_code'].should == 'N'
      end
    end

    describe 'avs responses' do
      it 'should return processor.avs_result_code = Y' do
        params = payment_method_attributes.merge({
          :address_1  => '1000 1st Av',
          :address_2  => '',
          :zip        => '10101',
        })
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'Y'
      end

      it 'should return processor.avs_result_code = Z' do
        params = payment_method_attributes.merge({
          :address_1  => '',
          :address_2  => '',
          :zip        => '10101',
        })

        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'Z'
      end

      it 'should return processor.avs_result_code = N' do
        params = payment_method_attributes.merge({
          :address_1  => '123 Main St',
          :address_2  => '',
          :zip        => '60610',
        })
        payment_method_token = gateway.create_payment_method(params).token
        purchase = @processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))

        purchase.success.should be_true
        purchase.processor_response['avs_result_code'].should == 'N'
      end
    end
  end
end

