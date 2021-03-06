require 'nokogiri'
require 'open-uri'
require 'ethon'


root = Nokogiri::HTML(URI.open("https://windows10spotlight.com/"))
maxpage = root.css('nav.navigation.pagination > div.nav-links > a.page-numbers')[-2].content.to_i

(1..maxpage).each do |page|
  puts "Working on page #{page} of #{maxpage}"
  page = Nokogiri::HTML(URI.open("https://windows10spotlight.com/page/#{page}"))
  articles = page.css('article > h2 > a')
  articles.each do |article|
    imagepage = Nokogiri::HTML(URI.open(article["href"]))
    image = imagepage.css("article  figure > a") 
    image = imagepage.css("article div.entry a") if image.count == 0
    imageurl = image[0]["href"].to_s
    puts imageurl

    filesize = 0
    File.open("./images/" + imageurl.gsub(/^.*\/([^\/]+)$/, '\1'), "wb") do |saved_file|
      begin
        easy = Ethon::Easy.new url: imageurl, followlocation: true, ssl_verifypeer: false, headers: {
        'User-Agent' => 'fu'
        }         
          
        easy.on_body do |chunk, easy|
          saved_file.write(chunk) 
          filesize += chunk.length;
          :abort if filesize > 50000000   #~50 MB limit
        end
        
        easy.perform
      rescue
        # EXCEPTION!
      end 
      puts "size=#{filesize}"               
    end
  end
end

