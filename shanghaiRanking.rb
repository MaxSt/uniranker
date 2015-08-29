# encoding: UTF-8
require 'rubygems'

#use pure ruby dns lookup
require 'resolv-replace'

#parse xml/html
require 'nokogiri'

#open url
require 'open-uri'

#all currencies hash
require "./currencies.rb"

@encoding = "ISO-8859-1"

@currenciesRegexStr = regexAllCurrencies
#puts @currenciesRegexStr

#delay request from google
@delay = 0;

#limit univerities (nil for all)
@limit = 100;


def findOnSite(link, search)
  link = 'https://www.google.at/search?q=' + URI.escape(search) + URI.escape(' site:') + link
  sleep(@delay)
  findpage = Nokogiri::HTML(open(URI.escape(link)))
  results = findpage.css("#search div div div")
  return results.size > 0
end

def getTuition(universityname)
  unistring = universityname.tr(' ', '+')
  link = 'https://www.google.at/search?q=' + unistring + ' tuition+total+per+year'
  puts(URI.escape(link))
  sleep(@delay)
  tuitionpage = Nokogiri::HTML(open(URI.escape(link)))
  text = tuitionpage.css('#search').text.force_encoding(@encoding)
  return text.match(/#{@currenciesRegexStr}/).to_s
end

def convertToDollar(str)
  puts str
  isocode = getISOCode(str)
  puts isocode
  value = getNumber(str)
  puts value
  if(isocode == 'USD')
    return value
  else
    link = "http://www.xe.com/currencyconverter/convert/?Amount=" + value.to_s + "&From=#{isocode}&To=USD"
    sleep(@delay)
    convertpage = Nokogiri::HTML(open(URI.escape(link)))
    answer = convertpage.css('.uccRes .rightCol')[0].text
    return answer
  end

  # TODO NEU BERECHNEN
  # if value.length > 0
  #   currencySign = value[0]
  #   if currencySign == "$"
  #     return value.slice!(0)
  #   else
  #     value.slice!(0)
  #     link = "http://www.xe.com/currencyconverter/convert/?Amount=" + value.to_s + "&From=" + @currencies[currencySign].to_s + "&To=USD"
  #     sleep(@delay)
  #     convertpage = Nokogiri::HTML(open(URI.escape(link)))
  #     answer = convertpage.css('.uccRes .rightCol')[0].text
  #     return ("$" + answer)
  #   end
  # else
  #   return "$0"
  # end
end

def outputUniversity(university, *keys)
  if keys.length > 0
    keys.each do |key|
      out = university[key.to_sym]
      if out == true || out == false
        print out ? "yes" : "no"
      else
        print(out.length == 0 ? "X" : out)
      end
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


def parseShanghaiRanking(link, debug)
  page = Nokogiri::HTML(open(link))

  allrows = page.css('table#UniversityRanking > tr')
  allrows.shift #delete first element (first row is header)

  universities = Array.new
  allrows.each_with_index do |row, index|
    break if @limit && index >= @limit
    university = Hash.new
    cols = row.css('td')
    university[:rank] = cols[0].text
    university[:name] = cols[1].css('a').text
    university[:link] = cols[1].css('a')[0]["href"]
    university[:totalscore] = cols[3].css('div').text
    university[:alumni] = cols[4].css('div').text
    university[:award] = cols[5].css('div').text
    university[:hici] = cols[6].css('div').text
    university[:pub] = cols[7].css('div').text
    university[:top] = cols[8].css('div').text
    university[:tuition] = convertToDollar(getTuition(university[:name]))
    university[:englishcourse] = findOnSite(university[:link],"programming course")
    if debug
      #outputUniversity(university, 'rank', 'name', 'tuition', 'englishcourse')
      outputUniversity(university, 'name')
    end
    universities.push(university)
  end
  return universities
end


# universities.each do |u|
#   puts u[:rank] + ' | ' + u[:name]
# end

