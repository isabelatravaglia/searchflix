# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# proxy_options = { http_proxyaddr: 'us-central.windscribe.com', http_proxyport: 443, http_proxyuser: 'lu1v0mtx-gsqrmd5', http_proxypass: 'pkzwjv4e7g' }
# puts HTTParty.get('http://api.ipify.org', proxy_options).body

start_time = Time.now
puts "started seeding at #{start_time}"

# puts "destroying movies"
# Movie.destroy_all

puts "destroying watchlists"
Watchlist.destroy_all

puts "destroying users"
User.destroy_all

puts "creating user"
u = User.create(email: "admin@admin.com", password: "123456")

puts "creating movies"

COUNTRY = 'us'
MOVIE_PATH = 'https://www.netflix.com/browse/genre/34399'

# INDEX_CRITERION = ['az', 'za']
# urls_to_scrape = INDEX_CRITERION.map { |c| "https://www.netflix.com/browse/genre/34399?so=#{c}" }

PROD_HTML_PATH = "/app/countries/"
DEV_HTML_PATH = "/home/isabela/code/isabelatravaglia/searchflix/countries/"
Rails.env.production? ? HTML_PATH = PROD_HTML_PATH : HTML_PATH = DEV_HTML_PATH

def browser
  if Rails.env.production?
    @_browser ||= Watir::Browser.new :chrome
  else
    @_browser ||= Watir::Browser.new :firefox #, headless: true
  end
end

def main_page?
  browser.element(id: 'userNavigationLabel').exist?
end

def puts_movie_image_runtime(image_download_start_time)
  image_download_end_time = Time.now
  image_download_total_length = (image_download_end_time - image_download_start_time)
  puts "finished image download at #{image_download_end_time}. Total length is #{image_download_total_length} seconds"
end

def handle_api_responses(m, response)
  if JSON.parse(response)["Error"] == "Movie not found!"
    m.omdb = false
    m.save
    puts "Movie not found!"
    response
  else
    case response.code
    when 200
      puts "It worked!"
      response
    when 401
      puts "Error 401!"
      response
    else
      response.return!(&block)
    end
  end
end

ENCODING_OPTIONS = {
  invalid: :replace, # Replace invalid byte sequences
  undef: :replace, # Replace anything not defined in ASCII
  replace: '', # Use a blank for those replacements
  universal_newline: true # Always break lines with \n
}

def fetch_movie_details(m, title, year)
  puts "fetching movie details from OMDB"
  clean_title = title.gsub('#', '').encode(Encoding.find('ASCII'), ENCODING_OPTIONS)
  omdb_response = RestClient.get("http://www.omdbapi.com/?t=#{clean_title}&y=#{year}&apikey=#{ENV["OMDB_KEY"]}") do |response, request, result, &block|
    handle_api_responses(m, response)
  end
  rsp_json = JSON.parse(omdb_response).symbolize_keys
  m.director = rsp_json[:Director]
  m.runtime = rsp_json[:Runtime]
  m.genre = rsp_json[:Genre]
  m.writer = rsp_json[:Writer]
  m.actors = rsp_json[:Actors]
  m.plot = rsp_json[:Plot]
  m.imdb_score = rsp_json[:imdbRating]
  puts "done with fetching OMDB details"
end

def fetch_movie_year(m)
  puts "start fetching movie year"
  netflix_id = m.netflix_id
  browser.goto("https://www.netflix.com/title/#{netflix_id}")
  return if browser.element(class: 'errorBox').exists?

  year_spans = browser.spans(class: ["title-info-metadata-item", "item-year"])
  year = year_spans[0].text.to_i
  m.year = year
  puts "Movie year is #{m.year}"
  sleep(rand(2..7))
end

def fetch_movie_image(movie, m)
  movie.css('img').each do |movie_image|
    movie_image_url = movie_image['src']
    image_download_start_time = Time.now
    puts "starting image download at #{image_download_start_time}"
    sleep(rand(3..5)) # avoid website block
    m.remote_photo_url = movie_image_url
    puts_movie_image_runtime(image_download_start_time)
    puts "saved movie #{m.title} with image #{m.photo.url}"
  end
end

def fetch_movie_netflix_id(movie)
  href = movie['href']
  href ? netflix_id = href[7..14] : netflix_id = "0000000"
  netflix_id
end

def fetch_movie_country(m)
  puts "setting #{COUNTRY} to true"
  m[:"#{COUNTRY}"] = true
end

