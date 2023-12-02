# Required libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(tidyverse)
library(data.table)
library(dplyr)
library(curl)
library(lubridate)
Language_Statistics <- read_csv("./../Language Statisitics/Language_Statistics_new.csv")
# Weblate API configuration
api_token <- "wlu_s7fqhH2f9VgCCvIU2FQFlFMIZ27IH9GJwCg0"
api_token2<-"wlu_U8k6Kk12pyhXuBeXOP6imHRFiPrUMwHgHari"
api_url <- "https://translate.rx.studio/api/"

# API request: Fetch all languages
endpoint <- paste0(api_url, "users/")
h <- new_handle()
handle_setopt(h, ssl_verifyhost = 0L, ssl_verifypeer = 0L)
handle_setopt(h, customrequest = "GET")
handle_setopt(h, httpheader = c("Authorization: Token wlu_U8k6Kk12pyhXuBeXOP6imHRFiPrUMwHgHari"))

response<-curl_fetch_memory(endpoint, handle = h)
users<-rawToChar(response$content)
users<-fromJSON(users)

count<-users$count
remain<-count%%50
pages=0
if(remain==0)
{
  pages<-count/50
}else
{
  pages<-ceiling(count/50)
}
name<-c()
username<-c()
for (i in 1:pages) {
  pages_url <- paste0("https://translate.rx.studio/api/users/?page=", i)
  
  pages_response <- curl_fetch_memory(pages_url, handle = h)
  
  pages_changes <- rawToChar(pages_response$content)
  
  pages_changes <- fromJSON(pages_changes)
  extracted_name<-pages_changes$results$full_name
  extracted_username<-pages_changes$results$username
  name<-c(name,extracted_name)
  username<-c(username,extracted_username)
}  
data<-data.frame(name=name,username=username)
stats_endpoint<-paste0(endpoint,username,"/","statistics/")
stat<-numeric((count))
stats<-list()
for(i in 1:(count))
{
  stats_response<-curl_fetch_memory(stats_endpoint[i], handle = h)
  stat[i] <- rawToChar(stats_response$content)
  stats[[i]]<-fromJSON(stat[i])
}
translated<-numeric(count)
languages_count<-numeric(count)
for(i in 1:(count))
{
  translated[i]<-stats[[i]]$translated
  languages_count[i]<-stats[[i]]$languages
}
url<-"https://translate.rx.studio/user/"
url<-paste0(url,username,"/")
languages<-list()
for(i in 1:length(url))
{
  html<-read_html(url[i])
  language<-html%>%html_elements(".middle-dot-divider a")%>%html_text()
  for(lang in language)
  {
    if(!lang %in% Language_Statistics$Name)
    {
      language<-language[language!=lang]
    }
  }
  languages[[i]]<-language
}
data<-cbind(data,translated)
data$Lanaguages_Count<-languages_count
data2<-data.frame(data,stringsAsFactors = FALSE)
data2$Languages<-languages
data2$Languages[[3]]
typeof(data2$Languages)
data2 <- data2 %>%
  mutate(serial_number = row_number()) %>%
  select(serial_number, everything())

data2<-tibble(data2)
data2 <- data2 %>%
  group_by(serial_number)%>%
  mutate(Languages=paste(Languages))

timestamp<-c()
for(user in data2$username)
{
  url_timestamp<-paste0("https://translate.rx.studio/api/changes/?user=",user)
  response_timestamp <- curl_fetch_memory(url_timestamp,handle = h)
  users_timestamp <- rawToChar(response_timestamp$content)
  users_timestamp <- fromJSON(users_timestamp)
  if(users_timestamp$count==0)
  {
    timestamp<-c(timestamp,"N/A")
  }else
  {
      timestamp<-c(timestamp,users_timestamp$results$timestamp[1])
  }
}
data2$created<-timestamp
created<-c()
for(user in data2$username)
{
  url<-paste0("https://translate.rx.studio/api/changes/?user=",user)

  res <- curl_fetch_memory(url, handle = h)
  
  content <- rawToChar(res$content)
  users_last <- fromJSON(content)
  pages_count<-ceiling(users_last$count/50)
  if(pages_count!=0)
  {
    url_last<-paste0("https://translate.rx.studio/api/changes/?page=",pages_count,"&user=",user)
    res2<-curl_fetch_memory(url_last, handle = h)
    content2<-rawToChar(res2$content)
    last_users<-fromJSON(content2)
    remain<-users_last$count%%50
    if(remain==0)
    {
      remain=50
    }
    created<-c(created,last_users$results$timestamp[remain])
  }else
  {
    created<-c(created,"N/A")
  }
  print(user)
}
data2$Last_Activity<-created
now<-Sys.time()
active_time<-now %m+% months(-6)
active<-c()
k=1
for(time in as.POSIXct(data2$Last_Activity,format = "%Y-%m-%dT%H:%M:%OSZ", tz = "Asia/Kolkata") )
{
  print(k)
  if(is.na(time))
  {
    if(data2$translated[k]==0)
    {
      active<-c(active,"Unbegun")
    }else{
      active<-c(active,"Active")
    }
  }else
  {
    if(time>active_time)
    {
      active<-c(active,"Active")
    }else if(data2$translated[k]==0){
      active<-c(active,"Unbegun")
    }else
    {
      active<-c(active,"Inactive")
    }
  }
  k=k+1
}
data2$Active<-active
write_csv(data2, "Statistics.csv")

