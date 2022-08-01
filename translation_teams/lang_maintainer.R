# R Language Translation Team Contact details
library(rvest)
library(stringr)

translation_teams <- read_html("https://developer.r-project.org/TranslationTeams.html") |>
  html_node("table , th") |>
  html_table()

translation_teams$Members <- translation_teams$Contact |>
  gsub(pattern = "(.*)<.*", replacement = "\\1") |>
  str_trim(side = "right")

translation_teams$Contact <- translation_teams$Contact |>
  gsub(pattern = ".*<([^>]+)>.*", replacement = "\\1")

translation_teams <- translation_teams[, c("Language", "Members", "Contact")]