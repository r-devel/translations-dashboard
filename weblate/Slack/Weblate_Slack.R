library(slackr)
library(httr)
library(jsonlite)
library(stringr)
library(readr)
Statistics <- read_csv("/home/runner/work/weblate/weblate/User Statistics/Statistics.csv")
api_token <- "wlu_s7fqhH2f9VgCCvIU2FQFlFMIZ27IH9GJwCg0"
slackr_setup(config_file = "translationswithr")
#### making of file
date<-Sys.Date()
time<-Sys.time()
url<-"https://translate.rx.studio/api/changes/"
endpoint <- url
headers <- add_headers(Authorization = paste("Token"," ",api_token))
response <- GET(url = endpoint, headers = headers, authenticate("shrishs21","kvell@2003"))
changes <- content(response, "text", encoding = "UTF-8")
changes <- fromJSON(changes)
count<-changes$count
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
libraries<-c()
languages<-c()
message<-c()
units<-c()
new_message<-c()
timestamp<-c()
new_timestamp<-c()
for(i in pages:1)
{
  changes_url<-paste0(url,"?page=",i)
  page_response <- GET(url = changes_url, headers = headers, authenticate("shrishs21","kvell@2003"))
  page_changes <- content(page_response, "text", encoding = "UTF-8")
  page_changes <- fromJSON(page_changes)
  k<-length(page_changes$results$action)
  extract_unit<-c()
  extract_username<-c()
  extract_libraries<-c()
  extract_languages<-c()
  extract_action<-c()
  extract_message<-c()
  extract_name<-c()
  extract_new_message<-c()
  extract_timestamp<-c()
  extract_new_timestamp<-c()
  flag<-0
  for(j in k:1)
  {
    if(time<as.POSIXct(page_changes$results$timestamp[j], format = "%Y-%m-%dT%H:%M:%OSZ"))
    {
      flag<-flag+1
      ac<-page_changes$results$action[j]
      if(ac==37||ac==2||ac==5||ac==59)
      {
        unit<-str_extract(page_changes$results$unit[j], "/([^/]+)/$")
        unit<-str_remove_all(unit,"/")
        extract_unit<-c(extract_unit,unit)
        user <- str_extract(page_changes$results$user[j], "/([^/]+)/$")
        user <- str_remove_all(user, "/")
        extract_username<-c(extract_username,user)
        library<- str_extract(page_changes$results$component[j], "/([^/]+)/$")
        library <- str_remove_all(library, "/")
        extract_libraries<-c(extract_libraries,library)
        lang <- str_extract(page_changes$results$translation[j], "/([^/]+)/$")
        lang <- str_remove_all(lang, "/")
        extract_languages<-c(extract_languages,lang)
        extract_action<-c(extract_action,ac)
        extract_message<-c(extract_message,page_changes$results$action_name[j])
        extract_timestamp<-c(extract_timestamp,as.POSIXct(page_changes$results$timestamp[j], format = "%Y-%m-%dT%H:%M:%OSZ"))
      }else if(ac==45)
      {
        user2 <- str_extract(page_changes$results$user[j], "/([^/]+)/$")
        user2 <- str_remove_all(user2, "/")
        extract_name<-c(extract_name,user2)
        extract_new_message<-c(extract_new_message,page_changes$results$action_name[j])
        extract_new_timestamp<-c(extract_new_timestamp,as.POSIXct(page_changes$results$timestamp[j], format = "%Y-%m-%dT%H:%M:%OSZ"))
      }
    }else
    {
      break
    }
  }
  username<-c(username,extract_username)
  libraries<-c(libraries,extract_libraries)
  languages<-c(languages,extract_languages)
  units<-c(units,extract_unit)
  message<-c(message,extract_message)
  name<-c(name,extract_name)
  new_message<-c(new_message,extract_new_message)
  timestamp<-c(timestamp,extract_timestamp)
  new_timestamp<-c(new_timestamp,extract_new_timestamp)
  if(flag<k)
  {
    break
  }
}
updates<-data.frame(Username=username,Library=libraries,Language=languages,Unit=units,Message=message,Timestamp=timestamp)
fullname<-c()
for(n in name)
{
  index<-which(Statistics$username==n)
  fullname<-c(fullname,Statistics$name[index])
}
New_contributor<-data.frame(Message=new_message,FullName=fullname,Username=name,Timestamp=new_timestamp)
updates<-updates[rev(seq_len(nrow(updates))), ]
rownames(updates) <- seq_len(nrow(updates))

#####Slack working
slack_message<-paste("Here are the Updates for the date",Sys.Date())
contributor_message<-paste("New contributors on day",Sys.Date())
slackr_csv(updates,initial_comment = slack_message,channels = "#gsoc-translations")
slackr_csv(New_contributor,initial_comment =contributor_message ,channels = "#gsoc-translations")
