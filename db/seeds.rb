# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

start_time = Time.now
puts "started seeding at #{start_time}"

puts "destroying movies"
# Movie.destroy_all

puts "destroying users"
User.destroy_all

puts "destroying watchlists"
Watchlist.destroy_all

puts "creating user"
u = User.create(email: "admin@admin.com", password: "123456")

puts "creating movies"

INDEX_CRITERION = ['az', 'za']
urls_to_scrape = INDEX_CRITERION.map { |c| "https://www.netflix.com/browse/genre/34399?so=#{c}" }

def browser
  if Rails.env.production?
    @_browser ||= Watir::Browser.new :chrome
  else
    @_browser ||= Watir::Browser.new(:firefox)
  end
end

def main_page?
  browser.element(id: 'userNavigationLabel').exist?
end

def scrape(saved_html)
  puts "starting scraping!"
  file = open(saved_html[:url]).read
  doc = Nokogiri::HTML(file)
  doc.search('.slider-refocus a').each do |movie|
    puts "creating/updating movie #{movie.text}"
    m = Movie.find_or_initialize_by(title: movie.text)
    puts "setting #{saved_html[:country]} to true"
    country = saved_html[:country]
    m[:"#{country}"] = true
    m.save
    puts "movie #{m.title} has #{country} as #{m[:"#{country}"]}"
    puts "movie #{m.title} has id #{m.id}"
    next unless m.id.nil?

    puts "#{movie.text} is new!"
    movie.css('img').each do |movie_image|

      movie_image_url = movie_image['src']
      image_download_start_time = Time.now
      puts "starting image download at #{image_download_start_time}"
      sleep(rand(3..5))
      m.remote_photo_url = movie_image_url
      m.save
      image_download_end_time = Time.now
      image_download_total_length = (image_download_end_time - image_download_start_time)
      puts "finished image download at #{image_download_end_time}. Total length is #{image_download_total_length} seconds"
      puts "saved movie #{m.title} with image #{m.photo.url}"
    end
  end
end

def save_html(html_to_save)
  File.open(html_to_save[:url], 'w') { |f| f.write @_browser.html }
  puts "html saved!"
  scrape(html_to_save)
end

def login
  puts "login in"
  return true if @logged_in

  browser.goto('https://www.netflix.com/pt-en/login')
  form = browser.form

  return false unless form.exist?

  form.text_field(name: 'userLoginId').set(ENV["NETFLIX_USERNAME"])
  form.text_field(name: 'password').set(ENV["NETFLIX_PASSWORD"])
  form.button(type: 'submit').click
  puts "logged in!"

  profile = browser.span(class: "profile-name")
  profile.click

  sleep(2)

  @logged_in = main_page?
end

def scrape_html(country, criterion)
  if Rails.env.production?
    html_to_save = {
      url: "/app/movies_#{country}_#{criterion}.html",
      country: country,
      criterion: criterion
    }
  else
    html_to_save = {
      url: "/home/isabela/code/isabelatravaglia/searchflix/movies_#{country}_#{criterion}.html",
      country: country,
      criterion: criterion
    }
  end
  html_to_save
end

def scroll_down(url_to_scrape, country)
  puts "checking if scrape file exists"
  criterion = url_to_scrape.split("").last(2).join
  pn = Pathname.new(scrape_html(country, criterion)[:url])
  puts "Does scrape file exist? #{pn.exist?}"

  if !pn.exist?
    login unless @logged_in
    puts "going to scroll down scrape page"
    browser.goto(url_to_scrape)
    loop do
      puts "scrolling..."
      link_number = browser.links.size
      browser.scroll.to :bottom
      sleep(2)
      break if browser.links.size == link_number
    end
    puts "finished scrolling. Saving html!"
    save_html(scrape_html(country, criterion))
  end
  scrape(scrape_html(country, criterion))
end

country = 'brazil'
urls_to_scrape.each { |url| scroll_down(url, country) }

end_time = Time.now
total_length = (end_time - start_time) / 60
puts "finished seeding at #{end_time}"
puts "total running time was approximately #{total_length} minutes"

# url= "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SY1000_CR0,0,704,1000_AL_.jpg"
# m1 = Movie.new(
#   title: "The Godfather",
#   director: "Francis Ford Coppola",
#   plot: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
#   actors: "Marlon Brando, Al Pacino",
#   imdb_score: 9.2,
#   year: 1972
# )
# m1.remote_photo_url = url
# m1.save

# puts "creating watchlist"

# w1 = Watchlist.create(movie: m1, user: u)
