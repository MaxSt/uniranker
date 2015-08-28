require "./shanghaiRanking.rb"

#json
require 'json'

#ruby template language
require 'erb'

#parse options
require 'optparse'

def outputToHtmlTable(universities, filename)
  File.open('./' + filename, 'w') do |new_file|
    @universities = universities
    new_file.write ERB.new(File.read('./table.html.erb')).result(binding)
  end
end

def writeHashToJSON(hash, filename)
  File.open("./" + filename,"w") do |f|
    f.write(hash.to_json)
  end
end

def getHashFromJson(filename)
  File.open( filename, "r" ) do |f|
    JSON.load(f)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: uniranker.rb [options]"

  opts.on("-wFILE", "--write-json-file=FILE", "Write universities as json to File [FILE]") do |v|
    options[:writejson] = v
  end

  opts.on("-rFILE", "--read-json-file=FILE", "read universities from json file [FILE]") do |v|
    options[:readjson] = v
  end

  opts.on("-d", "--debug-output", "Output debug Messages") do |v|
    options[:debug] = true
  end
end.parse!

link = 'http://www.shanghairanking.com/SubjectCS2014.html'

if !options[:readjson]
  universities = parseShanghaiRanking(link, options[:debug] || false)
else
  universities = getHashFromJson(options[:readjson])
end

if options[:writejson]
  puts "saving univerities to #{options[:writejson]}"
  writeHashToJSON(universities, options[:writejson])
end

maxTuition = universities.reduce([]){ |arr, u|
  arr.push(u["tuition"].sub!(',', '').to_f)
}.max

universities.each do |u|
  sum = u["alumni"].to_f * 0.7
  sum += u["award"].to_f * 0.12
  sum += u["hici"].to_f * 0.22
  sum += u["pub"].to_f * 0.22
  sum += u["top"].to_f * 0.22
  sum += (maxTuition - u["tuition"].sub!(',', '').to_f) / maxTuition
  u["newVAL"] = sum
end

outputToHtmlTable(universities, 'output.html')
puts "html table written to output.html"

