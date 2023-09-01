# Required libraries
library(httr)
library(jsonlite)
library(tibble)
library(tidyverse)
library(utils)
api_token <- "wlu_s7fqhH2f9VgCCvIU2FQFlFMIZ27IH9GJwCg0"

libraries_url<-"https://translate.rx.studio/api/projects/r-project/components/"
endpoint <- libraries_url
headers <- add_headers(Authorization = paste("Token"," ",api_token))
response <- GET(url = endpoint, headers = headers, authenticate("shrishs21","kvell@2003"))
libraries <- content(response, "text", encoding = "UTF-8")
libraries <- fromJSON(libraries)
libraries_count<-libraries$count
slugs<-libraries$results$slug
name_of_libraries<-libraries$results$name
component<-numeric(libraries_count)
char<-"\\("
for(i in 1:libraries_count)
{
  index<-gregexpr(char,name_of_libraries[i])
  match_length <- attr(index[[1]], "match.length")
  if(match_length==1)
  {
    component[i]<-substr(name_of_libraries[i],index[[1]][1]+1,index[[1]][1]+1)
  }
  else
  {
    component[i]<-"English"
  }
}
lang<-list()
translated<-list()
fuzzy<-list()
total<-list()
untranslated<-list()
lang_count<-numeric(length(slugs))
i=1 
for(slug in slugs)
{
  library_url<-"https://translate.rx.studio/api/components/r-project/"
  endpoint_library<-paste0(library_url,slug,"/statistics/")
  response_lib <- GET(url = endpoint_library, headers = headers, authenticate("shrishs21","kvell@2003"))
  lib_lang <- content(response_lib, "text", encoding = "UTF-8")
  lib_lang <- fromJSON(lib_lang)
  lang_count[i]<-lib_lang$count
  lang[[i]]<-lib_lang$results$name
  total[[i]]<-lib_lang$results$total
  translated[[i]]<-lib_lang$results$translated
  fuzzy[[i]]<-lib_lang$results$fuzzy
  untranslated[[i]]<-total[[i]]-translated[[i]]-fuzzy[[i]]
  i=i+1
}
data<-data.frame()
for(i in 1:libraries_count)
{
  df<-data.frame(S.no=seq(1,lang_count[i]),Library=name_of_libraries[i],Component=component[i],Language=lang[[i]],Total_words =total[[i]],Translated=translated[[i]],Untranslated=untranslated[[i]],Fuzzy=fuzzy[[i]])
  data<-rbind(data,df)
}
write.csv(data,"Library Language Statistics.csv")
print(25)