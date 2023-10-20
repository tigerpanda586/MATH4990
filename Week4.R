library(here)
library(dplyr)
data = read.csv(here("Datasets", "Police_Department_Incident_Reports__2018_to_Present.csv"))
View(data)

#Only Get Missing Persons theb only unique incidents
data_MP = data.frame(subset(data, data$Incident.Category == "Missing Person" & 
data$Report.Type.Description == "Initial"))
View(data_MP)

#Change Incident.Time column to lubridate readable
library(lubridate)
data_MP$Incident.Time = hm(data_MP$Incident.Time)
#Lubridate other time columns
data_MP$Incident.Datetime = parse_date_time(data_MP$Incident.Datetime, 
orders = "mdy HM")
data_MP$Incident.Date = parse_date_time(data_MP$Incident.Date, 
orders = "mdy")

#Take out all 2023 entries
data_MP = data.frame(subset(data_MP, year(data_MP$Incident.Datetime) != 2023))

#How many have no neighborhood?
Neighborhood_Count = data.frame(table(data_MP$Analysis.Neighborhood))
data_MP_useful = data.frame("No_Neighborhood_Count", 
Neighborhood_Count$Freq[1])

#Rearrange Neighborhood_Count table for aesthetics
names(Neighborhood_Count)[1] = "Neighborhood"
names(Neighborhood_Count)[2] = "Count"

#Rename data_MP_useful columns so it makes sense (ease of mind)
names(data_MP_useful)[1] = "Field"
names(data_MP_useful)[2] = "Value"

#Make a list for all DFs & assign latest/first two dataframes then remove
#dfs from environment + rename them in list
all_df_list = list()
all_df_list[[1]] = data_MP_useful
names(all_df_list)[1] = "No_Neighborhood_Count"
all_df_list[[2]] = Neighborhood_Count
names(all_df_list)[2] = "Neighborhood_Count"
rm(data_MP_useful)
rm(Neighborhood_Count)

#Prepare for counting how many crimes per month
Month_df = data.frame(month(data_MP$Incident.Datetime))
Month_df = data.frame(table(Month_df))
names(Month_df)[1] = "Month"
names(Month_df)[2] = "Count"
Month_df = Month_df %>% arrange(Month)
all_df_list[[3]] = Month_df
names(all_df_list)[3] = "Month_df"
rm(Month_df)

#Counting Distribution for Day of Week
Week_df = data.frame(weekdays(data_MP$Incident.Datetime))
Week_df = data.frame(table(Week_df), c(5,1,6,7,4,2,3))
names(Week_df)[1] = "Week"
names(Week_df)[2] = "Count"
names(Week_df)[3] = "Number"
Week_df = Week_df %>% arrange(Number)
all_df_list[[4]] = Week_df
names(all_df_list)[4] = "Week_df"
rm(Week_df)

#Counting for Time of Day
Hour_df = data.frame(hour(data_MP$Incident.Datetime))
Hour_df = data.frame(table(Hour_df))
names(Hour_df)[1] = "Hour"
names(Hour_df)[2] = "Count"
all_df_list[[5]] = Hour_df
names(all_df_list)[5] = "Hour_df"
rm(Hour_df)

#How many were found?
#!!! This one, you must use supplemental reports as well
data_MP_with_supplement = data.frame(subset(data, data$Incident.Category == "Missing Person"))
Found_df = data.frame(subset(data_MP_with_supplement, 
data_MP_with_supplement$Incident.Description == "Found Person"))
Found_df = data.frame(table(Found_df$Incident.Description))
names(Found_df)[1] = "Found"
names(Found_df)[2] = "Count"
all_df_list[[6]] = Found_df
names(all_df_list)[6] = "Found_df"
rm(Found_df)
rm(data_MP_with_supplement)

#Arranging for top neighborhood data
#Rename 1st row, if not it won't work
all_df_list$Neighborhood_Count$Neighborhood[[1]] = "Empty"
all_df_list$Neighborhood_Count = arrange(all_df_list$Neighborhood_Count, 
desc(all_df_list$Neighborhood_Count$Count))
Top5 = data.frame(all_df_list$Neighborhood_Count[1:5,])
all_df_list[[7]] = Top5
rm(Top5)
names(all_df_list)[7] = "Top 5"


                     