class AddRuntimeGenreWritersToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :runtime, :string
    add_column :movies, :genre, :string
    add_column :movies, :writer, :string
  end
end
