# encoding: UTF-8
require 'rubygems'

#use pure ruby dns lookup
require 'resolv-replace'

#parse xml/html
require 'nokogiri'

#open url
require 'open-uri'

@encoding = "ISO-8859-1"
@currencies = {"€" => "EUR", "£" => "GBP", "$" => "USD"}
@currenciesRegexStr = "["
@currencies.each_pair do |k, v|
  @currenciesRegexStr += "\\" + k.to_s
end
@currenciesRegexStr += ']\d+[\,\.]\d+'
@currenciesRegexStr.force_encoding(@encoding)


def getTuition(universityname)
  unistring = universityname.tr(' ', '+')
  link = 'https://www.google.at/search?q=' + unistring + '+tuition+total+per+year'
  tuitionpage = Nokogiri::HTML(open(link))
  text = tuitionpage.css('#search').text.force_encoding(@encoding)
  return text.match(/#{@currenciesRegexStr}/).to_s
end

def convertToDollar(value)
  if value.length > 0
    currencySign = value[0]
    if currencySign == "$"
      return value
    else
      value.slice!(0)
      link = "http://www.xe.com/currencyconverter/convert/?Amount=" + value.to_s + "&From=" + @currencies[currencySign].to_s + "&To=USD"
      convertpage = Nokogiri::HTML(open(URI.escape(link)))
      answer = convertpage.css('.uccRes .rightCol')[0].text
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

def parseShanghaiRanking(link)
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
end


# universities.each do |u|
#   puts u[:rank] + ' | ' + u[:name]
# end

