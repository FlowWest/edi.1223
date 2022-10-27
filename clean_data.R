library(tidyverse)
library(readxl)
library(lubridate)
library(hms)

list.files('data-raw/')

raw_snorkel_all <- read_csv('data-raw/snorkel_all.csv') %>% glimpse

# datetime:   hh:mm:ssTZD

snorkel_all <- raw_snorkel_all |> 
  mutate(Date = as_date(Date, format = "%m/%d/%Y"),
         Species_Code = ifelse(Species_Code == "Unknown Larval", "LARVAL", Species_Code)) |> 
  separate(StartTime, into = c("tmp", "StartTime"), sep = " ") |> 
  separate(EndTime, into = c("tmp2", "EndTime"), sep = " ") |> 
  mutate(StartTime = ifelse(nchar(StartTime) %in% c(5, 4), paste0(StartTime, ":00"), StartTime),
         EndTime = ifelse(nchar(EndTime) %in% c(5, 4), paste0(EndTime, ":00"), EndTime),
         StartTime = as_hms(as_datetime(paste(Date, StartTime))),
         EndTime = as_hms(as_datetime(paste(Date, EndTime)))) |> 
  #mutate(nchar = nchar(as.character(StartTime))) 
  #mutate(StartTime = ifelse(nchar(StartTime) != 10, StartTime, NA)) |> 
  select(-tmp, -tmp2) |> 
  glimpse()

unique(snorkel_all$ProjectID)

# plot numeric variables--------------------------------------------------------


ggplot(data = snorkel_all, aes(x = Date, y = Temperature_C)) + 
  geom_point()

ggplot(data = snorkel_all, aes(x = Date, y = DO_mgL)) + 
  geom_point()

ggplot(data = snorkel_all, aes(x = Date, y = Turbidity_NTU)) + 
  geom_point()

ggplot(data = snorkel_all, aes(x = Date, y = Depth)) + 
  geom_point()

ggplot(data = snorkel_all, aes(x = Date, y = Velocity1)) + 
  geom_point() 

ggplot(data = snorkel_all, aes(x = Date, y = Velocity2)) + 
  geom_point() 

ggplot(data = snorkel_all, aes(x = Date, y = Visibility)) + 
  geom_point() 

ggplot(data = snorkel_all, aes(x = Date, y = Count)) + 
  geom_point() 

ggplot(data = snorkel_all, aes(x = Date, y = xsVelocity_1)) + 
  geom_point() 

ggplot(data = snorkel_all, aes(x = as.numeric(XSDVTransectNo))) + 
  geom_histogram() 


# explore character variables  --------------------------------------------

table(snorkel_all$TransectID, useNA = "ifany")
length(unique(snorkel_all$TransectID))

unique(snorkel_all$Notes, useNA = "ifany")

table(snorkel_all$Bank, useNA = "ifany")

table(snorkel_all$SingleSnorkeler, useNA = "ifany")

unique(snorkel_all$ObsID, useNA = "ifany")

unique(snorkel_all$AreaCode, useNA = "ifany")

unique(snorkel_all$FishObsID, useNA = "ifany")

# changed unknown larval to "LARVAL". see above. 
table(snorkel_all$Species_Code, useNA = "ifany")

unique(snorkel_all$Comment, useNA = "ifany")


# write clean csv  --------------------------------------------------------

write_csv(snorkel_all, 'data/snorkel_all.csv')

# shapefiles --------------------------------------------------------------

snorkel <- sf::read_sf('data-raw/2014_2022_HW_snorkel_final/2014_2022_HW_Snorkel_End_pts_CASP2_final.shp')

fish_obs <- sf::read_sf('data-raw/2014_2022_HW_snorkel_final/2014_2022_HW_Snorkel_FishObs_pts_CASP2_final.shp')

start_pts <- sf::read_sf('data-raw/2014_2022_HW_snorkel_final/2014_2022_HW_Snorkel_Start_pts_CASP2_final.shp')

