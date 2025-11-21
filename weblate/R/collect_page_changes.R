collect_page_changes <- function(changes_page, language_file = NULL) {
  stopifnot("language_file must be provided" = !is.null(language_file))
  page_data <- process_page_response(changes_page)

  languages <- match_language_names(
    page_data$extracted_lang,
    language_file
  )

  extracted_lib <- numeric(length(page_data$extracted_slug))
  k <- 1
  for (s in page_data$extracted_slug) {
    index <- which(s == slugs)
    extracted_lib[k] <- name_of_libraries[index]
    print(k)
    k <- k + 1
  }

  data.frame(
    user = page_data$extracted_users,
    language = languages,
    library = extracted_lib,
    units = page_data$extracted_units,
    date = as.integer(page_data$date),
    time = page_data$time
  )
}
