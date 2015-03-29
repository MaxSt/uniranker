require 'rubygems'
require 'nokogiri'
require 'open-uri'

link = 'http://www.shanghairanking.com/SubjectCS2014.html'
page = Nokogiri::HTML(open(link))

allrows = page.css('table#UniversityRanking > tr')
allrows.shift #delete first element (first row is header)

universities = Array.new

allrows.each do |row|
  university = Hash.new
  cols = row.css('td')
  university[:rank] = cols[0].text
  university[:name] = cols[1].css('a').text
  university[:totalscore] = cols[3].css('div').text
  university[:alumni] = cols[4].css('div').text
  university[:award] = cols[5].css('div').text
  university[:hici] = cols[6].css('div').text
  university[:pub] = cols[7].css('div').text
  university[:top] = cols[8].css('div').text
  universities.push(university)
end

# universities.each do |u|
#   puts u[:rank] + ' | ' + u[:name]
# end

testuni = universities[0]
unistring = testuni[:name].tr(' ', '+')
link = 'https://www.google.at/search?q=' + unistring + '+tuition+total+per+year'
puts link
page = Nokogiri::HTML(open(link))
puts page.text

