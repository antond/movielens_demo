class Movie < ApplicationRecord
  acts_as_taggable_on :tags

  validates :title, presence: true, length: { minimum: 1, maximum: 127 }

  has_and_belongs_to_many :genres
  has_many :links
  has_many :ratings
  has_many :raters, through: :ratings, source: :user
end
