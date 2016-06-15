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

jtryker_api <- oauth_app("twitter", 
                    key = api_key,
                    secret = api_secret)

twitter_token <- oauth1.0_token(oauth_endpoints("twitter"), jtryker_api)


##query twitter api for user_ids using GET followers/ids; 5000 attribute limit 
id_limit <- 5000
get_trump <- GET(url = "https://api.twitter.com/1.1/followers/ids.json",
                 config(token = twitter_token),
                 query = list(screen_name = "realDonaldTrump", count = id_limit))


##format content from GET followers/ids request as data.frame, then transpose to columns for readability
trump_ids <- as.data.frame(content(get_trump))
trump_ids <- t(trump_ids[1:5000])


##query twitter api for profile_location$ids using GET users/show in a while loop; 180 attribute limit


loc_limit <- 180
user_ids <- list(0)

repeat {

  count <- 1

  while(count <= loc_limit) {
    user_loc <- content(GET(url = "https://api.twitter.com/1.1/users/show.json",
                            config(token = twitter_token),
                            query = list(user_id = trump_ids[count])))
    
    user_ids[[count]] <- user_loc$profile_location$id
    count <- count + 1
  }
  
  if(length(user_ids) < 360) { ##actual condition: (id_limit - length(user_ids) > 140)
    Sys.sleep(900)
  } else {
    break
  }
}


##exclude NULL values from User_ids list 
user_ids <- user_ids[!sapply(user_ids, is.null)]


##query twitter api to GET twitter geo ids and store longitudes and latitudes in objects

geo_limit <- 15
user_lon <- list(0)
user_lat <- list(0)

repeat {

  count2 <- 1
  
  while(count2 <= geo_limit) {
  
    user_geo <- content(GET(url = paste("https://api.twitter.com/1.1/geo/id/",
                                        user_ids[count2],
                                        ".json",
                                        sep = ""),
                            config(token = twitter_token)))
  
    user_lon[[count2]] <- user_geo$centroid[[1]]
    user_lat[[count2]] <- user_geo$centroid[[2]]
  
    count2 <- count2 + 1
  }
  
  if(length(user_lon) < length(user_ids)) {
    Sys.sleep(900)
  } else {
    break
  } 
}  


##convert longitudes and latitudes into a dataframe for use in ggplot
lon_lat_df <- data.frame(lon = unlist(user_lon),
                         lat = unlist(user_lat),
                         stringsAsFactors = FALSE)


##load the world map data from maps package
map_world <- map_data("world")


##use world map data to form a filled polygon of the world's continents; overlay longitudes and latitudes
ggplot() + 
  geom_polygon(data = map_world, 
               aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) +
  geom_point(data = lon_lat_df, 
             aes(x = lon, y = lat, color = "dark green", alpha = .01), size = .05) +
  ggtitle("@realDonaldTrump Twitter Followers")

##end project

