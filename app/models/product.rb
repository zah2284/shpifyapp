class Product < ApplicationRecord
	attr_accessor :image
  belongs_to :shop

  validates :product_id,
            :uniqueness => true,
            :presence => true


end
