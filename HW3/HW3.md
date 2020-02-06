HW3: Working with tables
================

# Exercise 1: Long and wide at Statistics Sweden

#### Choose a table that is on wide format (see textbook), convert it to long format using gather and illustrate something that is easier to do in the latter format.

From [SCB](http://www.statistikdatabasen.scb.se/sq/78600), we can get a
table containing monthly YTD household lending (Utlåning till hushåll),
and money supply (M1) in Sweden. In its raw format, each month is its
own variable, which is the definition of the “wide” format. Thus, we
need to gather the time variables to the “long” format as done below.

``` r
scb_long <- read.table(file = "FM5001AC.csv", sep = "\t", header = TRUE) %>%
  gather("X2019M01":"X2019M09",
    key = "month",
    value = "percent"
  )

knitr::kable(scb_long, caption = "Long table from SCB using `gather()`")
```

| ekonomisk.indikator   | month    | percent |
| :-------------------- | :------- | ------: |
| Utlåning till hushåll | X2019M01 |     5.4 |
| M1                    | X2019M01 |     6.6 |
| Utlåning till hushåll | X2019M02 |     5.2 |
| M1                    | X2019M02 |     7.5 |
| Utlåning till hushåll | X2019M03 |     5.0 |
| M1                    | X2019M03 |     7.1 |
| Utlåning till hushåll | X2019M04 |     5.0 |
| M1                    | X2019M04 |     6.0 |
| Utlåning till hushåll | X2019M05 |     5.0 |
| M1                    | X2019M05 |     7.3 |
| Utlåning till hushåll | X2019M06 |     4.9 |
| M1                    | X2019M06 |     6.8 |
| Utlåning till hushåll | X2019M07 |     4.9 |
| M1                    | X2019M07 |     7.9 |
| Utlåning till hushåll | X2019M08 |     4.9 |
| M1                    | X2019M08 |     8.0 |
| Utlåning till hushåll | X2019M09 |     4.8 |
| M1                    | X2019M09 |     8.1 |

Long table from SCB using `gather()`

``` r
ggplot(scb_long, aes(x = month, y = percent, fill = ekonomisk.indikator)) +
  geom_bar(position = "dodge", stat = "identity") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(
    x = "Month",
    y = "Increase MoM",
    caption = "Monthly increase in household lending and money supply (M1)",
    fill = "Indicator type"
  )
```

![](HW3_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

#### Choose a table that has variables as rows (e.g. separate rows for men and women), turn it into tidy format using spread and illustrate something that is easier to do in the latter format.

From [SCB](http://www.statistikdatabasen.scb.se/sq/78599), we get a
table containing the number of suicides in Sweden from 1990 to 1996 for
men and women. First, as in the previous example, we `gather()` the time
variables.

``` r
scb1_long <- read.table(file = "HS0301A1.csv", sep = "\t", header = TRUE) %>%
  gather("X1990",
    "X1991",
    "X1992",
    "X1993",
    "X1994",
    "X1995",
    "X1996",
    key = "year",
    value = "count"
  ) %>%
  select(-dödsorsak)

knitr::kable(scb1_long, caption = "Long table from SCB using `gather()`")
```

| kön     | year  | count |
| :------ | :---- | ----: |
| män     | X1990 |  1020 |
| kvinnor | X1990 |   451 |
| män     | X1991 |  1036 |
| kvinnor | X1991 |   447 |
| män     | X1992 |   936 |
| kvinnor | X1992 |   419 |
| män     | X1993 |   956 |
| kvinnor | X1993 |   417 |
| män     | X1994 |   929 |
| kvinnor | X1994 |   395 |
| män     | X1995 |   936 |
| kvinnor | X1995 |   412 |
| män     | X1996 |   872 |
| kvinnor | X1996 |   381 |

Long table from SCB using `gather()`

Then, we `spead()` the genders, since the variable `count` contains
values from multiple variables (i.e. the two genders). The result is a
tidy dataframe where each gender has its own variable, and the all years
are gathered under a single variable `year`.

``` r
scb1_wide <- scb1_long %>%
  spread(key = kön, value = count)

knitr::kable(scb1_wide, caption = "Tidy table from SCB using `spread()`")
```

| year  | kvinnor |  män |
| :---- | ------: | ---: |
| X1990 |     451 | 1020 |
| X1991 |     447 | 1036 |
| X1992 |     419 |  936 |
| X1993 |     417 |  956 |
| X1994 |     395 |  929 |
| X1995 |     412 |  936 |
| X1996 |     381 |  872 |

Tidy table from SCB using `spread()`

``` r
ggplot(scb1_wide, aes(x = year, y = män)) +
  geom_bar(position = "dodge", stat = "identity") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(
    x = "Year",
    y = "Number of male suicides",
    caption = "Number of male suicides per year in Sweden"
  )
```

![](HW3_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

# Exercise 2: SL lines

#### Figure out and describe how the tables relate to eachother.

We have the following tables: `sites`, `stopPoints`, `lines`,
`journeyPatterns`, and `transportmodes`. `transportmodes` is a
dictionary between the `DefaultTransportModeCode` and `StopAreaTypeCode`
for transating the codes in `lines` and `stopPoints`, repsectively.
`sites` and `stopPoints` is linked with `StopAreaNumber` or
`StopPointNumber`. `StopPointNumber` links each `lines` to each
`stopPoints`.

#### Pull all data from the SQLite database into R as data.frames using the RSQLite package.

The following code from the Internet loads the dataframes into the
vector lDataFrames.

Convert `SiteId`, `StopPointNumber` and `StopAreaNumber` to integers.

#### Consider the `stopAreas` and `stopPoints` tables and comment on the sparsity of this data presentation, e.g., are there any (unecessary) redudancies?. Suggest a more sparse data model for the stopAreas table and perform the appropriate table operations to obtain this sparser representation and store it in the data.frame `stopAreas_sparse`. Explain how one would get the original `stopAreas` data.frame using joins.

In `stopAreas`, each `StopPointName`-`StopAreaTypeCode` pair is linked
to a unique `StopPointNumber`. Hence, for multiple instances of a
`StopPointNumber` with the same `StopAreaTypeCode`, the sucessive
`StopPointName` can be omitted. An example that illustrates this
redundancy is given below.

``` r
stopAreas_small <- stopAreas %>%
  filter(StopPointName == "Gullmarsplan")
```

#### Present a table of the number of active unique rail traffic stops (i.e. train, tram or metro stops in each ticket zone (ZoneShortName in stopAreas/stopPoints). By “active” we mean stops that are part of the journey pattern of a line.

``` r
stopPoints_active_grouped <- stopPoints %>%
  filter(
    StopPointNumber %in% journeyPatterns$JourneyPatternPointNumber, # Active stopPoints
    StopAreaTypeCode %in% c("TRAMSTN", "METROSTN", "RAILWSTN") # only rail stopPonts
  ) %>%
  group_by(ZoneShortName) %>%
  summarize(
    count = n()
  )
knitr::kable(stopPoints_active_grouped, caption = "Table of number of active rail stoppoints, grouped by zone")
```

| ZoneShortName | count |
| :------------ | ----: |
|               |     3 |
| A             |   410 |
| B             |   120 |
| C             |    32 |

Table of number of active rail stoppoints, grouped by zone

#### Choose a line, and plot the stops as points on a map with the name of each stop as a label. Write the code in such a way that it is easily reusable if you want to plot another line.

For reusability, we define the function `line()`, which takes the line
number as integer, and produces a filtered dataframe from
`journeyPatterns`. If the output were a shiny html instead of a md, we
could have the user herself declaring the bus-lie of interest using this
function.

``` r
line <- function(line_number) { # FUnction for easy reusability
  `journeyPatterns` %>%
    filter(
      LineNumber == as.character(line_number),
      DirectionCode == "1"
    ) # Pick only one direction for clarity
}
```

The coordinates in this dataframe is then used to generate a png-file.
Below is the code and resulting png used to generate the map of the
busline 4 in one direction.

``` r
coordinates <- stopPoints %>%
  mutate(
    lon = as.numeric(LocationEastingCoordinate),
    lat = as.numeric(LocationNorthingCoordinate),
    name = StopPointName
  ) %>%
  filter(
    StopAreaTypeCode == "BUSTERM", # Only buses for now
    StopPointNumber %in% line(4)$JourneyPatternPointNumber, # stopPoints of line 4
  )
leaflet(coordinates) %>%
  addTiles() %>%
  addMarkers(lng = ~lon, lat = ~lat, popup = ~name) %>%
  mapshot(file = "Leaflet-plot.png")
knitr::include_graphics("Leaflet-plot.png")
```

![](Leaflet-plot.png)<!-- -->

# Exercise 3: Using the SL lines with a reseplan

#### From where to where is the journey? How would you answer the question using the sites table from Exercise 2?

Inspect the `Origin$name` variable:

``` r
data <- load("../HW_data/reseplaner-2019-11-17.RData")
knitr::kable(trips$LegList$Leg[[1]]$Origin$name, caption = "`Origin$name` of the data")
```

| x                  |
| :----------------- |
| Albano             |
| Tekniska högskolan |
| Tekniska högskolan |
| Gamla stan         |
| Gamla stan         |

`Origin$name` of the data

This seems to be a variable of the starting points of the connections.
Hence, the trip starts at Albano. Inspect the `Destination$name`
variable:

``` r
knitr::kable(trips$LegList$Leg[[1]]$Destination$name, caption = "`Destination$name` of the data")
```

| x                  |
| :----------------- |
| Tekniska högskolan |
| Tekniska högskolan |
| Gamla stan         |
| Gamla stan         |
| Medborgarplatsen   |

`Destination$name` of the data

This seems to be a table of the ending points of the connections. Hence,
the trip ends at Medborgarplatsen.

In both `Origin` and `Destination`, there seems to be a variable
`mainMastExtId` that contains the `siteId` from previous exercise.

``` r
trips$LegList$Leg[[1]]$Origin$mainMastExtId
```

    ## [1] "300101096" "300109204" "300101082" "300101345" "300101345"

Stripping the first entry of the 5 leading numbers, we get 1096. it
corresponds to Albano and its `siteId`. Doing the same for
`Destination`, we get the `siteId` 1315. Let’s check that this indeed
corresponds to Medborgarplatsen:

``` r
sites1 <- sites %>%
  filter(SiteId ==
    substr(tail(trips$LegList$Leg[[1]]$Destination$mainMastExtId, 1), 6, 100))

coordinates1 <- stopPoints %>%
  mutate(
    lon = as.numeric(LocationEastingCoordinate),
    lat = as.numeric(LocationNorthingCoordinate),
    name = StopPointName
  ) %>%
  filter(
    StopPointNumber %in% sites1$StopAreaNumber,
  )
leaflet(coordinates1) %>%
  addTiles() %>%
  addMarkers(lng = ~lon, lat = ~lat, popup = ~name) %>%
  mapshot(file = "Leaflet-plot1.png")
knitr::include_graphics("Leaflet-plot1.png")
```

![](Leaflet-plot1.png)<!-- --> Which is a map over Björns trädgård,
Medborgarplatsen as expected\!

#### When one would arrive at the destination?

`trips$LegList$Leg[[i]]` contains the i:th suggested trip. We can assume
that `i = 1` gives us the shortest trip, because this is the standard
setting in most apps (i.e. sorting by shortest travel time). This can of
course also be checked by printing `trips$LegList$Leg[[i]]`. However,
under this assumption, the time is then:

``` r
tail(trips$
  LegList$
  Leg[[1]]$
  Destination$
  time, 1)
```

    ## [1] "14:27:00"

#### Provide a list of all stops that one travels through during the journey.

We need to iterate twice: first list all the stops for one connection,
and then list all connections. This can be done using the following
nested for-loop.

``` r
for (j in 1:length(trips$
  LegList$
  Leg[[1]]$
  Stops$
  Stop)) {
  for (i in trips$
    LegList$
    Leg[[1]]$
    Stops$
    Stop[[j]]$
    name) {
    print(i)
  }
}
```

    ## [1] "Albano"
    ## [1] "Roslagstull (på Valhallavägen)"
    ## [1] "Tekniska högskolan"
    ## [1] "Tekniska högskolan"
    ## [1] "Stadion"
    ## [1] "Östermalmstorg"
    ## [1] "T-Centralen"
    ## [1] "Gamla stan"
    ## [1] "Gamla stan"
    ## [1] "Slussen"
    ## [1] "Medborgarplatsen"

Each repetition signals a change of connection. Unfortunately, the
$-structure is not in tidy format, and is quite hard to read.
