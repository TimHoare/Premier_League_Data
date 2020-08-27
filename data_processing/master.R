library(tidyverse)
library(lubridate)

source("data_processing/helper_functions.R")

files <- list.files("data/games/", full.names = TRUE)

process_match <- function(path) {
  print(path)
  match <- read_file(path)
  match_info <- get_match_info(match)
  teams <- get_teams_from_team_lists(match, match_info$match_id)
  events <- process_events(match[["events"]], match_info$match_id)
  return(list(match_info, teams, events))
}

## Extract info from files


all_prem_matches <- files %>%
  map(process_match)

## Process resulting list
  

match_info <- all_prem_matches %>%
  map_df(function(x) x[[1]])

teams <- all_prem_matches %>%
  map_df(function(x) x[[2]]) %>%
  select(match_id,
         team_id,
         field,
         type,
         player_id = id,
         player_name = name.display,
         position = matchPosition,
         shirt_no = matchShirtNumber,
         captain,
         nationality = nationalTeam.country,
         birth_date = birth.date.label) %>%
  mutate(birth_date = dmy(birth_date))

players <- teams %>%
  distinct(player_id, player_name)


events <- all_prem_matches %>%
  map_df(function(x) x[[3]]) %>%
  left_join(players, by = c("personId" = "player_id")) %>%
  left_join(players, by = c("assistId" = "player_id")) %>%
  select(match_id,
         half = phase,
         event_type = type,
         event_desc = description,
         team_id = teamId,
         player_id = personId,
         player_name = player_name.x,
         assist_id = assistId,
         assist_name = player_name.y,
         minute = clock.label,
         seconds = clock.secs) %>%
  mutate(
    event_type = case_when(
      event_type == "B" ~ "Booking",
      event_type == "G" ~ "Goal",
      event_type == "MP" ~ "Penalty Missed",
      event_type == "O" ~ "Own-Goal",
      event_type == "P" ~ "Penalty Scored",
      event_type == "PE" ~ "Play End",
      event_type == "PS" ~ "Play Start",
      event_type == "S" ~ "Substitution",
      event_type == "SP" ~ "Penalty Saved"),
    event_desc = case_when(
      event_desc == "OFF" ~ "Subbed-off",
      event_desc == "ON" ~ "Subbed-on",
      event_desc == "Y" ~ "Yellow Card",
      event_desc == "G" ~ "Goal",
      event_desc == "P" ~ "Penalty Scored",
      event_desc == "R" ~ "Red Card",
      event_desc == "O" ~ "Own-Goal",
      event_desc == "YR" ~ "Second Yellow",
      event_desc == "SP" ~ "Penalty Saved",
      event_desc == "MP" ~ "Penalty Missed"))


## Write data to file

write_csv(match_info, "data/matches.csv")
write_csv(teams, "data/teams.csv")
write_csv(events, "data/events.csv")