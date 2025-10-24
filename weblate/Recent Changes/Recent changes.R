# Required libraries
library(curl)
library(jsonlite)
library(stringr)
library(readr)
Language_Statistics <- read_csv("./../Language Statisitics/Language_Statistics_new.csv")
API_TOKEN <- Sys.getenv("WEBLATE_TOKEN")

# Get new translations (action = 5) for r-project project only
# (See comments at end of file for actions)
# And only get changes since last time this script ran, with a little bit of wiggle room added.
last_df <- readr::read_csv("New Translation.csv")
max_date <- max(as.Date(last_df$date))
max_date <- format(max_date - 1, "%Y-%m-%dT%H:%M:%SZ")

changes_url<-"https://translate.rx.studio/api/projects/r-project/changes/?action=5"
changes_url <- paste0(changes_url, "&timestamp_after=", max_date)
endpoint <- changes_url

h <- new_handle()
handle_setopt(h, ssl_verifyhost = 0L, ssl_verifypeer = 0L)
handle_setopt(h, customrequest = "GET")
handle_setopt(h, httpheader = c(paste0("Authorization: Token ", API_TOKEN)))

print(paste("Querying endpoint", endpoint))
response <- curl_fetch_memory(endpoint, handle = h)

changes <- rawToChar(response$content)

changes <- fromJSON(changes)

libraries_url<-"https://translate.rx.studio/api/projects/r-project/components/"

print(paste("Querying endpoint", libraries_url))
lib_response <- curl_fetch_memory(libraries_url, handle = h)

libraries <- rawToChar(lib_response$content)

libraries <- fromJSON(libraries)
libraries_count<-libraries$count
slugs<-libraries$results$slug
name_of_libraries<-libraries$results$name
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
lang<-c()
users <- c()
lib<-c()
slug<-c()
units<-c()
timestamp<-c()
dates<-c()
times<-c()
for (i in 1:pages) {
  pages_url <- paste0(changes_url, "&page=", i)
  
  print(paste("Querying endpoint", pages_url))
  pages_response <- curl_fetch_memory(pages_url, handle = h)
  
  pages_changes <- rawToChar(pages_response$content)
  
  pages_changes <- fromJSON(pages_changes)
  component<-str_extract(pages_changes$results$component, "components/(.*?)/")
  component<-str_remove_all(component, "components/|/")
  extracted_users <- str_extract(pages_changes$results$user, "/([^/]+)/$")
  extracted_users <- str_remove_all(extracted_users, "/")
  extracted_lang <- str_extract(pages_changes$results$translation, "/([^/]+)/$")
  extracted_lang <- str_remove_all(extracted_lang, "/")
  extracted_slug <- str_extract(pages_changes$results$component, "/([^/]+)/$")
  extracted_slug <- str_remove_all(extracted_slug, "/")
  extracted_units<-str_extract(pages_changes$results$unit, "/([^/]+)/$")
  extracted_units<-str_remove_all(extracted_units,"/")
  datetime <- as.POSIXct(pages_changes$results$timestamp, format = "%Y-%m-%dT%H:%M:%OSZ")
  datetime <- strptime(datetime, format = "%Y-%m-%d %H:%M:%S")

  date <- as.Date(datetime)

  time <- format(datetime, format = "%H:%M:%S")
  languages<-numeric(length(extracted_lang))
  k=1
  for(lan in extracted_lang)
  {
    index<-which(lan==Language_Statistics$Code)
    languages[k]<-Language_Statistics[index,]$Name
    k=k+1
  }

  extracted_lib<-numeric(length(extracted_slug))
  k=1
  for(s in extracted_slug)
  {
    index<-which(s==slugs)
    extracted_lib[k]<-name_of_libraries[index]
    print(k)
    k=k+1
  }
  users <- c(users, extracted_users)
  lang<-c(lang,languages)
  slug<-c(slug,extracted_slug)
  lib<-c(lib,extracted_lib)
  units<-c(units,extracted_units)
  dates<-c(dates,date)
  times<-c(times,time)
}
translated_data<-data.frame(user=users,language=lang,library=lib,units=units,date=dates,time=times)
dd<-duplicated(translated_data$units,fromLast = TRUE)
translated_data<-translated_data[!dd,]

