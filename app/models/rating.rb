class Rating < ApplicationRecord
  validates_presence_of :rating
  validates_numericality_of :rating, minimum: 1, maximum: 5

  belongs_to :movie
  belongs_to :user
end
