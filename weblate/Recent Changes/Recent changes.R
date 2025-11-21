# Required libraries
library(curl)
library(jsonlite)
library(stringr)
Language_Statistics <- read.csv(
  "./../Language Statisitics/Language_Statistics_new.csv"
)
R.utils::sourceDirectory("./../R/")
API_TOKEN <- Sys.getenv("WEBLATE_TOKEN")
h <- get_auth_handle(API_TOKEN)


# Get new translations (action = 5) for r-project project only
# (See comments at end of file for actions)
# And only get changes since last time this script ran, with a little bit of wiggle room added.

last_df <- read.csv("New Translation.csv")
max_date <- max(as.Date(last_df$date))
max_date <- format(max_date - 1, "%Y-%m-%dT%H:%M:%SZ")
changes_url <- "https://translate.rx.studio/api/projects/r-project/changes/?action=5"
changes_url <- paste0(changes_url, "&timestamp_after=", max_date)

changes <- fetch_response_as_json(endpoint = changes_url, handle = h)

libraries_url <- "https://translate.rx.studio/api/projects/r-project/components/"
libraries <- fetch_response_as_json(endpoint = libraries_url, handle = h)


libraries_count <- libraries$count
slugs <- libraries$results$slug
name_of_libraries <- libraries$results$name
count <- changes$count
remain <- count %% 50
pages <- 0
if (remain == 0) {
  pages <- count / 50
} else {
  pages <- ceiling(count / 50)
}
lang <- c()
users <- c()
lib <- c()
slug <- c()
units <- c()
timestamp <- c()
dates <- c()
times <- c()
for (i in 1:pages) {
  ### split loop into section 1 that gets all responses (3 lines below)
  pages_url <- paste0(changes_url, "&page=", i)
  print(paste("Querying endpoint", pages_url))
  pages_response <- curl_fetch_memory(pages_url, handle = h)

  pages_changes <- rawToChar(pages_response$content)
  pages_changes <- fromJSON(pages_changes)
  component <- str_extract(pages_changes$results$component, "components/(.*?)/")
  component <- str_remove_all(component, "components/|/")
  extracted_users <- str_extract(pages_changes$results$user, "/([^/]+)/$")
  extracted_users <- str_remove_all(extracted_users, "/")
  extracted_lang <- str_extract(pages_changes$results$translation, "/([^/]+)/$")
  extracted_lang <- str_remove_all(extracted_lang, "/")
  extracted_slug <- str_extract(pages_changes$results$component, "/([^/]+)/$")
  extracted_slug <- str_remove_all(extracted_slug, "/")
  extracted_units <- str_extract(pages_changes$results$unit, "/([^/]+)/$")
  extracted_units <- str_remove_all(extracted_units, "/")
  datetime <- as.POSIXct(
    pages_changes$results$timestamp,
    format = "%Y-%m-%dT%H:%M:%OSZ"
  )
  datetime <- strptime(datetime, format = "%Y-%m-%d %H:%M:%S")

  date <- as.Date(datetime)

  time <- format(datetime, format = "%H:%M:%S")
  
  languages <- match_language_names(extracted_lang, Language_Statistics)

  extracted_lib <- numeric(length(extracted_slug))
  k <- 1
  for (s in extracted_slug) {
    index <- which(s == slugs)
    extracted_lib[k] <- name_of_libraries[index]
    print(k)
    k <- k + 1
  }
  users <- c(users, extracted_users)
  lang <- c(lang, languages)
  slug <- c(slug, extracted_slug)
  lib <- c(lib, extracted_lib)
  units <- c(units, extracted_units)
  dates <- c(dates, date)
  times <- c(times, time)
  lang <- c(lang, languages)
  slug <- c(slug, extracted_slug)
  lib <- c(lib, extracted_lib)
  units <- c(units, extracted_units)
  dates <- c(dates, date)
  times <- c(times, time)
}
translated_data <- data.frame(
  user = users,
  language = lang,
  library = lib,
  units = units,
  date = dates,
  time = times
)

### Marked for edit 
# Need to always download full set of "Marked for edit" translations, since 
# there is no robust way to track newly marked/unmarked
# (status can be changed by updates to the repository vs user action)
edit_url <- "https://translate.rx.studio/api/units/"
# using search query here not query parameters!
# we are assuming that there are 200 results per response 
edit_url <- paste0(edit_url, "?q=project:r-project%20AND%20state:needs-editing")
edits <- fetch_response_as_json(endpoint = edit_url, handle = h)

edit_pages <- ceiling(edits$count/200)
mark_data <- do.call(rbind, lapply(seq_len(edit_pages), mark_page, edit_url, 
                                   Language_Statistics))


###Data Processing

# Add new translations above previously saved translations
translated_data_old <- read.csv("New Translation.csv")
translated_data <- rbind(translated_data, translated_data_old)

# Remove duplicated (identical) records and save, newest translations first
translated_data <- translated_data[!duplicated(translated_data), ]
write.csv(translated_data[order(translated_data$date, decreasing = TRUE),], 
          "New Translation.csv", quote = FALSE, row.names = FALSE)

# Overwrite previous record of translations marked for edit
write.csv(mark_data[order(mark_data$language, mark_data$library),], 
          "Marked for Edit.csv", quote = FALSE, row.names = FALSE)

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
# 59 String updated in the repository
# 60 Add-on installed
# 61 Add-on configuration changed
# 63 Removed string
# 64 Removed comment
# 65 Resolved comment
