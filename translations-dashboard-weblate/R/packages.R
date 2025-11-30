setup <- function(){
  needed <- c(
    "flexdashboard", "crosstalk", "tidyverse", "htmltools", 
    "plotly", "reactable", "glue", "fontawesome", "dplyr",
    "DT", "reshape2", "formattable", "htmlwidgets", "curl", 
    "lubridate", "jsonlite", "readr", "rvest", "stringr"
  )
  for(package in needed){
    if(!sum(installed.packages() %in% package)){
      install.packages(package)
    }
    
    require(package, character.only = TRUE)
  }
}

setup()