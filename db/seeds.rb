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

COUNTRY = 'portugal'
url_to_scrape = 'https://www.netflix.com/browse/genre/34399?so=az'
HTML_TO_SAVE = "/home/isabela/code/isabelatravaglia/searchflix/movies_#{COUNTRY}.html"
PN = Pathname.new(HTML_TO_SAVE)

def browser
  @_browser ||= Watir::Browser.new(:firefox)
end

def main_page?
  browser.element(id: 'userNavigationLabel').exist?
end

def scrape(url)
  puts "starting scraping!"
  file = open(url).read
  doc = Nokogiri::HTML(file)
  doc.search('.slider-refocus a').each do |movie|
    puts "creating movie #{movie.text}"
    m = Movie.new(title: movie.text)
    m.update("#{COUNTRY}": true)
    movie.css('img').each do |movie_image|
      movie_image_url = movie_image['src']
      m.remote_photo_url = movie_image_url
      m.save
      puts "saved movie #{m.title} with image #{m.photo.url}"
    end
  end
end

def save_html
  File.open(HTML_TO_SAVE, 'w') { |f| f.write @_browser.html }
  puts "html saved!"
  scrape(HTML_TO_SAVE)
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

def scroll_down(url_to_scrape)
  puts "checking if scrape file exists"
  puts "Does scrape file exist? #{PN.exist?}"
  if !PN.exist?
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
    save_html
  end
  scrape(HTML_TO_SAVE)
end
scroll_down(url_to_scrape)







# curl 'https://www.netflix.com/browse/genre/34399' --output movies2.html -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Cookie: NetflixId=v%3D2%26ct%3DBQAOAAEBEOPFuHszKwQd5U-Mjj0RW26BwA7-gtvkrE5YppLcCWExFCU2EeCz24TOaTvmnGpAgGCp01K8t2bhwVqJZQprCi0jjRHAF2XZh1kdiLjf0tZLqu7KtOMPEiPVa3nPJjYBAN3d5ppZ8wnozZ2JVZVqnQD2__BTqYqA6bjZHkXtRnFqn4lqE85moi2DfBqI9sy2sj3YfNrDog96uo_qjJ3227_FpTw4HGHu_7HFz-adz9gFRZm0hsyvA7fR6Bx-k7S8l2FSwOarGLx3z4XhARbkOEacPOAftgmJrQb_AgkOu6MLW0dKdmnABXaE5x6KeBzyeB8KBqlkeGTvNX6A9HAqXq5QlXI5a-r9DxYB_WncxdjMbyN_O6Hx2oHKnLWGwJrRS9QyjtkKVGGdzrKhE8BT7zubGyUC8NffJCPH1F3QNLe9WWciiEJamAAFoodyWgNqTVceM28vsONWCi0mRm5JIaPXyr_b77qAYmcwDov5T9x_fbqNqKWxsjzsXBjOQBcPATMGPl9_wnZEDIOLr4BUlya1Fk4ahNApMqmeJUDNiQ_aQcWmFs4ChyeZP9cWGRNBGfu4y4A5KA4t2zq3mDyPAsJbwvcEIQ_mi_C0RJcAGO4KSgk.%26bt%3Ddbl%26ch%3DAQEAEAABABRnEBzHUdDspQHgl2YjPiieW0sgSytGjyw.%26mac%3DAQEAEAABABQCYHK7jj0bPjdNcBaG1ExnJiPAkd11yUw.; SecureNetflixId=v%3D2%26mac%3DAQEAEQABABTYxNFsn5oulNN_ymlzwUfI96EiH7dwwh4.%26dt%3D1569265015254; flwssn=b0fc6a9c-f4be-483f-9454-affbb366851d; nfvdid=BQFmAAEBEKgKuu759eUG5QsTPSqJoyRg8eZjHt%2BToPNBHmz4Tu4pX1p7oDXBmalBcIK834O8GfykskE3e2gIlPa1eaEg9iz8rfHvQfJ5ZAvTSNf71EonWU7APIKun4VctBkfi%2BjbRphJbapebLYNXoIJzWZAjT8d; memclid=TkZDREZGLUxYLUZSSlZQSFY5N1JNMFI1MVdXQTUyTkRBQVQ1VEtLMQ; didUserInteractWithPage=true; hasSeenCookieDisclosure=true; dsca=anonymous; lhpuuidh-browse-XGGE767VBJFSPNLWHSWUMBRZSQ=PT%3AEN-BR%3Ae1afa36f-62f2-4c69-8b66-c8c30b9d2f91_ROOT; lhpuuidh-browse-XGGE767VBJFSPNLWHSWUMBRZSQ-T=1569255181738; clSharedContext=196b10a9-2fc0-4690-a6de-af963656436b; cL=1569265058326%7C15692602739862800%7C156926429481027256%7C%7C16%7CTQVEA3VJVRFWHLUGO52UPH44YM; profilesNewSession=0' -H 'Upgrade-Insecure-Requests: 1'

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