### Marked for edit 
# Only get changes since last time this script ran, with a little bit of wiggle room added.
last_df <- readr::read_csv("Marked for Edit.csv")
max_date <- max(as.Date(last_df$date))
max_date <- format(max_date - 1, "%Y-%m-%dT%H:%M:%SZ")
edit_url<-"https://translate.rx.studio/api/projects/r-project/changes/?action=37"
edit_url <- paste0(edit_url, "&timestamp_after=", max_date)

print(paste("Querying endpoint", edit_url))
edit_response <- curl_fetch_memory(edit_url, handle = h)

edits <- rawToChar(edit_response$content)

edits <- fromJSON(edits)
edit_count<-edits$count
edit_remain<-edit_count%%50
edit_pages=0
if(edit_remain==0)
{
  edit_pages<-edit_count/50
}else
{
  edit_pages<-ceiling(edit_count/50)
}
mark_lang<-c()
mark_users <- c()
mark_lib<-c()
mark_slug<-c()
mark_units<-c()
mark_timestamp<-c()
mark_dates<-c()
mark_times<-c()
for(i in 1:edit_pages)
{
  mark_url <- paste0(edit_url, "&page=", i)
  
  print(paste("Querying endpoint", mark_url))
  mark_response <- curl_fetch_memory(mark_url, handle = h)
  
  mark_changes <- rawToChar(mark_response$content)
  
  mark_changes <- fromJSON(mark_changes)
  
  mark_component<-str_extract(mark_changes$results$component, "components/(.*?)/")
  mark_component<-str_remove_all(mark_component, "components/|/")
  mark_extracted_users <- str_extract(mark_changes$results$user, "/([^/]+)/$")
  mark_extracted_users <- str_remove_all(mark_extracted_users, "/")
  mark_extracted_lang <- str_extract(mark_changes$results$translation, "/([^/]+)/$")
  mark_extracted_lang <- str_remove_all(mark_extracted_lang, "/")
  mark_extracted_slug <- str_extract(mark_changes$results$component, "/([^/]+)/$")
  mark_extracted_slug <- str_remove_all(mark_extracted_slug, "/")
  mark_extracted_units<-str_extract(mark_changes$results$unit, "/([^/]+)/$")
  mark_extracted_units<-str_remove_all(mark_extracted_units,"/")
  mark_datetime <- as.POSIXct(mark_changes$results$timestamp, format = "%Y-%m-%dT%H:%M:%OSZ")
  mark_datetime <- strptime(mark_datetime, format = "%Y-%m-%d %H:%M:%S")
  
  mark_date <- as.Date(mark_datetime)
  
  mark_time <- format(mark_datetime, format = "%H:%M:%S")
  mark_languages<-numeric(length(mark_extracted_lang))
  k=1
  for(lan in mark_extracted_lang)
  {
    index<-which(lan==Language_Statistics$Code)
    mark_languages[k]<-Language_Statistics[index,]$Name
    k=k+1
  }
  
  mark_extracted_lib<-numeric(length(mark_extracted_slug))
  k=1
  for(s in mark_extracted_slug)
  {
    index<-which(s==slugs)
    mark_extracted_lib[k]<-name_of_libraries[index]
    k=k+1
  }
  mark_users <- c(mark_users, mark_extracted_users)
  mark_lang<-c(mark_lang,mark_languages)
  mark_slug<-c(mark_slug,mark_extracted_slug)
  mark_lib<-c(mark_lib,mark_extracted_lib)
  mark_units<-c(mark_units,mark_extracted_units)
  mark_dates<-c(mark_dates,mark_date)
  mark_times<-c(mark_times,mark_time)
}
mark_data<-data.frame(user=mark_users,language=mark_lang,library=mark_lib,units=mark_units,date=mark_dates,time=mark_times)
d_row<-duplicated(mark_data$units,fromLast = TRUE)
mark_data<-mark_data[!d_row,]
editing<-dim(mark_data)[1]

