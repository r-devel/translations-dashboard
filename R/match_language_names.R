mark_lang <- c()
mark_lang_id <- match(
  mark_changes$results$language_code,
  Language_Statistics$Code
)
mark_lang <- c(mark_lang, Language_Statistics$Name[mark_lang_id])



k = 1
for (lan in extracted_lang) {
  index <- which(lan == Language_Statistics$Code)
  languages[k] <- Language_Statistics[index, ]$Name
  k = k + 1
}

extracted_lang <- c('ar', 'bn', 'ca')
match_language_names <- function (extracted_language_codes,
                                  language_file) {
  
  lang_codes <- match(
    extracted_lang, Language_Statistics_new$Code
  )
  languages <- Language_Statistics_new$Name[lang_codes]
}
