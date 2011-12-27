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
        capture = gateway.capture(@authorized_transaction.id)
        capture.success.should be_true
      end

      it 'should be successful for full amount' do
        capture = gateway.capture(@authorized_transaction.id, 100.0)
        capture.success.should be_true
      end

      it 'should be successful for partial amount' do
        capture = gateway.capture(@authorized_transaction.id, 50.0)
        capture.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return processor.transaction - invalid with declined auth' do
        auth = gateway.authorize(@payment_method_token, 100.02, processor_token)  # declined auth
        capture = gateway.capture(auth.id)

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'This transaction type is not allowed.' ]
      end

      it 'should return processor.transaction - declined' do
        auth = gateway.authorize(@payment_method_token, 100.00, processor_token)
        capture = gateway.capture(auth.id, 100.02)

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end

      it 'should return input.amount - invalid' do
        auth = gateway.authorize(@payment_method_token, 100.00, processor_token)
        capture = gateway.capture(auth.id, 100.1)

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
        reverse = gateway.reverse(@purchase.id)
        reverse.success.should be_true
      end

      it 'should be successful for full amount' do
        reverse = gateway.reverse(@purchase.id, 100.0)
        reverse.success.should be_true
      end

      it 'should be successful for partial amount' do
        reverse = gateway.reverse(@purchase.id, 50.0)
        reverse.success.should be_true
      end
    end

    describe 'on authorize' do
      before do
        @authorize = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        reverse = gateway.reverse(@authorize.id)
        reverse.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = gateway.purchase(@payment_method_token, 100.00, processor_token)
        reverse = gateway.reverse(purchase.id, 100.10)
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
        credit = gateway.credit(@purchase.id)
        credit.success.should be_true
      end

      it 'should be successful for full amount' do
        credit = gateway.credit(@purchase.id, 100.0)
        credit.success.should be_true
      end

      it 'should be successful for partial amount' do
        credit = gateway.credit(@purchase.id, 50.0)
        credit.success.should be_true
      end
    end

    describe 'on authorize' do
      before do
        @authorize = gateway.authorize(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        credit = gateway.credit(@authorize.id)
        credit.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = gateway.purchase(@payment_method_token, 100.00, processor_token)
        credit = gateway.credit(purchase.id, 100.10)

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
        void = gateway.void(@authorize.id)
        void.success.should be_true
      end
    end

    describe 'on captured' do
      before do
        @purchase = gateway.purchase(@payment_method_token, 100.0, processor_token)
      end

      it 'should be successful' do
        void = gateway.void(@purchase.id)
        void.success.should be_true
      end
    end
  end
end
