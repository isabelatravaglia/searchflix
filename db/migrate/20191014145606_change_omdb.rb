class ChangeOmdb < ActiveRecord::Migration[6.0]
  def change
    rename_column :movies, :omdb?, :omdb
  end
end
