require 'spec_helper'

describe "Transaction" do
  let(:gateway) { Ronin::Gateway.new(DEFAULT_OPTIONS.clone) }
  let(:processor_token) {DEFAULT_OPTIONS[:processor_token]}

  before do
    @rand = rand(1000)
    @payment_method_token = gateway.create_payment_method(payment_method_attributes).token
  end

  describe 'capture' do
    describe 'success' do
      before do
        @authorized_transaction = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        capture = @authorized_transaction.capture
        capture.success.should be_true
      end

      it 'should be successful for full amount' do
        capture = @authorized_transaction.capture(100.0)
        capture.success.should be_true
      end

      it 'should be successful for partial amount' do
        capture = @authorized_transaction.capture(50.0)
        capture.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return processor.transaction - invalid with declined auth' do
        auth = gateway.authorize(@payment_method_token, 100.02, processor_token)  # declined auth
        capture = auth.capture

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'This transaction type is not allowed.' ]
      end

      it 'should return processor.transaction - declined' do
        auth = gateway.authorize(@payment_method_token, 100.00, processor_token)
        capture = auth.capture(100.02)

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end

      it 'should return input.amount - invalid' do
        auth = gateway.authorize(@payment_method_token, 100.00, processor_token)
        capture = auth.capture(100.1)

        capture.success.should be_false
        capture.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'reverse' do
    describe 'on capture' do
      before do
        @purchase = gateway.purchase(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        reverse = @purchase.reverse
        reverse.success.should be_true
      end

      it 'should be successful for full amount' do
        reverse = @purchase.reverse(100.0)
        reverse.success.should be_true
      end

      it 'should be successful for partial amount' do
        reverse = @purchase.reverse(50.0)
        reverse.success.should be_true
      end
    end

    describe 'on authorize' do
      before do
        @authorize = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        reverse = @authorize.reverse
        reverse.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = gateway.purchase(@payment_method_token, 100.00, processor_token)
        reverse = purchase.reverse(100.10)
        reverse.success.should be_false
        reverse.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'credit' do
    describe 'on capture' do
      before do
        @purchase = gateway.purchase(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        credit = @purchase.credit
        credit.success.should be_true
      end

      it 'should be successful for full amount' do
        credit = @purchase.credit(100.0)
        credit.success.should be_true
      end

      it 'should be successful for partial amount' do
        credit = @purchase.credit(50.0)
        credit.success.should be_true
      end
    end

    describe 'on authorize' do
      before do
        @authorize = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        credit = @authorize.credit
        credit.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = gateway.purchase(@payment_method_token, 100.00, processor_token)
        credit = purchase.credit(100.10)

        credit.success.should be_false
        credit.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'void' do
    describe 'on authorized' do
      before do
        @authorize = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        void = @authorize.void
        void.success.should be_true
      end
    end

    describe 'on captured' do
      before do
        @purchase = gateway.purchase(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        void = @purchase.void
        void.success.should be_true
      end
    end
  end
end
