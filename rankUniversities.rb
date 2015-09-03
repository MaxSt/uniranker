# encoding: UTF-8

def rankUniversities(universities)

  #get highest Tuition
  maxTuition = universities.reduce([]){ |arr, u|
    arr.push(u["tuition"].to_f)
  }.max

  rankedUniversities = universities.reduce([]){ |arr, u|
    #calculate score
    score = ( u["alumni"].to_f / 100 ) * 0.07
    score += ( u["award"].to_f / 100 ) * 0.12
    score += ( u["hici"].to_f / 100 ) * 0.22
    score += ( u["pub"].to_f / 100 ) * 0.22
    score += ( u["top"].to_f / 100 ) * 0.22
    tuitionpercent = ( maxTuition - u["tuition"].to_f ) / maxTuition
    score += tuitionpercent * 0.10
    if(u["coursefound"])
      score += 1 * 0.05
    end

    hash = Hash.new
    hash = {
      :name => u["name"],
      :oldrank => u["rank"],
      :link => u["link"],
      :tuition => u["tuition"],
      :coursefound => u["coursefound"],
      # :alumni => u["alumni"],
      # :award => u["award"],
      # :hici => u["hici"],
      # :pub => u["pub"],
      # :top => u["top"],
      # :tuitionpercent => tuitionpercent.to_s,
      :score => score
    }
    arr.push hash
  }

  rankedUniversities.sort_by! { |h| h[:score] }
  rankedUniversities.reverse!

  return rankedUniversities
end
