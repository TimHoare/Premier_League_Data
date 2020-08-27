# Premier League Data

This repository contains data on matches in the English Premier League between the 1992/93 and 2019/20 seasons. 

The data has been scraped from the Premier League's [official website](https://www.premierleague.com/) and manipulated into a tabular format.

## The data

Raw data in for every game in JSON format can be found in data/games/. The processed data includes:

`matches.csv` - Metadata about each match. Columns are as follows:

|Column              |Description                                                                   |
|:-------------------|:-----------------------------------------------------------------------------|
|match_id            |Premier league match id e.g. https://www.premierleague.com/match/{match_id}   |
|season              |Premier league season                                                         |
|game_week           |Gameweek, an integer between 1 and 41                                         |
|kickoff             |Date and time of match kickoff                                                |
|home                |Home team name                                                                |
|home_id             |Premier league home team id e.g. https://www.premierleague.com/clubs/{home_id}|
|home_score          |Home team score                                                               |
|home_ht_score       |Home team half-time score                                                     |
|away                |Away team name                                                                |
|away_id             |Premier league away team id, as above                                         |
|away_score          |Away team score                                                               |
|away_ht_score       |Away team half-time score                                                     |
|ground_id           |Premier league ground id                                                      |
|ground_name         |Ground name e.g. Old Trafford                                                 |
|ground_city         |Ground city e.g. Manchester                                                   |
|referee_id          |Premier league referee id                                                     |
|referee_name        |Referee name                                                                  |
|behind_closed_doors |Boolean. Was game played behind closed doors?                                 |

`teams.csv` - Matchday squads for games. Joins to `matches.csv` on `match_id`. Note that this data looks to be slightly spotty in terms of reliability.

|Column      |Description |
|:-----------|:-----------|
|match_id    |Premier league match id, as above        |
|team_id     |Premier league team id, as above        |
|field       |Specifies whether this was the home or the away team        |
|type        |Either `starting11` or `substitute`        |
|player_id   |Premier league player id e.g. https://www.premierleague.com/players/{player_id}        |
|player_name |Player name        |
|position    |Match position        |
|shirt_no    |Shirt number        |
|captain     |Boolean, was player captain for team        |
|nationality |Nationality        |
|birth_date  |Birth date in YYYY-MM-DD format        |

`events.csv` - Events in game. These include goals, cards, substitutes etc. Again, Joins to `matches.csv` on `match_id` and to `teams.csv` by `player_id` and/or `assist_id`

|value       |description |
|:-----------|:-----------|
|match_id    |Premier league match id, as above       |
|half        |Integer, indicating first or second half        |
|event_type  |see below        |
|event_desc  |see below        |
|team_id     |Premier league match id, as above        |
|player_id   |Premier league player id, as above        |
|player_name |Player name        |
|assist_id   |Where goal was assisted, Premier league player id        |
|assist_name |Where goal was assisted, player name        |
|minute      |Time of event in minuteds, in mm'ss format (although seconds are redundant)        |
|seconds     |Tim of event in seconds     |

`event_type` - Can be one of `Play Start` or `Play End`, at the start and end of each half, `Booking` for yellow and red cards, `Substitution` for subs in an out `Goal`, `Own-Goal` and `Penalty Scored` for goals, and `Penalty Saved` or `Penalty Missed`.

`event_description` is very similar, but carries an extra level of detail for subs in and out and card types: yellow, red or second yellow.