###Translation changed
# Only get changes since last time this script ran, with a little bit of wiggle room added.
last_df <- readr::read_csv("New Translation.csv")
max_date <- max(as.Date(last_df$date))
max_date <- format(max_date - 1, "%Y-%m-%dT%H:%M:%SZ")
changed_url<-"https://translate.rx.studio/api/projects/r-project/changes/?action=2"
changed_url <- paste0(changed_url, "&timestamp_after=", max_date)

print(paste("Querying endpoint", changed_url))
changes_response <- curl_fetch_memory(changed_url, handle = h)

changed <- rawToChar(changes_response$content)

changed <- fromJSON(changed)
changed_count<-changed$count
changed_remain<-changed_count%%50
changed_pages=0
if(changed_remain==0)
{
  changed_pages<-changed_count/50
}else
{
  changed_pages<-ceiling(changed_count/50)
}
changed_lang<-c()
changed_users <- c()
changed_lib<-c()
changed_slug<-c()
changed_units<-c()
changed_timestamp<-c()
changed_dates<-c()
changed_times<-c()
for(i in 1:changed_pages)
{
  
  ch_url <- paste0(changed_url, "&page=", i)
  
  print(paste("Querying endpoint", ch_url))
  ch_response <- curl_fetch_memory(ch_url, handle = h)
  
  ch_changes <- rawToChar(ch_response$content)
  
  ch_changes <- fromJSON(ch_changes)
  ch_component<-str_extract(ch_changes$results$component, "components/(.*?)/")
  ch_component<-str_remove_all(ch_component, "components/|/")
  ch_units<-str_extract(ch_changes$results$unit, "/([^/]+)/$")
  ch_units<-str_remove_all(ch_units,"/")
  ch_users <- str_extract(ch_changes$results$user, "/([^/]+)/$")
  ch_users <- str_remove_all(ch_users, "/")
  ch_lang <- str_extract(ch_changes$results$translation, "/([^/]+)/$")
  ch_lang <- str_remove_all(ch_lang, "/")
  ch_slug <- str_extract(ch_changes$results$component, "/([^/]+)/$")
  ch_slug <- str_remove_all(ch_slug, "/")
  ch_units<-str_extract(ch_changes$results$unit, "/([^/]+)/$")
  ch_units<-str_remove_all(ch_units,"/")
  ch_datetime <- as.POSIXct(ch_changes$results$timestamp, format = "%Y-%m-%dT%H:%M:%OSZ")
  ch_datetime <- strptime(ch_datetime, format = "%Y-%m-%d %H:%M:%S")
  
  ch_date <- as.Date(ch_datetime)
  
  ch_time <- format(ch_datetime, format = "%H:%M:%S")
  ch_languages<-numeric(length(ch_lang))
  k=1
  for(lan in ch_lang)
  {
    index<-which(lan==Language_Statistics$Code)
    ch_languages[k]<-Language_Statistics[index,]$Name
    k=k+1
  }
  
  ch_lib<-numeric(length(ch_slug))
  k=1
  for(s in ch_slug)
  {
    index<-which(s==slugs)
    ch_lib[k]<-name_of_libraries[index]
    k=k+1
  }
  changed_users <- c(changed_users, ch_users)
  changed_lang<-c(changed_lang,ch_languages)
  changed_slug<-c(changed_slug,ch_slug)
  changed_lib<-c(changed_lib,ch_lib)
  changed_units<-c(changed_units,ch_units)
  changed_dates<-c(changed_dates,ch_date)
  changed_times<-c(changed_times,ch_time)
}
changed_data<-data.frame(user=changed_users,language=changed_lang,library=changed_lib,units=changed_units,date=changed_dates,time=changed_times)
du_row<-duplicated(changed_data$units,fromLast = TRUE)
changed_data<-changed_data[!du_row,]

###Data Processing

# if translation changed after marking for edit, remove from mark_data
# otherwise remove from changed_data
elements_changed<-intersect(mark_data$units,changed_data$units)
indexes<-match(elements_changed,mark_data$units)
indexes2<-match(elements_changed,changed_data$units)

