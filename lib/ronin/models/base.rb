class Ronin::Base
  include Ronin::Connection
  attr_reader :messages, :errors, :attributes

  def initialize
    @attributes = {}
    @errors     = {}
    @messages   = []
  end

  def id
    self.token
  end

  def token
    raise NoMethodError, "#token must be defined in classes inheriting from Ronin::Base"
  end

  def process_response_errors(attributes)
    messages.clear
    errors.clear

    messages_attributes = attributes['messages']
    if messages_attributes.present?
      # Sort the messages so that more-critical/relevant ones appear first, since only the first error is added to a field
      sorted_messages = messages_attributes.sort_by {|m| ['is_blank', 'not_numeric', 'too_short', 'too_long', 'failed_checksum'].index(m['key']) || 0 }
      add_messages(sorted_messages)
    end
    self
  end

  protected
  def add_messages(messages_attributes)
    messages_attributes.each do |message_attributes|
      message = Ronin::Message.new(message_attributes)
      messages << message
      if message.subclass == 'error'
        self.errors[message.context] = self.errors[message.context] || []
        self.errors[message.context] << message.description if self.errors[message.context].blank?
      end
    end
  end

  def replace(obj)
    attributes.replace(obj.attributes)
    errors.replace(obj.errors)
    messages.replace(obj.messages)
  end
end
