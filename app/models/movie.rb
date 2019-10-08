class Movie < ApplicationRecord
  has_many :watchlists, dependent: :destroy
  mount_uploader :photo, PhotoUploader
  default_scope { order('created_at DESC') }

  include PgSearch::Model
  pg_search_scope :search_by_title_and_plot,
    against: [:title, :plot],
    using: {
      tsearch: { prefix: true }
    }
end
