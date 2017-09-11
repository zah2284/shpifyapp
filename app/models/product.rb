class Product < ApplicationRecord

  belongs_to :shop

  validates :product_id,
            :uniqueness => true,
            :presence => true
end
