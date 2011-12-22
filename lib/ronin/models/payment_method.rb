class Ronin::PaymentMethod
  attr_accessor :attributes
  def initialize
    @messages = []
  end

  def id
    self.token
  end

  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end

  def errors
    @errors ||= {}
  end

  def process_response_errors(messages_attributes)
    @errors = {}
    if messages_attributes.present?
      # Sort the messages so that more-critical/relevant ones appear first, since only the first error is added to a field
      sorted_messages = messages_attributes.sort_by {|m| ['is_blank', 'not_numeric', 'too_short', 'too_long', 'failed_checksum'].index(m['key']) || 0 }
      sorted_messages.each do |message_attributes|
        message = Ronin::Message.new(message_attributes)
        self.errors[message.context] = self.errors[message.context] || []
        self.errors[message.context] << message.description if self.errors[message.context].blank?
      end
    end
    self
  end
end
