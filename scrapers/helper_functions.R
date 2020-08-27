get_match_count <- function() as.integer(remDr$executeScript("return document.querySelectorAll('.overview').length"))

scroll_until_all_matches <- function(url) {
  
  total_matches <- if(url %in% c("https://www.premierleague.com/results?co=1&se=3&cl=-1","https://www.premierleague.com/results?co=1&se=2&cl=-1", 
                     "https://www.premierleague.com/results?co=1&se=1&cl=-1")) 462 else 380
  
  matches_on_page <- get_match_count()
  
  while (matches_on_page != total_matches) {
    
    if(matches_on_page > total_matches) {
      stop("Too many games")
    }
    
    Sys.sleep(1)
    
    remDr$executeScript("window.scrollBy(0, 4000)")
    
    matches_on_page <- get_match_count()
    
  }
  
}

get_all_matches_on_page <- function() {
  
  matches <- remDr$executeScript("const season = document.querySelector('#dd-compSeasons+ .current').innerText;

  return Array.from(document.querySelectorAll('.overview')).map(match => {
    const url = match.parentElement.getAttribute('data-href');
    const {0: teams, 1: stadiumName} = match.children;
    const ground =  stadiumName.innerText.trim()
    const result =  teams.innerText
    return {
      result,
      ground,
      url,
      season
    }
  })")
  
  return(matches)
  
}

