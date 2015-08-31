# encoding: UTF-8
require "./shanghaiRanking.rb"

#json
require 'json'

#ruby template language
require 'erb'

#parse options
require 'optparse'

#write ruby hash <universities> to file <filename> as html table
def outputToHtmlTable(universities, filename)
  File.open('./' + filename, 'w') do |new_file|
    @universities = universities
    new_file.write ERB.new(File.read('./table.html.erb')).result(binding)
  end
end

#write ruby hash <hash> to file <filename> in json format
def writeHashToJSON(hash, filename)
  File.open("./" + filename,"w") do |f|
    f.write(JSON.pretty_generate(hash))
  end
end

#read file <filename> (json format) and returns ruby hash
def getHashFromJson(filename)
  File.open( filename, "r" ) do |f|
    JSON.load(f)
  end
end

options = {}
#parse command line options
OptionParser.new do |opts|
  opts.banner = "Usage: uniranker.rb [options]"

  #option for writing fetched universities to json file
  opts.on("-wFILE", "--write-json-file=FILE", "Write universities as json to File [FILE]") do |v|
    options[:writejson] = v
  end

  #option for getting universities from json file (does not fetch universities
  #from web queries)
  opts.on("-rFILE", "--read-json-file=FILE", "Read universities from json file [FILE]") do |v|
    options[:readjson] = v
  end

  #option for debug output
  opts.on("-d", "--debug-output", "Output debug Messages") do |v|
    options[:debug] = true
  end

  #option for setting output file (output is in html format)
  opts.on("-o", "--output", "Set Output file (output is in html format)") do |v|
    options[:output] = v
  end

end.parse!

link = 'http://www.shanghairanking.com/SubjectCS2014.html'

#when option readjson is set
if !options[:readjson]
  universities = parseShanghaiRanking(link, options[:debug] || false)
else
  puts "reading univerities from #{options[:readjson]}"
  universities = getHashFromJson(options[:readjson])
end

#when option writejson is set
if options[:writejson]
  puts "saving univerities to #{options[:writejson]}"
  writeHashToJSON(universities, options[:writejson])
end

rankedUniversities = rankUniversities(universities)

#set default output if it is not set manually
options[:output] = 'output.html' if options[:output]

outputToHtmlTable(rankedUniversities, options[:output])
puts "html table written to #{options[:output]}"