date_at_indexes<-as.Date(mark_data[indexes,]$date,origin="1970-01-01")
time_at_indexes<-mark_data[indexes,]$time
timestamp_at_indexes<-paste0(date_at_indexes," ",time_at_indexes)
datetime_at_indexes <- as.POSIXct(timestamp_at_indexes, format = "%Y-%m-%d %H:%M:%S")

date_at_indexes2<-as.Date(changed_data[indexes2,]$date,origin="1970-01-01")
time_at_indexes2<-changed_data[indexes2,]$time
timestamp_at_indexes2<-paste0(date_at_indexes2," ",time_at_indexes2)
datetime_at_indexes2 <- as.POSIXct(timestamp_at_indexes2, format = "%Y-%m-%d %H:%M:%S")
j<-c()
k<-c()
for(i in 1:length(indexes))
{
  if(timestamp_at_indexes2[i]>timestamp_at_indexes[i])
  {
    j<-c(j,i)
  }else{
    k<-c(k,i)
  }
}
# remove records changed after marking for edit
mark_data<-mark_data[-indexes[j],] 
# remove records marked for edit after changing
changed_data<-changed_data[-indexes2[k],]
editing<-dim(mark_data)[1]

# if new translation marked for edit, exclude from new translations
translation_edited<-intersect(translated_data$units,mark_data$units)
translated_indexes<-match(translation_edited,translated_data$units)
translated_data<-translated_data[-translated_indexes,]

# treat new and updated translations as "new translations"
translation_changed<-intersect(translated_data$units,changed_data$units)
changed_indexes<-match(translation_changed,translated_data$units)
changed_index<-match(translation_changed,changed_data$units)
translated_data<-translated_data[-changed_indexes,]
translated_data<-rbind(translated_data,changed_data[changed_index,])

# Append to previous runs
translated_data_old <- readr::read_csv("New Translation.csv")
translated_data <- rbind(translated_data_old, translated_data)

mark_data_old <- readr::read_csv("Marked for Edit.csv")
mark_data <- rbind(mark_data_old, mark_data)

# Results retrieved from API will likely go back further in time than the last
# time that this script was executed by CI/CD. It might just be by 12 hours, but
# if the CI/CD fails or becomes intermittent it could be longer.
# Whatever the case, remove duplicates caused by the overlap.
translated_data <- translated_data[!duplicated(translated_data), ]
mark_data <- mark_data[!duplicated(mark_data), ]

write_csv(translated_data[order(translated_data$date, decreasing = TRUE),], 
          "New Translation.csv")
write_csv(mark_data[order(mark_data$date, decreasing = TRUE),], 
          "Marked for Edit.csv")

# Weblate action id and action names (can't find documented)
# # Missing numbers do not appear in r-project project as of 2024-10-11
# 2 Translation changed 
# 3 Comment added 
# 4 Suggestion added 
# 5 New translation 
# 6 Automatic translation 
# 7 Suggestion accepted 
# 8 Translation reverted 
# 9 Translation uploaded 
# 13 New source string 
# 14 Component locked 
# 15 Component unlocked 
# 16 Found duplicated string 
# 17 Committed changes 
# 18 Pushed changes 
# 21 Rebased repository 
# 22 Failed merge on repository 
# 23 Failed rebase on repository 
# 24 Parse error 
# 26 Suggestion removed 
# 27 Search and replace 
# 28 Failed push on repository 
# 29 Suggestion removed during cleanup 
# 30 Source string changed 
# 31 New string added 
# 34 Added user 
# 36 Translation approved 
# 37 Marked for edit 
# 38 Removed component 
# 40 Found duplicated language 
# 42 Renamed component 
# 44 New strings to translate 
# 45 New contributor 
# 47 New alert 
# 48 Added new language 
# 50 Created project 
# 51 Created component
# 59 String updated in the repository 
# 60 Add-on installed 
# 61 Add-on configuration changed 
# 63 Removed string 
# 64 Removed comment 
# 65 Resolved comment 
