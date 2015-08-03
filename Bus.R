setwd("/Users/Mac/Dropbox/practice/crawler")
# 公車路線
# 測試  版本控制

library(httr)
library(XML)

area=c("中正區","大同區","中山區","松山區","大安區","萬華區",
       "信義區","士林區","北投區","內湖區","南港區","文山區")
host="http://5284.taipei.gov.tw/aspx/dybus/arrivalInfo.aspx?ACTION=7&Town="


url=vector()
res=list()
reqText=vector()
for(i in 1:12){
  url[i]=paste0(host, sapply(area[i], URLencode))
  res = GET(url[i])
  reqText[i] = content(res, 'text', encoding='utf8')
}

routes = strsplit(reqText ,split="|",fixed=T)
for(i in 1:12){routes[[i]]=routes[[i]][-1]}

bus=c(routes[[1]],routes[[2]],routes[[3]],routes[[4]],routes[[5]],routes[[6]],
      routes[[7]],routes[[8]],routes[[9]],routes[[10]],routes[[11]],routes[[12]])
bus=unique(bus)
#---------


host2="http://5284.taipei.gov.tw/aspx/start21.aspx?Glid="
url2=vector()
reqText2=vector()
for(i in 1:length(bus)){
  url2[i]=paste0(host2, sapply(bus[i], URLencode))
  reqText2[i] = content( GET(url2[i]), 'text', encoding='utf8')
}
stops = strsplit(reqText2 ,split="|",fixed=T)

#data = stops[[1]]
stopfun = function(data){
  
  end=vector()
  stops=vector()
  for(i in 1:length(data)){
    end[i] =  regexpr("_",data[i])[1]
    if(end[i] !=-1){stops[i] = substr(data[i], 0, end[i]-1 )}
  }
  return(stops)
}

stations=lapply(stops, stopfun)
names(stations)=bus
for(i in 1:length(stations)){
  stations[[i]]=stations[[i]][-1]
  stations[[i]]=stations[[i]][-length(stations[[i]])]
}


#load
library(jsonlite)

#convert object to json
stations.json = jsonlite::toJSON(stations, pretty=TRUE)

write(stations.json, "bus.json")
