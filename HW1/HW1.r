library(tidyverse)
library(reshape2)
RB <- read_csv(file = "RB.csv")

ggplot(RB,aes(x=Rate,y=SWED))+
    geom_point()+
    scale_y_log10()

