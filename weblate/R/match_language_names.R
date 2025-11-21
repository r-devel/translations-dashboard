#' Match language code page changes to reference list
#'
#' @param extracted_language_codes language code extracted from the 
#'   page changes objects
#' @param language_file reference file containing the link between language
#'   code and language full name
#'
#' @returns vector of language names
#' @export
#'
#' @examples
#' extracted_lang <- c('ar', 'bn', 'ca')
#' languages <- match_language_names(extracted_lang, Language_Statistics_new)
match_language_names <- function (extracted_language_codes,
                                  language_file) {
  lang_codes <- match(extracted_language_codes, language_file$Code)
  languages <- language_file$Name[lang_codes]
  return(languages)
}

