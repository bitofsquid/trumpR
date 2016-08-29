##load necessary packages
library(httr)
library(httpuv)
library(ggplot2)
library(maps)

##set scientific notation to off, this ensures the twitter user_ids are not truncated
options(scipen = 999)

##setup twitter session authentication
api_key <- "63Y8LnjXeHYFGa822ZdCPvc8f"
api_secret <- "1ydAFosHshYHWDIJM3O2WdDhufy2UaUsXtqmw3etvkkS8eECqF"

oauth_endpoints("twitter")

api_auth <- oauth_app("twitter", 
                      key = api_key,
                      secret = api_secret)

twitter_token <- oauth1.0_token(oauth_endpoints("twitter"), api_auth)

1 #OAuth1.0 web response

##query twitter api for user_ids using GET followers/ids; 5000 attribute limit 
get_trump <- GET(url = "https://api.twitter.com/1.1/followers/ids.json",
                 config(token = twitter_token),
                 query = list(screen_name = "realDonaldTrump", count = 1000))

##format content from GET followers/ids request as data.frame, then transpose for readability
trump_ids <- as.data.frame(content(get_trump))
trump_ids <- t(trump_ids[1:1000])

##query twitter api for profile_location$ids using GET users/show in a loop to avoid rate limit
user_ids <- list(0)
user_names <- list(0)
user_followers <- list(0)
user_lang <- list(0)

for(i in seq(1:length(trump_ids))) {
  
  user_loc <- content(GET(url = "https://api.twitter.com/1.1/users/show.json",
                          config(token = twitter_token),
                          query = list(user_id = trump_ids[i])))
    
  if("Rate limit exceeded" %in% user_loc$errors[[1]]) {
    
    Sys.sleep(16*60)
    
  } else
    
    user_ids[[i]] <- user_loc$profile_location$id
    user_names[[i]] <- user_loc$screen_name
    user_followers[[i]] <- user_loc$followers_count
    user_lang[[i]] <- user_loc$lang
    
}

##exclude NULL values from lists but maintain list format 
user_ids <- user_ids[!sapply(user_ids, is.null)]
user_names <- user_names[!sapply(user_names, is.null)]
user_followers <- user_followers[!sapply(user_followers, is.null)]
user_lang <- user_lang[!sapply(user_lang, is.null)]

##query twitter api to GET twitter geo ids and store longitudes and latitudes in objects
user_lon <- list(0)
user_lat <- list(0)

for(i in seq(1:length(user_ids))) {
  
  user_geo <- content(GET(url = paste("https://api.twitter.com/1.1/geo/id/",
                                      user_ids[[i]],
                                      ".json",
                                      sep = ""),
                          config(token = twitter_token)))
  
  if("Rate limit exceeded" %in% user_geo$errors[[1]]) {
    
    Sys.sleep(16*60)
    
  } else
    
    user_lon[[i]] <- user_geo$centroid[[1]]
    user_lat[[i]] <- user_geo$centroid[[2]]
  
}

##combine lists into a dataframe
combined_df <- data.frame(ids = unlist(user_ids),
                          screen_name = unlist(user_names),
                          followers = unlist(user_followers),
                          lang = unlist(user_lang),
                          lon = unlist(user_lon),
                          lat = unlist(user_lat),
                          stringsAsFactors = FALSE)

##load the world map data from maps package
map_world <- map_data("world")

##use world map data to form a filled polygon of the world's continents; overlay longitudes and latitudes
ggplot() + 
  geom_polygon(data = map_world, 
               aes(x = long, y = lat, group = group)) + coord_fixed(1.3) +
  
  geom_point(data = combined_df, 
             aes(x = lon, y = lat, alpha = .01), size = .05) +
  
  ggtitle("@realDonaldTrump Twitter Followers")


##end
