require 'spec_helper'

describe "Transaction" do
  let(:processor_token) {DEFAULT_OPTIONS[:processor_token]}
  let(:gateway) { Ronin::Gateway.new(DEFAULT_OPTIONS.clone) }
  let(:processor) { gateway.processor(processor_token) }

  before do
    @rand = rand(1000)
    @payment_method_token = gateway.create_payment_method(payment_method_attributes).token
  end

  describe 'capture' do
    describe 'success' do
      before do
        @authorized_transaction = processor.authorize(@payment_method_token, 100.0)
      end

      it 'should be successful' do
        capture = @authorized_transaction.capture
        capture.success.should be_true
      end

      it "contains no error messages" do
        capture = @authorized_transaction.capture
        capture.success.should be_true

        capture.errors.should be_blank
      end

      it "contains messages" do
        capture = @authorized_transaction.capture
        capture.success.should be_true

        capture.messages.should be_present
        capture.messages.map(&:description) =~ [ "The transaction was successful.", "The address and 9-digit ZIP match." ]
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
        auth = processor.authorize(@payment_method_token, 100.02)  # declined auth
        capture = auth.capture

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'This transaction type is not allowed.' ]
      end

      it 'should return processor.transaction - declined' do
        auth = processor.authorize(@payment_method_token, 100.00)
        capture = auth.capture(100.02)

        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end

      it 'should return input.amount - invalid' do
        auth = processor.authorize(@payment_method_token, 100.00)
        capture = auth.capture(100.1)

        capture.success.should be_false
        capture.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'reverse' do
    describe 'on capture' do
      before do
        @purchase = processor.purchase(@payment_method_token, 100.0)
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
        @authorize = processor.authorize(@payment_method_token, 100.0)
      end

      it 'should be successful' do
        reverse = @authorize.reverse
        reverse.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = processor.purchase(@payment_method_token, 100.00)
        reverse = purchase.reverse(100.10)
        reverse.success.should be_false
        reverse.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'credit' do
    describe 'on capture' do
      before do
        @purchase = processor.purchase(@payment_method_token, 100.0)
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
        @authorize = processor.authorize(@payment_method_token, 100.0)
      end

      it 'should be successful' do
        credit = @authorize.credit
        credit.success.should be_true
      end
    end

    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = processor.purchase(@payment_method_token, 100.00)
        credit = purchase.credit(100.10)

        credit.success.should be_false
        credit.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'reverse' do
    describe 'on authorized' do
      before do
        @authorize = processor.authorize(@payment_method_token, 100.0)
      end

      it 'should be successful' do
        reverse = @authorize.reverse
        reverse.success.should be_true
      end
    end

    describe 'on captured' do
      before do
        @purchase = processor.purchase(@payment_method_token, 100.0)
      end

      it 'should be successful' do
        reverse = @purchase.reverse
        reverse.success.should be_true
      end
    end
  end
end
