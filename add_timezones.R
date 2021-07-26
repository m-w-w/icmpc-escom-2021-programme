# a short script for adding time zone specific information to the ICMPC-ESCOM program
# currently, adds EST

# import libraries
library(lubridate)
library(tidyverse)

# where should the file save on your computer?
path_to_save <- '/where/do/you/want/the/file/to/go'

# what is your time zone label? Run Sys.timezone() or OlsonNames() to find a valid name
time_zone_code <- 'America/Toronto'
  
# read the data from GitHub
df <- read_csv('https://raw.githubusercontent.com/m-w-w/icmpc-escom-2021-programme/main/ICMPC-ESCOM-2021-Programme.csv')

# The program originally listed talks at 23:00 UTC as happening on the next day in the Day column
# It's more straightforward to list the correct day when setting the datetime
df <- 
  df %>%
  mutate(Day = case_when(str_detect(`Time (UTC)`,'(Weds)') ~ 'Wednesday',
                         str_detect(`Time (UTC)`,'(Thurs)') ~ 'Thursday',
                         str_detect(`Time (UTC)`,'(Fri)') ~ 'Friday',
                         TRUE ~ Day)) 

# add column with datetime UTC
df <- 
  df %>%
  mutate(Datetime_UTC = ymd_hms(
    case_when(Day == 'Wednesday' ~ paste('2021-07-28 ',`Time (UTC)`,':00:00', sep=''),
              Day == 'Thursday' ~ paste('2021-07-29 ',`Time (UTC)`,':00:00', sep=''),
              Day == 'Friday' ~ paste('2021-07-30 ',`Time (UTC)`,':00:00', sep=''),
              Day == 'Saturday' ~ paste('2021-07-31 ',`Time (UTC)`,':00:00', sep='')), 
    tz = "UTC")
  )

# to add another timezone, use the function "with_tz()"
# we use format() so that it writes correctly when saving
rename_datetime <- function(x) paste('Datetime_',time_zone_code,sep='')
df <- 
  df %>%
  mutate(
    Datetime_ = format(with_tz(Datetime_UTC, time_zone_code), usetz=TRUE), 
  ) %>%
  rename_at('Datetime_', rename_datetime)

# finally, we can format the UTC datetime, reorder cols, and write the file
# to the path specified at the top of the script
df <- 
  df %>%
  mutate(
    Datetime_UTC = format(Datetime_UTC, usetz=TRUE), 
  ) %>%
  select(
    Day,
    `Time (UTC)`,
    Datetime_UTC,
    starts_with('Datetime_'), # dynamically named
    everything()
  ) %>%
  write_csv(file.path(path_to_save,'ICMPC-ESCOM-2021-Programme-Datetimes.csv'))

