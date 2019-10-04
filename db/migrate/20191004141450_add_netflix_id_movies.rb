class AddNetflixIdMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :netflix_id, :string
  end
end
