library(tidyverse)
library(stringr)

header_1 <- read_csv2("../HW_data/exp_betyg_ak6_kommun_2018_19.csv", skip =5, n_max = 1, col_names = FALSE) %>%
  replace(is.na(.),"")

header_2 <- read_csv2("../HW_data/exp_betyg_ak6_kommun_2018_19.csv", skip =6, n_max = 1, col_names = FALSE) %>%
  replace(is.na(.),"")

betyg_wrong_header <- read_csv2("../HW_data/exp_betyg_ak6_kommun_2018_19.csv", skip =6, col_names = TRUE) 

old_header = c(colnames(betyg_wrong_header))
new_header = paste(header_1, header_2)
colnames(betyg_wrong_header) <- str_replace(new_header,"(^ )","") # fix trailing spaces and rename header



betyg1 <- betyg_wrong_header %>% 
  select(-"") %>%  # strip last column (empty)
  filter(`Typ av huvudman` == "Samtliga") %>% # No reason to keep data on public/private school.
  replace(. == ".", NA) %>% # rename . to NA
  mutate_all(funs(str_replace(.,",", "."))) %>% #replace , with .

  mutate(`Antal elever Totalt` = sub("\\s+", "", `Antal elever Totalt`)) %>% # remove 1000's delimiter
  mutate(`Antal elever Pojkar` = sub("\\s+", "", `Antal elever Pojkar`)) %>% # remove 1000's delimiter
  mutate(`Antal elever Flickor` = sub("\\s+", "", `Antal elever Flickor`)) # remove 1000's delimiter

betyg2 <- betyg1 %>% 
  mutate(`Antal elever Pojkar` = 
           case_when(
               `Antal elever Pojkar` == ".." & 
               is.numeric(as.numeric(`Antal elever Flickor`)) &
               is.numeric(as.numeric(`Antal elever Totalt`))
             ~ as.numeric(`Antal elever Totalt`) - as.numeric(`Antal elever Flickor`),
             
               `Antal elever Pojkar` == ".." & 
               `Antal elever Flickor` == ".." &
               is.numeric(as.numeric(`Antal elever Totalt`))
             ~ as.numeric(`Antal elever Totalt`) / 2,
             
             TRUE ~ as.numeric(`Antal elever Pojkar`)
           ))
betyg3 <- betyg2 %>% 
  mutate(`Antal elever Flickor` = 
           case_when(
               `Antal elever Flickor` == ".." & 
               is.numeric(as.numeric(`Antal elever Pojkar`)) &
               is.numeric(as.numeric(`Antal elever Totalt`))
             ~ as.numeric(`Antal elever Totalt`) - as.numeric(`Antal elever Pojkar`),
             
               `Antal elever Flickor` == ".." & 
               `Antal elever Pojkar` == ".." &
               is.numeric(as.numeric(`Antal elever Totalt`))
             ~ as.numeric(`Antal elever Totalt`) / 2,
             
             TRUE ~ as.numeric(`Antal elever Flickor`)
           ))

betyg8 <- betyg %>% #fixa genomsnittlig betygspoäng
  mutate(`Genomsnittlig betygspoäng Flickor` = case_when(
    `Genomsnittlig betygspoäng Flickor` == 5 & 
      !is.na(`Genomsnittlig betygspoäng Pojkar`) & 
      !is.na(`Genomsnittlig betygspoäng Totalt`) 
      ~ (as.numeric(`Genomsnittlig betygspoäng Pojkar`)+ as.numeric(`Genomsnittlig betygspoäng Totalt`) )/2,
    TRUE ~ as.numeric(`Genomsnittlig betygspoäng Flickor`)
  )) %>% 
  mutate(`Genomsnittlig betygspoäng Pojkar` = case_when(
    `Genomsnittlig betygspoäng Pojkar` == 5 & 
      !is.na(`Genomsnittlig betygspoäng Flickor`) & 
      !is.na(`Genomsnittlig betygspoäng Totalt`) 
    ~ (as.numeric(`Genomsnittlig betygspoäng Flickor`)+ as.numeric(`Genomsnittlig betygspoäng Totalt`) )/2,
    TRUE ~ as.numeric(`Genomsnittlig betygspoäng Pojkar`)
  ))




betyg <- betyg %>% 
mutate(`Andel (%) med A-E Flickor` = # Fix .. in the "Andel" columns
    case_when(
      as.numeric(`Andel (%) med A-E Flickor`) == 5 ~ 0,
      is.na(`Andel (%) med A-E Flickor`) ~ as.numeric(NA),
      TRUE ~ as.numeric(`Andel (%) med A-E Flickor`))
    ) %>% 
mutate(`Andel (%) med A-E Pojkar` = # Fix .. in the "Andel" columns
           case_when(
             as.numeric(`Andel (%) med A-E Pojkar`) == 5 ~ 0,
             is.na(`Andel (%) med A-E Pojkar`) ~ as.numeric(NA),
             TRUE ~ as.numeric(`Andel (%) med A-E Pojkar`))
  )
grade_cols <- c(`Antal elever Totalt`, `Antal elever Flickor`, `Antal elever Pojkar`, `Andel (%) med A-E Totalt`, `Andel (%) med A-E Flickor`,
                `Andel (%) med A-E Pojkar`, `Genomsnittlig betygspoäng Totalt`, `Genomsnittlig betygspoäng Flickor`, `Genomsnittlig betygspoäng Pojkar`)
count_NA <- betyg %>%
  mutate(NAs = rowSums(is.na(betyg[7:15]))) %>% 
  mutate(non_NAs = rowSums(!is.na(betyg[7:15]))) %>% 
  group_by(`Ämne`) %>% 
  summarize(
    count_NAs = sum(NAs),
    count_non_NAs = sum(non_NAs),
    percentage_missing = count_NAs / (count_NAs + count_non_NAs)*100
    )

reshaped_betyg <- betyg_sub_imputed[c(2,6,13)] %>% 
  spread(key = Ämne, value = `Genomsnittlig betygspoäng Totalt`)

KNN <- kmeans(reshaped_betyg,centers = 2)

