library(assertthat)

match_urls_are_unique <- function(matches) {
  
  non_unique_matches <- matches %>%
    add_count(url) %>%
    filter(n > 1)
  
  return(assertthat::assert_that(nrow(non_unique_matches) == 0))
  
}

match_grounds_are_present <- function(matches) {
  not_present <- matches %>%
    filter(is.na(ground) | ground == "")
  
  no_comma <- matches %>%
    filter(!str_detect(ground, ", "))
  
  at_not_present <- assert_that(nrow(not_present) == 0)
  at_no_comma <- assert_that(nrow(no_comma) == 0)
  
  return(assert_that(at_not_present + at_no_comma == 2))
}

result_matches_regex <- function(matches) {
  not_matches_regex <- matches %>%
    filter(!str_detect(result, "[A-z]+ [0-9]-[0-9] [A-z]+"))
  
  return(assert_that(nrow(not_matches_regex) == 0))
}

single_season_and_matches_regex <- function(matches) {
  season_counts <- matches %>%
    count(season)
  
  not_matches_regex <- matches %>%
    filter(!str_detect(season, "[0-9]{4}/[0-9]{2}"))
  
  at_single_season <- assert_that(nrow(season_counts) == 1)
  at_not_matches_regex <- assert_that(nrow(not_matches_regex) == 0)
  return(assert_that(at_single_season + at_not_matches_regex == 2))
}

match_url_matches_regex <- function(matches) {
  
  not_matches_regex <- matches %>%
    filter(!str_detect(url, "^(//www\\.premierleague\\.com/match/)[0-9]+$"))
  
  return(assert_that(nrow(not_matches_regex) == 0))
  
}

season_has_correct_number_of_games <- function(matches) {
  season <- unique(matches$season)
  if(season %in% c("1992/93", "1993/94", "1994/95")) {
    return(assert_that(nrow(matches) == 462))
  } else {
    return(assert_that(nrow(matches) == 380))
  }
}

run_all_matches_tests <- function(matches) {
  match_urls_are_unique(matches)
  match_grounds_are_present(matches)
  result_matches_regex(matches)
  single_season_and_matches_regex(matches)
  match_url_matches_regex(matches)
  season_has_correct_number_of_games(matches)
}