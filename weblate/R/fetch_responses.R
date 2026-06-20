fetch_response_content <- function(endpoint, handle) {
  print(paste("Querying endpoint", endpoint))

  response <- curl_fetch_memory(endpoint, handle = h)
  response_content <- rawToChar(response$content)
  fromJSON(response_content)
}

calculate_n_pages <- function(count, page_size = 50) {
  remain <- count %% page_size

  if (remain == 0) {
    pages <- count / page_size
  } else {
    pages <- ceiling(count / page_size)
  }

  return(pages)
}

fetch_pages_content <- function(n_pages, endpoint, handle) {
  pages <- vector("list", n_pages)
  for (i in 1:n_pages) {
    url <- paste0(endpoint, "&page=", i)
    pages[[i]] <- fetch_response_content(url, handle)
  }
  pages
}
