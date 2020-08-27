library(tidyverse)
library(lubridate)
library(extrafont)
loadfonts()

matches <- read_csv("data/matches.csv")
teams <- read_csv("data/teams.csv")
events <- read_csv("data/events.csv")

get_goals_and_apps <- function(id) {
  
  started <- teams %>%
    filter(player_id == id, type == "starting11") %>%
    select(match_id)
  
  subbed_on <- events %>%
    filter(player_id == id, event_desc == "Subbed-on") %>%
    select(match_id)
  
  apps <- bind_rows(started, subbed_on)
  
  goals <- events %>%
    filter(event_type %in% c("Goal", "Penalty Scored"), player_id == id) %>%
    group_by(match_id) %>%
    summarise(goals_scored = n())
  
  
  all_data <- apps %>%
    left_join(goals, by = "match_id") %>%
    left_join(matches, by = "match_id") %>%
    mutate(goals_scored = ifelse(is.na(goals_scored), 0, goals_scored),
           kickoff = dmy_hm(kickoff)) %>%
    arrange(kickoff) %>%
    mutate(apps = row_number(),
           total_goals = cumsum(goals_scored)) %>%
    select(apps, total_goals)
  
  
  return(all_data)
  
}

scorers <- events %>%
  filter(event_type %in% c("Goal", "Penalty Scored")) %>%
  count(player_id, player_name,  sort = TRUE) %>%
  filter(n >= 50) %>%
  mutate(data = map(player_id, get_goals_and_apps))

plot_data <- scorers %>%
  unnest(data)

legend <- plot_data %>%
  filter(player_name %in% c("Alan Shearer", "Frank Lampard", "Jermain Defoe", 
                            "Wayne Rooney", "Ryan Giggs", "Gary Speed")) %>%
  group_by(player_name) %>%
  filter(apps == max(apps)) %>%
  ungroup()

ggplot() +
  geom_step(data = plot_data, aes(apps, total_goals, colour = player_name), size = 1, show.legend = FALSE) +
  gghighlight::gghighlight(player_name %in% c("Alan Shearer", "Frank Lampard",  "Jermain Defoe", 
                                              "Wayne Rooney", "Ryan Giggs", "Gary Speed")) +
  labs(x = "Appearances",
       y = "Goals",
       title = "The Premier League's most prolific goalscorers") +
  scale_colour_manual(breaks = c("Alan Shearer", "Frank Lampard", "Jermain Defoe", 
                                 "Wayne Rooney", "Ryan Giggs", "Gary Speed"),
                      values = c("black", "blue", "red", "#D9020D", "#D9020D", "black")) +
  geom_text(data = legend, aes(apps, total_goals, label = player_name), family = "Bahnschrift", size = 3, vjust = -1) +
  theme_light(base_family = "Bahnschrift") +
  theme(plot.title = element_text(hjust = 0.5))

  
  
ggsave("top_goal_scorers.png", width = 10, height = 8, dpi = "retina")



  
get_assists_and_apps <- function(id) {
  
  started <- teams %>%
    filter(player_id == id, type == "starting11") %>%
    select(match_id)
  
  subbed_on <- events %>%
    filter(player_id == id, event_desc == "Subbed-on") %>%
    select(match_id)
  
  apps <- bind_rows(started, subbed_on)
  
  assists <- events %>%
    filter(event_type == "Goal", assist_id == id) %>%
    group_by(match_id) %>%
    summarise(assists = n())
  
  all_data <- apps %>%
    left_join(assists, by = "match_id") %>%
    left_join(matches, by = "match_id") %>%
    mutate(assists = ifelse(is.na(assists), 0, assists),
           kickoff = dmy_hm(kickoff)) %>%
    arrange(kickoff) %>%
    mutate(apps = row_number(),
           total_assists = cumsum(assists)) %>%
    select(apps, total_assists)
  
  
  return(all_data)
  
}
  

id <- 335


assisters <- events %>%
  filter(event_type == "Goal", !is.na(assist_name)) %>%
  count(assist_id, assist_name,  sort = TRUE) %>%
  filter(n >= 25) %>%
  mutate(data = map(assist_id, get_assists_and_apps))

plot_data <- assisters %>%
  unnest(data)

legend <- plot_data %>%
  filter(assist_name %in% c("Cesc Fàbregas", "Ryan Giggs", "Frank Lampard", 
                            "Wayne Rooney", "Dennis Bergkamp", "Gary Speed")) %>%
  group_by(assist_name) %>%
  filter(apps == max(apps)) %>%
  ungroup()

ggplot() +
  geom_step(data = plot_data, aes(apps, total_assists, colour = assist_name), size = 1, show.legend = FALSE) +
  gghighlight::gghighlight(assist_name %in% c("Cesc Fàbregas", "Ryan Giggs", "Frank Lampard", 
                                              "Wayne Rooney", "Dennis Bergkamp", "Gary Speed")) +
  labs(x = "Appearances",
       y = "Assists",
       title = "The Premier League's most prolific assisters") +
  scale_colour_manual(breaks = c("Cesc Fàbregas", "Ryan Giggs", "Frank Lampard", 
                                 "Wayne Rooney", "Dennis Bergkamp", "Gary Speed"),
                      values = c("blue", "#D9020D", "blue", "#D9020D",  "#EF0107", "black")) +
  geom_text(data = legend, aes(apps, total_assists, label = assist_name), family = "Bahnschrift", size = 3, vjust = -1) +
  theme_light(base_family = "Bahnschrift") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("top_assisters.png", width = 10, height = 8, dpi = "retina")  
  
  
  
  










