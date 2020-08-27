library(tidyverse)
library(RSelenium)

source("scrapers/helper_functions.R")
source("tests/get_matches_tests.R")

rd <- rsDriver(verbose = FALSE, chromever = "84.0.4147.30")
remDr <- rd$client

## Get seasons urls:

#Array.from(document.querySelector('#mainContent > div.tabbedContent > div.wrapper.col-12.active > section > div:nth-child(4) > ul').children)
#.map(season => season.getAttribute('data-option-id'))
#.map(seasonId => `https://www.premierleague.com/results?co=1&se=${seasonId}&cl=-1`)

season_urls <- c("https://www.premierleague.com/results?co=1&se=274&cl=-1", "https://www.premierleague.com/results?co=1&se=210&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=79&cl=-1", "https://www.premierleague.com/results?co=1&se=54&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=42&cl=-1", "https://www.premierleague.com/results?co=1&se=27&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=22&cl=-1", "https://www.premierleague.com/results?co=1&se=21&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=20&cl=-1", "https://www.premierleague.com/results?co=1&se=19&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=18&cl=-1", "https://www.premierleague.com/results?co=1&se=17&cl=-1", 
                 "https://www.premierleague.com/results?co=1&se=16&cl=-1", "https://www.premierleague.com/results?co=1&se=15&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=14&cl=-1", "https://www.premierleague.com/results?co=1&se=13&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=12&cl=-1", "https://www.premierleague.com/results?co=1&se=11&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=10&cl=-1", "https://www.premierleague.com/results?co=1&se=9&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=8&cl=-1", "https://www.premierleague.com/results?co=1&se=7&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=6&cl=-1", "https://www.premierleague.com/results?co=1&se=5&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=4&cl=-1", "https://www.premierleague.com/results?co=1&se=3&cl=-1",
                 "https://www.premierleague.com/results?co=1&se=2&cl=-1", "https://www.premierleague.com/results?co=1&se=1&cl=-1")

get_all_season_data <- function(url) {
  
  print(url)
  
  remDr$navigate(url)
  
  scroll_until_all_matches(url)

  match_data <- get_all_matches_on_page()  %>%
    map_df(as_tibble) %>%
    mutate_at(vars(ground, result), str_replace_all, "\n", " ") %>%
    mutate_at(vars(ground, result), str_replace_all, "\\s+", " ")
  
  run_all_matches_tests(match_data)
  
  return(match_data)
  
}

all_season_data <- map_df(season_urls, get_all_season_data)

all_season_data %>%
  mutate(url = paste0("https:", url)) %>%
  write_csv("data/all_premier_leage_matches.csv")



