# encoding: UTF-8

def rankUniversities(universities)

  #get highest Tuition
  maxTuition = universities.reduce([]){ |arr, u|
    arr.push(u["tuition"].to_f)
  }.max

  rankedUniversities = universities.reduce([]){ |arr, u|
    #calculate score
    score = u["alumni"].to_f * 0.7
    score += u["award"].to_f * 0.12
    score += u["hici"].to_f * 0.22
    score += u["pub"].to_f * 0.22
    score += u["top"].to_f * 0.22
    score += (maxTuition - u["tuition"].to_f) / maxTuition

    arr.push {
      name: u["name"],
      link: u["link"],
      score: score,
    }
  }

  return rankedUniversities
end
