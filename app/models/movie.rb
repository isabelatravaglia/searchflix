class Movie < ApplicationRecord
  has_many :watchlists
  mount_uploader :photo, PhotoUploader
end
