class AddOmdbToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :omdb?, :boolean
  end
end
