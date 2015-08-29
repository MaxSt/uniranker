# encoding: UTF-8
@encoding = "ISO-8859-1"

def preorpost(str)
  number = "\\d+([\\,\\.]\\d+){0,2}"
  "(#{number}\\s*#{str})|(#{str}\\s*#{number})"
end
def getAllCurrencies
  {
  "EUR" => preorpost("\\€"),
  "USD" => preorpost("\\$"),
  "GBP" => preorpost("\\£"),
  "CHF" => preorpost("CHF"),
  "TWD" => preorpost("NT\\$"),
  "SGD" => preorpost("S\\$"),
  "CNY" => preorpost("(\\¥|RNB)")
  }
end

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

def getNumber(str)
  numberexp = "\\d+([\\,\\.]\\d+){0,2}".force_encoding(@encoding)
  numberstr = str.match(/#{numberexp}/).to_s
  lastsep = numberstr.rindex(/[\.\,]/)
  if(lastsep)
    numberstr[lastsep] = 'X'
    newsep = numberstr.rindex(/[\.\,]\d{2}/)
    while(newsep)
    numberstr.slice! newsep
    newsep = numberstr.rindex(/[\.\,]/)
    end
    numberstr[lastsep] = '.'
  end
  return numberstr.to_f
end

def getISOCode(str)
  currencies = getAllCurrencies
  currencies.each_pair do |k, v|
    if str.match(/#{v.force_encoding(@encoding)}/)
      return k
    end
  end
  return nil
end
# {
# "USD" => "\\$",
# "GBP" => "\\£",
# "EUR" => "\\€",
# "AFN" => "\\؋",
# "ALL" => "Lek",
# "ARS" => "\\$",
# "AWG" => "\\ƒ",
# "AUD" => "\\$",
# "AZN" => "\\м\\а\\н",
# "BSD" => "\\$",
# "BBD" => "\\$",
# "BYR" => "p\\.",
# "BZD" => "BZ\\$",
# "BMD" => "\\$",
# "BOB" => "\\$b",
# "BAM" => "KM",
# "BWP" => "P",
# "BGN" => "\\л\\в",
# "BRL" => "R\\$",
# "BND" => "\\$",
# "KHR" => "\\៛",
# "CAD" => "\\$",
# "KYD" => "\\$",
# "CLP" => "\\$",
# "CNY" => "\\¥",
# "CNB" => "\\¥",
# "COP" => "\\$",
# "CRC" => "\\₡",
# "HRK" => "kn",
# "CUP" => "\\₱",
# "CZK" => "K\\č",
# "DKK" => "kr",
# "DOP" => "RD\\$",
# "XCD" => "\\$",
# "EGP" => "\\£",
# "SVC" => "\\$",
# "EEK" => "kr",
# "FKP" => "\\£",
# "FJD" => "\\$",
# "GHC" => "\\¢",
# "GIP" => "\\£",
# "GTQ" => "Q",
# "GGP" => "\\£",
# "GYD" => "\\$",
# "HNL" => "L",
# "HKD" => "\\$",
# "HUF" => "Ft",
# "ISK" => "kr",
# "IDR" => "Rp",
# "IRR" => "\\﷼",
# "IMP" => "\\£",
# "ILS" => "\\₪",
# "JMD" => "J\\$",
# "JPY" => "\\¥",
# "JEP" => "\\£",
# "KZT" => "\\лв",
# "KPW" => "\\₩",
# "KRW" => "\\₩",
# "KGS" => "\\л\\в",
# "LAK" => "\\₭",
# "LVL" => "Ls",
# "LBP" => "\\£",
# "LRD" => "\\$",
# "LTL" => "Lt",
# "MKD" => "\\д\\е\\н",
# "MYR" => "RM",
# "MUR" => "\\₨",
# "MXN" => "\\$",
# "MNT" => "\\₮",
# "MZN" => "MT",
# "NAD" => "\\$",
# "NPR" => "\\₨",
# "ANG" => "\\ƒ",
# "NZD" => "\\$",
# "NIO" => "C\\$",
# "NGN" => "\\₦",
# "KPW" => "\\₩",
# "NOK" => "kr",
# "OMR" => "\\﷼",
# "PKR" => "\\₨",
# "PYG" => "Gs",
# "PHP" => "\\₱",
# "PLN" => "z\\ł",
# "QAR" => "\\﷼",
# "RON" => "lei",
# "RUB" => "\\р\\у\\б",
# "SHP" => "\\£",
# "SAR" => "\\﷼",
# "RSD" => "\\Д\\и\\н\\.",
# "SCR" => "\\₨",
# "SGD" => "\\$",
# "SBD" => "\\$",
# "SOS" => "S",
# "ZAR" => "R",
# "KRW" => "\\₩",
# "LKR" => "\\₨",
# "SEK" => "kr",
# "CHF" => "CHF",
# "SRD" => "\\$",
# "SYP" => "\\£",
# "TWD" => "NT\\$",
# "THB" => "\\฿",
# "TTD" => "TT\\$",
# "TRL" => "\\₤",
# "TVD" => "\\$",
# "UAH" => "\\₴",
# "UYU" => "\\$U",
# "UZS" => "\\л\\в",
# "VEF" => "Bs",
# "VND" => "\\₫",
# "YER" => "\\﷼",
# "ZWD" => "Z\\$"}
# }
