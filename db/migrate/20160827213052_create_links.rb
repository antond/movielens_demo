class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.references :movie, foreign_key: true, null: false, index: true
      t.integer :imdb_id
      t.integer :tmdb_id

      t.timestamps
    end
  end
end
