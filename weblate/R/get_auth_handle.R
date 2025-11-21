get_auth_handle <- function(API_TOKEN) {
  h <- new_handle()
  handle_setopt(h, ssl_verifyhost = 0L, ssl_verifypeer = 0L)
  handle_setopt(h, customrequest = "GET")
  handle_setopt(h, httpheader = c(paste0("Authorization: Token ", API_TOKEN)))
  return(h)
}
