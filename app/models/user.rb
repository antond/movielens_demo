class User < ApplicationRecord
  acts_as_tagger

  has_many :ratings
  has_many :movies, through: :ratings
end
