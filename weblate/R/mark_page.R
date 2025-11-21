#' Extract information from newly edited records on a given page
#'
#' @param page_no page of edited changes to be fetched
#' @param edit_url url to access edited changes page
#' @param language_file reference file containing the link between language
#'   code and language full name
#'
#' @returns dataframe containing language, library, string, id, and url for
#'   the edited records on this given page
#' @export
#'
#' @examples
#' \dontrun{
#' mark_page(1, 
#'   "https://translate.rx.studio/api/units/?q=project:r-project%20AND%20state:needs-editing", 
#'   Language_Statistics)
#' }
mark_page <- function (page_no, edit_url, language_file = NULL) {
  
  # input checking
  stopifnot("page should be greater than 0" = page_no > 0,
            "edit_url should not be empty" = nzchar(edit_url), 
            "language_file must be provided" = !is.null(language_file))
  
  mark_url <- paste0(edit_url, "&page=", page_no)
  mark_changes <- fetch_response_as_json(endpoint = mark_url, handle = h)
  # each row is a unit: https://docs.weblate.org/en/latest/api.html#units
  
  mark_lang <- match_language_names(mark_changes$results$language_code, 
                                    language_file)
  
  mark_lib_id <- match(basename(dirname(mark_changes$results$translation)),
                       slugs)
  mark_lib <- name_of_libraries[mark_lib_id]
  
  # where there are multiple messages due to plurals, use the first
  mark_string <- vapply(mark_changes$results$source, "[", character(1), 1)
  mark_units <- mark_changes$results$id
  mark_web_url <- mark_changes$results$web_url
  
  data.frame(language = mark_lang,
             library = mark_lib,
             string = mark_string,
             id = mark_units,
             url = mark_web_url)
  
}
