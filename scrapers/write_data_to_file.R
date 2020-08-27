library(tidyverse)
library(rvest)

matches <- read_csv("data/all_premier_leage_matches.csv")

get_match_json <- function(url) {
  match_info <- read_html(url) %>%
    html_nodes(".mcTabsContainer") %>%
    html_attr("data-fixture")
  
  return(match_info)
}

write_data_to_file <- function(match_id) {
  print(match_id)
  url <- paste0("https://www.premierleague.com/match/", match_id)
  data <- get_match_json(url)
  write(data, paste0("data/games/", match_id, ".json"))
}

str_extract(matches$url, "[0-9]+$") %>%
  map(write_data_to_file)


