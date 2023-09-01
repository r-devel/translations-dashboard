### Website link for the specific Unit

library(httr)
library(jsonlite)
api_token <- "wlu_s7fqhH2f9VgCCvIU2FQFlFMIZ27IH9GJwCg0"

website_url<-"https://translate.rx.studio/api/units/48663/"
#### Instead of the number "48663" ,Please add the unit number.
endpoint <- website_url
headers <- add_headers(Authorization = paste("Token"," ",api_token))
response <- GET(url = endpoint, headers = headers, authenticate("shrishs21","kvell@2003"))
unit <- content(response, "text", encoding = "UTF-8")
unit <- fromJSON(unit)
print(unit$web_url)
