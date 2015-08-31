# encoding: UTF-8

#use pure ruby dns lookup
require 'resolv-replace'

#parse xml/html
require 'nokogiri'

#open url
require 'open-uri'

@encoding = "ISO-8859-1"

#helper to generate REGEX for currency symbol before and after the value
def preorpost(str)
  value = "\\d+([\\,\\.]\\d+){0,2}"
  "(#{value}\\s*#{str})|(#{str}\\s*#{value})"
end

#all supported currencies in format [isostring] => regex
def getAllCurrencies
  {
  "EUR" => preorpost("\\€"),
  "USD" => preorpost("\\$"),
  "GBP" => preorpost("\\£"),
  "CHF" => preorpost("CHF"),
  "TWD" => preorpost("NT\\$"),
  "SGD" => preorpost("S\\$"),
  "HKD" => preorpost("HK\\$"),
  "CNY" => preorpost("(\\¥|RNB)")
  }
end

#generate regex for all supported currencies
def regexAllCurrencies
  currencies = getAllCurrencies
  cs = currencies.values

  cs_regex = "("
  cs.each do |s|
    cs_regex += s
    unless s == cs.last
      cs_regex += "|"
    end
  end
  cs_regex += ")"
  return cs_regex.force_encoding(@encoding)
end

#filter out number of string str
def getNumber(str)
  numberexp = "\\d+([\\,\\.]\\d+){0,2}$".force_encoding(@encoding)
  numberstr = str.match(/#{numberexp}/).to_s
  lastsep = numberstr.rindex(/[\.\,]\d{2}$/)
  if(lastsep)
    numberstr[lastsep] = 'X'
  end

  newsep = numberstr.rindex(/[\.\,]/)
  while(newsep)
    numberstr.slice! newsep
    newsep = numberstr.rindex(/[\.\,]/)
  end
  if(lastsep)
    numberstr[lastsep] = '.'
  end

  return numberstr.to_f
end

#filter out iso code of string str
def getISOCode(str)
  currencies = getAllCurrencies
  currencies.each_pair do |k, v|
    if str.match(/#{v.force_encoding(@encoding)}/)
      return k
    end
  end
  return nil
end

#convert currency String str to dollar
def convertToDollar(str, debug)
  isocode = getISOCode(str)
  value = getNumber(str)
  if(isocode == 'USD')
    if debug
      puts "Value in USD: #{value}"
    end
    return value
  else
    link = "http://www.xe.com/currencyconverter/convert/?Amount=" + value.to_s + "&From=#{isocode}&To=USD"
    convertpage = Nokogiri::HTML(open(URI.escape(link)))
    answer = convertpage.css('.uccRes .rightCol')[0].text.force_encoding(@encoding)
    newVal = getNumber(answer)
    if debug
      puts "Converted Value: #{str} to #{newVal.to_s}$"
    end
    return newVal
  end
end
