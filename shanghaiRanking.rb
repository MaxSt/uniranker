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

#delay request for google search
@delay = 0;

#limit univerities (nil for all)
@limit = nil;


#find <search> on site <link> returns true if <search> found
def findOnSite(link, search)
  link = 'https://www.google.at/search?q=' + URI.escape(search) + URI.escape(' site:') + link
  sleep(@delay)
  findpage = Nokogiri::HTML(open(URI.escape(link)))
  results = findpage.css("#search div div div")
  return results.size > 0
end

#get tuition for university <universityname>
def getTuition(universityname)
  unistring = universityname.tr(' ', '+')
  link = 'https://www.google.at/search?q=' + unistring + ' tuition+total+per+year'
  sleep(@delay)
  tuitionpage = Nokogiri::HTML(open(URI.escape(link)))
  text = tuitionpage.css('#search').text.force_encoding(@encoding)
  #rutrn match of @currenciesRegexStr and trim newline characters
  return text.match(/#{@currenciesRegexStr}/).to_s.gsub("\n","")
end


def outputUniversity(university, *keys)
  if keys.length > 0
    keys.each do |key|
      out = university[key]
      if out == true || out == false
        print out ? "yes" : "no"
      else
        print(out)
      end
      STDOUT.flush
      if key == keys.last
        puts ""
      else
        print " | "
        STDOUT.flush
      end
    end
    puts "-------------------------------------"
  else
    puts "wrong Parameters in outputUniversity"
  end
end


def parseShanghaiRanking(link, debug, course)
  page = Nokogiri::HTML(open(link))

  allrows = page.css('table#UniversityRanking > tr')
  allrows.shift #delete first element (first row is header)

  universities = Array.new
  allrows.each_with_index do |row, index|
    #when limit is not null only fetch @limit universities
    break if @limit && index >= @limit

    university = Hash.new
    cols = row.css('td')
    university["rank"] = cols[0].text
    university["name"] = cols[1].css('a').text
    university["link"] = cols[1].css('a')[0]["href"]
    university["totalscore"] = cols[3].css('div').text
    university["alumni"] = cols[4].css('div').text
    university["award"] = cols[5].css('div').text
    university["hici"] = cols[6].css('div').text
    university["pub"] = cols[7].css('div').text
    university["top"] = cols[8].css('div').text
    university["tuition"] = convertToDollar(getTuition(university["name"]), debug).to_s
    university["coursefound"] = findOnSite(university["link"], "course #{course}")

    if debug
      outputUniversity(university, "rank", "name", "tuition", "coursefound")
    end

    universities.push(university)

  end
  return universities
end
