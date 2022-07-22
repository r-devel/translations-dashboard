# library
library(tidyverse)

# Reading "message_status.csv" and "metadata.csv"
msg_status_df <- read.csv("message_status.csv")
meta_data_df <- read.csv("metadata.csv")

# Value Boxes
total_lang <- length(unique(msg_status_df$language))
total_trans_msg <- length(msg_status_df$translated[msg_status_df$translated==TRUE])
total_untrans_msg <- length(msg_status_df$translated[msg_status_df$translated==FALSE])
total_fuzzy_msg <- length(msg_status_df$fuzzy[msg_status_df$fuzzy==TRUE])

# Final message status counts - Translated, Untranslated, Fuzzy Message Count
# Languages dependent graphs for translated/untranslated messages
lang_df <- msg_status_df %>%
  select(package, language, translated, fuzzy)
stats_df <- lang_df %>%
  group_by(package, language, translated) %>%
  summarise(Count = n())
fuzzy_df <- lang_df %>%
  group_by(package, language, fuzzy) %>%
  summarise(Count = n())
fuzzy_df <- subset(fuzzy_df, fuzzy==TRUE)
trans_df <- subset(stats_df, translated==TRUE)
untrans_df <- subset(stats_df, translated==FALSE)
final_df <- merge(trans_df, untrans_df, by = c("package", "language"), all = TRUE)
final_df <- merge(final_df, fuzzy_df, by = c("package", "language"), all = TRUE)
final_df <- final_df %>%
  rename(translated_count = Count.x, untranslated_count = Count.y, fuzzy_count = Count)
final_df <- final_df %>%
  mutate(translated_count = coalesce(translated_count, 0), untranslated_count = coalesce(untranslated_count, 0) ,
         fuzzy_count = coalesce(fuzzy_count, 0))
final_df <- subset(final_df, select = -c(translated.x, translated.y, fuzzy))

# Fully Translated Packages with respective languages associated
complete_trans_df <- subset(final_df, untranslated_count == 0, select = -c(fuzzy_count))

# Untranslated Packages with respective languages associated
complete_untrans_df <- subset(final_df, translated_count == 0, select = -c(fuzzy_count))


# R Language Translation Team Contact details
library(rvest)
library(xml2)
library(stringr)

trans_team_wbpg <- read_html("https://developer.r-project.org/TranslationTeams.html")

lang <- trans_team_wbpg %>%
  html_nodes("td:nth-child(1)") %>%
  html_text() %>%
  str_trim(., side = "left")

lang_members <- trans_team_wbpg %>%
  html_nodes("td+ td") %>%
  html_text() %>%
  str_trim(., side = "both") %>% gsub("\n", "", .)

members_contact <- gsub(".*<", "", lang_members) %>%
  gsub(">", "", .) %>%
  gsub(",.*", "", .) %>% str_trim(., side = "right")

lang_members <- str_extract(lang_members, ".*(?=\\<)") %>%
  str_trim(., side = "right")
lang_members[16] = members_contact[16]
members_contact[16] = NA

trans_team_data <- data.frame(Language = lang, Members = lang_members, 
                              Contact = members_contact)
