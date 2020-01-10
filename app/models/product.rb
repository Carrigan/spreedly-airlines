class Product < ApplicationRecord
    has_many :purchases
    
    def formatted_price
        "$#{(price / 100).to_int}.#{(price % 100).to_s.ljust(2, '0')}"
    end
end
