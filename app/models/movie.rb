class Movie < ApplicationRecord
  has_many :watchlists, dependent: :destroy
  mount_uploader :photo, PhotoUploader
end
