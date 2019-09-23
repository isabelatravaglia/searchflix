class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :title
      t.date :year
      t.string :director
      t.string :plot
      t.text :actors
      t.string :photo
      t.float :imdb_score
      t.boolean :brazil
      t.boolean :us
      t.boolean :portugal
      t.boolean :germany
      t.boolean :sweden
      t.boolean :france

      t.timestamps
    end
  end
end
