module Samurai
  module Helpers
    def payment_method_attributes
      {
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
  end
end
