library(dplyr)
library(slackr)
library(httr)
library(jsonlite)
library(knitr)
library(stringr)
library(readr)
Statistics <- read_csv("./../User Statistics/Statistics.csv")
API_TOKEN <- Sys.getenv("WEBLATE_TOKEN")
SLACK_TOKEN <- Sys.getenv("SLACK_TOKEN")
SLACK_WEBHOOK_URL <- Sys.getenv("SLACK_WEBHOOK_URL")
slackr_setup(channel="#weblate-updates",
             username="weblate-notifier",
             token=SLACK_TOKEN,
             incoming_webhook_url=SLACK_WEBHOOK_URL
            )
# get changes in past week (round down to hour at which action scheduled, i.e. 19:00 UTC)
datetime <- trunc(Sys.time(), units = "hours")
ISO8601date_after <- format(datetime - as.difftime(7, unit="days"), "%Y-%m-%dT%H:%M:%SZ")
ISO8601date_before <- format(datetime, "%Y-%m-%dT%H:%M:%SZ")
url <- paste0("https://translate.rx.studio/api/projects/r-project/changes/?timestamp_after=", ISO8601date_after,
  "&timestamp_before=", ISO8601date_before)
endpoint <- url
headers <- add_headers(Authorization = paste("Token"," ",API_TOKEN))
response <- GET(url = endpoint, headers = headers)
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
  message("Page: ", i)
  changes_url<-paste0(url,"&page=",i)
  page_response <- GET(url = changes_url, headers = headers)
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
  message("Actions: ", paste(unique(page_changes$results$action), collapse = ", "))
  for(j in k:1)
  {
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
}

if (length(username)){  
  updates <- data.frame(Username=username,Library=libraries,Language=languages,Unit=units,Message=message,Timestamp=timestamp)
  leaderboard <- updates |>
    count(Username, Language, name = "Actions") |>
    arrange(desc(Actions))
  
  language_updates <- updates |>
    count(Language, Action = Message) |>
    arrange(Language)
  
  component_updates <- updates |>
    count(Library, name = "Actions")
}

if (length(name)){
  name <- unique(name)
  fullname <- Statistics$name[Statistics$username == name]
  new_contributor <- data.frame(`Full name` = fullname, Username = name, check.names = FALSE) |>
    arrange(`Full name`, Username)
}

##### Slack message
slack_message <- paste(c(paste0(format(datetime, "%Y-%m-%d %H:%M:%S UTC"), 
  ": Summary of the updates on Weblate in the last 7 days"), 
  if (length(name)){
    c("*New Contributors*", "```", knitr::kable(new_contributor), "```")
  } else "",
  c("*Message updates*"),
  "```", knitr::kable(leaderboard), "```",
  "```", knitr::kable(language_updates), "```",
  "```", knitr::kable(component_updates), "```"), collapse = "\n")

if (length(username)){
  slackr_msg(slack_message, channels = "#weblate-updates", mrkdwn = TRUE)
} else {
  slackr_msg(paste0(Sys.Date(), ": No activity on Weblate in the last 7 days"),
    channels = "#weblate-updates")
}
