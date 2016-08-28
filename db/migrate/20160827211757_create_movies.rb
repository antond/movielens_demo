class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :title, null: false, limit: 127, index: true
      t.integer :year, index: true

      t.timestamps
    end
  end
end
