class CreateGenresMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :genres_movies, { id: false } do |t|
      t.references :genre, index: true, null: false
      t.references :movie, index: true, null: false
    end

    add_index :genres_movies, [:genre_id, :movie_id], unique: true
  end
end
