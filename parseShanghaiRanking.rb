#encoding: UTF-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'

def getTuition(universityname)
  unistring = universityname.tr(' ', '+')
  link = 'https://www.google.at/search?q=' + unistring + '+tuition+total+per+year'
  page = Nokogiri::HTML(open(link))
  text = page.css('#search').text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
  return text.match(/[\$\€\£]\d+[\,\.]\d+/).to_s
end

def convertToDollar(value)
  if value.length > 0
    if value[0] == '$'
      return value
    else
      link = 'https://www.google.at/search?q=' + value + ' to $'
      # TODO
      puts URI.escape(link)
      page = Nokogiri::HTML(open(URI.escape(link)))
      answer = page.css('div.vk_ans')[0].text
      return ("$" + answer)
    end
  else
    return "$0"
  end
end

def outputUniversity(university, *keys)
  if keys.length > 0
    keys.each do |key|
      out = university[key.to_sym]
      print(out.length == 0 ? "X" : out)
      STDOUT.flush
      if key == keys.last
        puts ""
      else
        print " | "
        STDOUT.flush
      end
    end
  else
    puts "wrong Parameters in outputUniversity"
  end
end

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
  university[:tuition] = convertToDollar(getTuition(university[:name]))
  outputUniversity(university, 'rank', 'name', 'tuition')
  universities.push(university)
end


# universities.each do |u|
#   puts u[:rank] + ' | ' + u[:name]
# end

