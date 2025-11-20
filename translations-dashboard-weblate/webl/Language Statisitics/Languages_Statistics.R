library(httr)
library(jsonlite)
library(data.table)
library(utils)

url <- "https://translate.rx.studio/api/"
token <- "wlu_U8k6Kk12pyhXuBeXOP6imHRFiPrUMwHgHari"

headers <- add_headers(Authorization = paste0("Token ", token))
response <- GET(paste0(url, "languages/"), headers = headers)
lang_all <- content(response, "parsed")
lang <- lang_all$results
count <- lang_all$count
cat("Count:", count, "\n")

data <- data.table(Name = character(count),
                   Code = character(count),
                   Population = numeric(count),
                   Total_Words = numeric(count),
                   Date = character(count),
                   Time=character(count),
                   Translated = numeric(count),
                   Fuzzy = numeric(count),
                   Untranslated = numeric(count))

for (i in 1:count) {
  data$Name[i] <- lang[[i]]$name
  data$Code[i] <- lang[[i]]$code
  data$Population[i] <- lang[[i]]$population
}

get_language_statistics <- function(lang_code) {
  response_new <- GET(paste0(url, "languages/", lang_code, "/statistics/"), headers = headers)
  lang_stats <- content(response_new, "parsed")
  
  total <- lang_stats$total
  last_change <- ifelse(is.null(lang_stats$last_change), "N/A", lang_stats$last_change)
  if(last_change!="N/A")
  {
    datetime <- strptime(last_change, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
    date <- as.Date(datetime)
    
    time <- format(datetime, format = "%H:%M:%S")
  }else
  {
    date<-"N/A"
    time<-"N/A"
  }
  translated <- lang_stats$translated
  fuzzy <- lang_stats$fuzzy
  
  return(c(total,date,time, translated, fuzzy))
}

for (i in 1:count) {
  lang_code <- data$Code[i]
  stats <- get_language_statistics(lang_code)
  data$Total_Words[i] <- as.numeric(stats[1])
  data$Date[i] <- stats[2]
  data$Time[i]<-stats[3]
  data$Translated[i] <- as.numeric(stats[4])
  data$Fuzzy[i] <- as.numeric(stats[5])
  data$Untranslated[i] <- as.numeric(stats[1]) - as.numeric(stats[4]) - as.numeric(stats[5])
}

write.csv(data,"Language_Statistics_new.csv")
