class CreateGenres < ActiveRecord::Migration[6.0]
  def change
    create_table :genres do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :netflix_genre_id
      t.string :genre_name

      t.timestamps
    end
  end
end
