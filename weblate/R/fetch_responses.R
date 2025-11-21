fetch_response_as_json <- function(endpoint, handle) {
  print(paste("Querying endpoint", endpoint))

  response <- curl_fetch_memory(endpoint, handle = h)
  response_content <- rawToChar(response$content)

  fromJSON(response_content)
}
