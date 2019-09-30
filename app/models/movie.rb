class Movie < ApplicationRecord
  has_many :watchlists, dependent: :destroy
  mount_uploader :photo, PhotoUploader
  default_scope { order('created_at DESC') }
end
