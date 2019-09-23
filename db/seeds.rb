# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "destroying movies"
Movie.destroy_all

puts "destroying users"
User.destroy_all

puts "destroying watchlists"
Watchlist.destroy_all


puts "creating user"
u = User.create(email: "admin@admin.com", password:"123456")

puts "creating movies"

url= "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SY1000_CR0,0,704,1000_AL_.jpg"
m1 = Movie.new(
  title: "The Godfather",
  director: "Francis Ford Coppola",
  plot: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
  actors: "Marlon Brando, Al Pacino",
  imdb_score: 9.2,
  year: 1972
)
m1.remote_photo_url = url
m1.save

puts "creating watchlist"

w1 = Watchlist.create(movie: m1, user: u)

