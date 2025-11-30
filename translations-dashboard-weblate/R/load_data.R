#####################################################
# Load Data 
#####################################################
Language_Statistics_new       <- read_csv("webl/Language Statisitics/Language_Statistics_new.csv")
Library_Language_Statistics   <- read_csv("webl/Library Language Statistics/Library Language Statistics.csv")
Marked_for_Edit               <- read_csv("webl/Recent Changes/Marked for Edit.csv")
New_Translation               <- read_csv("webl/Recent Changes/New Translation.csv")
Statistics                    <- read_csv("webl/User Statistics/Statistics.csv")

#####################################################
# Custom Functions
#####################################################
compute_active <- function() {
  active_count<-nrow(subset(Statistics,Active=="Active"))
  total<-nrow(Statistics)
  return(active_count*100/total)
}
compute_inactive <- function() {
  inactive_count<-nrow(subset(Statistics,Active=="Inactive"))
  total<-nrow(Statistics)
  return(inactive_count*100/total)
}
compute_unbegun <- function() {
  unbegun_count<-nrow(subset(Statistics,Active=="Unbegun"))
  total<-nrow(Statistics)
  return(unbegun_count*100/total)
}

#####################################################
# Global Translations
#####################################################
# Reading "message_status.csv" and "metadata.csv"
msg_status_df               <- read.csv("message_status.csv")
meta_data_df                <- read.csv("metadata.csv")

# Value Boxes
total_lang                  <- length(unique(msg_status_df$language))
total_trans_msg             <- length(msg_status_df$translated[msg_status_df$translated==TRUE])
total_untrans_msg           <- length(msg_status_df$translated[msg_status_df$translated==FALSE])
total_fuzzy_msg             <- length(msg_status_df$fuzzy[msg_status_df$fuzzy==TRUE])

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
final_df[,6:8]<-final_df[,3:5]/rowSums(final_df[,3:5])
final_df <- rename(final_df, pc_trans_count = translated_count.1, pc_untrans_count = untranslated_count.1, pc_fuzzy_count = fuzzy_count.1)

# Fully Translated Packages with respective languages associated
complete_trans_df <- subset(final_df, untranslated_count == 0, select = -c(fuzzy_count, pc_trans_count, pc_untrans_count, pc_fuzzy_count))

# Untranslated Packages with respective languages associated
complete_untrans_df <- subset(final_df, translated_count == 0, select = -c(fuzzy_count, pc_trans_count, pc_untrans_count, pc_fuzzy_count))

# R Language Translation Team Contact details
translation_teams <- read_html("https://developer.r-project.org/TranslationTeams.html") |>
  html_node("table , th") |>
  html_table()

translation_teams$Members <- translation_teams$Contact |>
  gsub(pattern = "(.*)<.*", replacement = "\\1") |>
  str_trim(side = "right")

translation_teams$Contact <- translation_teams$Contact |>
  gsub(pattern = ".*<([^>]+)>.*", replacement = "\\1")

translation_teams <- translation_teams[, c("Language", "Members", "Contact")]

# Function to get the last date of update for any dataset on GitHub
# E.g of an endpoint: "https://api.github.com/repos/r-devel/translations/commits?path=message_status.csv&page=1&per_page=1"
get_last_data_update <- function(endpoint) {
  last_data_update <- curl::curl_fetch_memory(endpoint)$modified
  format(last_data_update, format= "%d %B %Y")
}