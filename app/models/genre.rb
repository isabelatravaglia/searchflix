class Genre < ApplicationRecord
  belongs_to :movie
  validates :netflix_genre_id, presence: true
  validates :genre_name, presence: true, uniqueness: true
  validates :movie, uniqueness: { scope: [:netflix_genre_id] }
end