def scrape(saved_html)
  puts "starting scraping!"
  file = open(saved_html[:url]).read
  doc = Nokogiri::HTML(file)
  doc.search('.slider-refocus a').each do |movie|
    puts "creating/updating movie #{movie.text}"
    netflix_id = fetch_movie_netflix_id(movie)
    m = Movie.find_or_initialize_by(netflix_id: netflix_id)
    puts "checking if movie #{movie.text} is new for #{COUNTRY}."
    puts "Does movie #{movie.text} has ID? #{!m.id.nil?}"
    puts "Does movie #{movie.text} has #{COUNTRY} set to true? #{m[:"#{COUNTRY}"]}"
    # fetch_movie_details(m, m.title, m.year) if (m.imdb_score.nil? and m.omdb != false)
    # m.save
    m.genre = saved_html[:genre_name]
    m.save
    next if !m.id.nil? && m[:"#{COUNTRY}"] == true # skip if movie already exists for the current country

    fetch_movie_country(saved_html, m)

    puts m.id.nil? ? "movie #{m.title} still doesn't have an id" : "movie #{m.title} has id #{m.id}"
    next unless m.id.nil? # skip if movie already exists

    m.netflix_id = netflix_id
    fetch_movie_year(m) if m.year.nil?
    m.title = movie.text
    fetch_movie_details(m, m.title, m.year)
    fetch_movie_image(movie, m)
    m.save
    puts "#{movie.text} create with id #{m.id}!"
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

def fetch_html_to_save(genre_code, genre_name)
  html_to_save = {
    url: "#{HTML_PATH}#{COUNTRY}/movies_#{COUNTRY}_#{genre_code}.html",
    country: COUNTRY,
    genre_code: genre_code,
    genre_name: genre_name
  }
  html_to_save
end

def scrolling(url_to_scrape)
  puts "going to scroll down scrape page"
  browser.goto(url_to_scrape)
  loop do
    puts "scrolling..."
    link_number = browser.links.size
    browser.scroll.to :bottom
    sleep(2)
    break if browser.links.size == link_number
  end
  puts "finished scrolling!"
end

# def prepare_to_scroll_down(url_to_scrape)
#   puts "checking if scrape file exists"
#   criterion = url_to_scrape.split("").last(2).join
#   pn = Pathname.new(fetch_html_to_save(criterion)[:url])
#   puts "Does scrape file exist? #{pn.exist?}"
#   if !pn.exist?
#     login unless @logged_in
#     scrolling(url_to_scrape)
#     save_html(fetch_html_to_save(criterion))
#   end
#   scrape(fetch_html_to_save(criterion))
# end

def create_scrape_file(genre_code, genre_name)
  url_to_scrape = "https://www.netflix.com/browse/genre/#{genre_code}?bc=34399"
  scrolling(url_to_scrape)
  fetch_html_to_save(genre_code, genre_name)
end

def generate_movie_genre_hash(genre_div)
  genre_hash = {}
  genre_div.uls.each do |li|
    li.each do |e|
      genre_url = e.a.href
      genre_code = genre_url.partition("genre/").last.partition("?").first.to_i
      genre_hash[genre_code] = e.a.text
    end
  end
  genre_hash
end

def fetch_country_movie_genres
  login unless @logged_in
  browser.goto(MOVIE_PATH)
  genre_btn = browser.div(class: "nfDropDown")
  genre_btn.click
  genre_div = browser.div(class: ["sub-menu", "theme-lakira"])
  generate_movie_genre_hash(genre_div)
end

def check_scrape_files_existence
  puts "checking if scrape files for #{COUNTRY} exist"
  puts "creating countries dir if they don't exist"
  country_dir = Pathname.new("countries/#{COUNTRY}")
  FileUtils.mkdir_p "countries/#{COUNTRY}" unless country_dir.exist?
  fetch_country_movie_genres.each do |hash_element|
    genre_code = hash_element.first
    genre_name = hash_element.last
    scrape_file = "countries/#{COUNTRY}/movies_#{COUNTRY}_#{genre_code}.html"
    scrape_file_path = Pathname.new(scrape_file)
    if scrape_file_path.exist?
      puts "Scrape file movies_#{COUNTRY}_#{genre_code}.html already exists. Would you like to overwrite it? (y/n)"
      gets.chomp == "y" ? create_scrape_file(genre_code) : scrape(fetch_html_to_save(genre_code, genre_name))
    end
    create_scrape_file(genre_code, genre_name)
  end
end

check_scrape_files_existence

puts "creating watchlist"
m1 = Movie.last
m2 = Movie.first
Watchlist.create(movie: m1, user: u)
Watchlist.create(movie: m2, user: u)

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


