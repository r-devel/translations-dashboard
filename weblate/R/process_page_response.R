#' Extract and clean data from a page
#'
#' @param pages_changes
#'
#' @returns A list.
#' @export
process_page_response <- function(page) {
  component <- extract_str(page$results$component, "components/(.*?)/")
  component <- gsub("components/|/", "", component)
  extracted_users <- extract_str(page$results$user, "/([^/]+)/$")
  extracted_users <- gsub("/", "", extracted_users)
  extracted_lang <- extract_str(page$results$translation, "/([^/]+)/$")
  extracted_lang <- gsub("/", "", extracted_lang)
  extracted_slug <- extract_str(page$results$component, "/([^/]+)/$")
  extracted_slug <- gsub("/", "", extracted_slug)
  extracted_units <- extract_str(page$results$unit, "/([^/]+)/$")
  extracted_units <- gsub("/", "", extracted_units)

  datetime <- as.POSIXct(
    page$results$timestamp,
    format = "%Y-%m-%dT%H:%M:%OSZ"
  )
  datetime <- strptime(datetime, format = "%Y-%m-%d %H:%M:%S")
  date <- as.Date(datetime)
  time <- format(datetime, format = "%H:%M:%S")

  list(
    extracted_users = extracted_users,
    extracted_lang = extracted_lang,
    extracted_slug = extracted_slug,
    extracted_units = extracted_units,
    date = date,
    time = time
  )
}


#' Basically the same as stringr::str_extract()
#'
#' @param x A character vector.
#' @param pattern A regular expression.
#'
#' @returns A character vector.
#'
#' @examples
#' extract_str(c('test1', 'apple'), 'app')
extract_str <- function(x, pattern) {
  unname(sapply(x, function(.x) extract_str_or_na(.x, pattern)))
}


#' Extract the string given a pattern and return NA if no match.
#'
#' @param i A character.
#' @param pattern A regular expression.
#'
#' @returns A character.
#'
#' @examples
#' extract_str_or_na('apple', 'app')
extract_str_or_na <- function(i, pattern) {
  m <- unlist(regmatches(i, gregexpr(pattern, i)))
  if (length(m) == 0) {
    return(NA_character_)
  }
  m
}
