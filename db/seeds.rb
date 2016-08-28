# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

#
# Helper methods
#
def extract_title(title)
  title.gsub(/\s\(\d+\)/, '')
end

def extract_year(title)
  title.scan(/\((\d+)\)/).try(:first).try(:first)
end

# Process and prepare movies
movies_file = File.read(Rails.root.join('datasets', 'movielens', 'movies.csv'))
parsed_movies = CSV.parse(movies_file, headers: true, encoding: 'ISO-8859-1')
movie_attrs = []
genre_attrs = []
parsed_movies.each do |row|
  movie = {}
  orig = row.to_hash

  movie[:id] = orig['movieId'].to_i
  movie[:title] = extract_title(orig['title'])
  movie[:year] = extract_year(orig['title']).to_i
  time = Time.now
  movie[:created_at] = time
  movie[:updated_at] = time
  movie_attrs << movie

  # handle multiple genres
  orig['genres'].split('|').each do |genre|
    genre_attrs << { genre: genre, movie_id: movie[:id] }
  end
end
# insert in bulk for performance
Movie.bulk_insert(:id, :title, :year, :created_at, :updated_at) do |worker|
  movie_attrs.each do |attrs|
    worker.add(attrs)
  end
end
genre_attrs.each do |attrs|
  movie = Movie.find(attrs[:movie_id])
  # skip "no genres listed" cases
  unless attrs[:genre].eql?('(no genres listed)')
    movie.genres << Genre.find_or_create_by(name: attrs[:genre])
  end
end

# Process and store user -> movie tags
tags_file = File.read(Rails.root.join('datasets', 'movielens', 'tags.csv'))
parsed_tags = CSV.parse(tags_file, headers: true, encoding: 'ISO-8859-1')
parsed_tags.each do |row|
  orig = row.to_hash
  user = User.find_or_create_by(id: orig['userId'])
  movie = Movie.find(orig['movieId'])
  user.tag(movie, with: orig['tag'], on: 'tags')
end

# Process and prepare links
links_file = File.read(Rails.root.join('datasets', 'movielens', 'links.csv'))
parsed_links = CSV.parse(links_file, headers: true, encoding: 'ISO-8859-1')
link_attrs = []
parsed_links.each do |row|
  link = {}
  orig = row.to_hash

  link[:movie_id] = orig['movieId']
  link[:imdb_id] = orig['imdbId']
  link[:tmdb_id] = orig['tmdbId']
  time = Time.now
  link[:created_at] = time
  link[:updated_at] = time

  link_attrs << link
end
# Store links in bulk for performance
Link.bulk_insert do |worker|
  link_attrs.each do |attrs|
    worker.add(attrs)
  end
end

# Process and prepare ratings
ratings_file = File.read(Rails.root.join('datasets', 'movielens', 'ratings.csv'))
parsed_ratings = CSV.parse(ratings_file, headers: true, encoding: 'ISO-8859-1')
rating_attrs = []
parsed_ratings.each do |row|
  rating = {}
  orig = row.to_hash

  # create missing users
  User.find_or_create_by(id: orig['userId'])

  rating[:user_id] = orig['userId']
  rating[:movie_id] = orig['movieId']
  rating[:rating] = orig['rating']
  time = Time.at(orig['timestamp'].to_i)
  rating[:created_at] = time
  rating[:updated_at] = time

  rating_attrs << rating
end
# Store ratings in bulk for performance
Rating.bulk_insert do |worker|
  rating_attrs.each do |attrs|
    worker.add(attrs)
  end
end
