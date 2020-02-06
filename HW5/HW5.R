library(tidyverse)
library(stringr)
library(jsonlite)
library(httr)
tweets_raw <- load("../HW_data/LoofLofvenTweets.Rdata") %>% 
  select(text, created_at, )
sentiment <- read_delim("https://svn.spraakdata.gu.se/sb-arkiv/pub/lmf/sentimentlex/sentimentlex.csv", delim = ",") %>% 
    select(word, strength, confidence)

# add Person varaible to both tibbles
Lofven$Person <- "Löfven"
Loof$Person <-  "Lööf"

all_tweets <- rbind(Lofven, Loof) # Merge tibbles vertically
tweets <- distinct(total, text, .keep_all = TRUE) # Remove duplicate sum(Lofven$text == Loof$text) = 902 tweets. This probably removes internal retweets aswell (24 total)

intensity <- tweets %>% # Captures tweets containing e.g. "statsministerkandidat" and "xyztatsminister"
  mutate(text = str_replace(text, "(.*tatsminister.*)", "This tweet used to contain the words tatsminister")) %>% 
  filter(text == "This tweet used to contain the words tatsminister")

ggplot(intensity) +
  geom_histogram(aes(x = created_at, color = Person)) +
  labs(
    x = "Time of Tweet",
    y = "Counts",
    title = "Histogram over the usage of the word s/Statsminister on Twitter"
  )

tweets %>% 
  select(created_at, Person, text) %>%
  mutate(created_at = as.POSIXct(created_at) %>% lubridate::date()) %>% 
  separate_rows(text, sep = " ") %>% 
  inner_join(sentiment, by = c("text" = "word")) %>% 
  group_by(created_at, Person) %>% 
  summarize(
    weighted_avg_strength = mean(strength*confidence),
    avg_strength = mean(strength)
  ) %>% 
  ggplot(aes(x = created_at, y = avg_strength, color = Person)) + 
  geom_line(aes(y=avg_strength)) +
  geom_line(aes(y = weighted_avg_strength), linetype = "dashed") + 
  scale_color_manual(values=c("#e8112d", "#016A3A")) +
  labs(x = "Day of Tweet", y = "Sentiment Score", title = "Weighted (dashed) and unweighted average tweet sentiment for two politicians")
    
schema_response <- GET("http://api.nobelprize.org/v1/prize.json")
schema_json <- content(schema_response, "text")
schema_df <- fromJSON(schema_json)$prizes

laureates <- unnest(schema_df, laureates)

motivation <- c(laureates$motivation)
stopwords <- read_table("https://raw.githubusercontent.com/stopwords-iso/stopwords-en/master/stopwords-en.txt", col_names = "words")
  