library(jsonlite)

get_main_referee <- function(match) {
  main_ref <- match[["matchOfficials"]] %>%
    flatten() %>%
    filter(role == "MAIN")
  if(nrow(main_ref) == 1) {
    return(tibble(referee_id = main_ref$id, referee_name = main_ref$name.display[1]))
  } else if (match[["id"]] %in% c(14142, 22366, 22390, 22600, 22630, 2410, 2481, 38351, 38571, 46618, 951)) {
    match_id <- match[["id"]]
    if(match_id == 14142) {
      ref <- tibble(referee_id = 16961, referee_name = "Anthony Taylor")
    } else if (match_id == 951) {
      ref <- tibble(referee_id = 16921, referee_name = "Peter Jones")
    } else if (match_id == 2410) {
      ref <- tibble(referee_id = 16921, referee_name = "Peter Jones")
    } else if (match_id == 2481) {
      ref <- tibble(referee_id = 16921, referee_name = "Peter Jones")
    } else if (match_id == 22366) {
      ref <- tibble(referee_id = 16967, referee_name = "Craig Pawson")
    } else if (match_id == 22390) {
      ref <- tibble(referee_id = 16961, referee_name = "Anthony Taylor")
    } else if (match_id == 22600) {
      ref <- tibble(referee_id = 16941, referee_name = "Mike Dean")
    } else if (match_id == 22630) {
      ref <- tibble(referee_id = 16962, referee_name = "Kevin Friend")
    } else if (match_id == 38351) {
      ref <- tibble(referee_id = 16954, referee_name = "Lee Mason")
    } else if (match_id == 38571) {
      ref <- tibble(referee_id = 16921, referee_name = "Simon Hooper")
    } else if (match_id == 46618) {
      ref <- tibble(referee_id = 17012, referee_name = "Oliver Langford")
    } else {
      stop("Too many referees!")
    } 
  }
}

read_file <- function(path) {
  chr <- readChar(path, nchars = file.info(path)$size)
  return(fromJSON(chr))
}

process_lineup <- function(df, type, field, team_id) {
  if(nrow(df) == 0 || length(df) == 0) {
    return(tibble())
  } else {
    lineup <- df %>%
      flatten() %>%
      as_tibble() %>%
      select(any_of(c("id", "name.display", "matchPosition", "matchShirtNumber", "captain",
                      "nationalTeam.country", "birth.date.label"))) %>%
      mutate(type = type,
             field = field,
             team_id = team_id)
    return(lineup)
  }
}

process_events <- function(events, match_id) {
  events_condesed <- events %>%
    flatten() %>%
    as_tibble() %>%
    select(any_of(c("phase", "type", "personId", "teamId", "description", "clock.label",
                    "clock.secs", "assistId"))) %>%
    mutate(match_id = match_id)
  return(events_condesed)
}

get_match_info <- function(match) {
  main_referee <- get_main_referee(match)
  return(tibble(match_id = match$id,
                season = match$gameweek$compSeason$label,
                game_week = match$gameweek$gameweek,
                kickoff = match$kickoff$label,
                home = match$teams$team$name[1],
                home_id = match$teams$team$id[1],
                home_score = match$teams$score[1],
                home_ht_score = match$halfTimeScore$homeScore,
                away = match$teams$team$name[2],
                away_id = match$teams$team$id[2],
                away_score = match$teams$score[2],
                away_ht_score = match$halfTimeScore$awayScore,
                ground_id = match$ground$id,
                ground_name = match$ground$name,
                ground_city = match$ground$city,
                referee_id = main_referee$referee_id,
                referee_name = main_referee$referee_name,
                behind_closed_doors = return_na_if_null(match$behindClosedDoors)))
}

get_teams_from_team_lists <- function(match, match_id) {
  team_lists <- match$teamLists
  home_lineup <- process_lineup(team_lists$lineup[[1]],
                                "starting11",
                                "home",
                                match$teamLists$teamId[1])
  home_subs <- process_lineup(team_lists$substitutes[[1]],
                                "substitute",
                                "home",
                                match$teamLists$teamId[1])
  away_lineup <- process_lineup(team_lists$lineup[[2]],
                                "starting11",
                                "away",
                                match$teamLists$teamId[2])
  away_subs <- process_lineup(team_lists$substitutes[[2]],
                                "substitute",
                                "away",
                                match$teamLists$teamId[2])
  return(bind_rows(home_lineup, home_subs, away_lineup, away_subs) %>% mutate(match_id = match_id))
}


return_na_if_null <- function(prop) {
  if(is.null(prop)) {
    return(NA)
  } else {
    return(prop)
  }
}

