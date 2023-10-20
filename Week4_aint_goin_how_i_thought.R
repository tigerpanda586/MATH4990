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
Neighborhood_Count = data.frame(data_MP$Analysis.Neighborhood)
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
list2 = list()
list2[[1]] = Neighborhood_Count
names(list2)[1] = "No_Neighborhood_Count"
list2[[2]] = Neighborhood_Count
names(list2)[2] = "Neighborhood_Count"
rm(data_MP_useful)
rm(Neighborhood_Count)

#Prepare for counting how many crimes per month
Month_df = data.frame(month(data_MP$Incident.Datetime))
Month_df = data.frame(Month_df, Month_df, Month_df)
names(Month_df)[1] = "Month"
names(Month_df)[2] = "Count"
names(Month_df)[3] = "Name"
i = 1
while(i <= length(Month_df$Month)){
  Month_df$Name[i] = month.name[Month_df$Count[i]]
  i = i +1
}
i = 1
while(i <= length(Month_df$Month)){
  Month_df$Count[i] = all_df_list$Month_df$Count[Month_df$Count[i]]
  i = i +1
}
Month_df = list2$Month_df %>% arrange(Month)
list2[[3]] = Month_df
names(list2)[3] = "Month_df"
rm(Month_df)
rm(i)

#Counting Distribution for Day of Week
Week_df = data.frame(weekdays(data_MP$Incident.Datetime))
Week_df = data.frame(Week_df, Week_df, Week_df)
names(Week_df)[1] = "Week"
names(Week_df)[2] = "Count2"
names(Week_df)[3] = "Count"
i = 1
while(i <= length(Week_df$Week)){
  if(Week_df$Week[i] == "Monday")
    Week_df$Count[i] = 1
  else if (Week_df$Week[i] == "Tuesday")
    Week_df$Count[i] = 2
  else if (Week_df$Week[i] == "Wednesday")
    Week_df$Count[i] = 3
  else if (Week_df$Week[i] == "Thursday")
    Week_df$Count[i] = 4
  else if (Week_df$Week[i] == "Friday")
    Week_df$Count[i] = 5
  else if (Week_df$Week[i] == "Saturday")
    Week_df$Count[i] = 6
  else
    Week_df$Count[i] = 7
  i = i+1
}
i = 1
while(i <= length(Week_df$Week)){
  if(Week_df$Count[i] == 1)
    Week_df$Count2[i] = all_df_list$Week_df$Count[1]
  else if(Week_df$Count[i] == 2)
    Week_df$Count2[i] = all_df_list$Week_df$Count[2]
  else if(Week_df$Count[i] == 3)
    Week_df$Count2[i] = all_df_list$Week_df$Count[3]
  else if(Week_df$Count[i] == 4)
    Week_df$Count2[i] = all_df_list$Week_df$Count[4]
  else if(Week_df$Count[i] == 5)
    Week_df$Count2[i] = all_df_list$Week_df$Count[5]
  else if(Week_df$Count[i] == 6)
    Week_df$Count2[i] = all_df_list$Week_df$Count[6]
  else
    Week_df$Count2[i] = all_df_list$Week_df$Count[7]
  i = i +1
}
Week_df = Week_df %>% arrange(Count)
list2[[4]] = Week_df
names(list2)[4] = "Week_df"
rm(Week_df)
rm(i)

#Counting for Time of Day
Hour_df = data.frame(hour(data_MP$Incident.Datetime))
Hour_df = data.frame(Hour_df, Hour_df)
names(Hour_df)[1] = "Hour"
names(Hour_df)[2] = "Count"
typeof(all_df_list$Hour_df$Count[Hour_df$Hour[3]])
typeof(Hour_df$Count[9])
Hour_df$Hour[3]
all_df_list$Hour_df$Count[0]
i = 1
while(i <= length(Hour_df$Hour)){
  if(Hour_df$Hour[i] == 0)
    Hour_df$Count[i] = 771
  else {
    j = Hour_df$Hour[i] + 1
    Hour_df$Count[i] = all_df_list$Hour_df$Count[j]
  }
i = i +1 
}
list2[[5]] = Hour_df
names(list2)[5] = "Hour_df"
rm(Hour_df)

#How many were found?
#!!! This one, you must use supplemental reports as well
data_MP_with_supplement = data.frame(subset(data, data$Incident.Category == "Missing Person"))
Found_df = data.frame(subset(data_MP_with_supplement, 
data_MP_with_supplement$Incident.Description == "Found Person"))
Found_df = data.frame(Found_df$Incident.Description)
names(Found_df)[1] = "Found"
names(Found_df)[2] = "Count"
list2[[6]] = Found_df
names(list2)[6] = "Found_df"
rm(Found_df)
rm(data_MP_with_supplement)

#Arranging for top neighborhood data
#Rename 1st row, if not it won't work
list2$Neighborhood_Count$Neighborhood[[1]] = "Empty"
list2$Neighborhood_Count = arrange(list2$Neighborhood_Count, 
desc(list2$Neighborhood_Count$Count))
Top5 = data.frame(list2$Neighborhood_Count[1:5,])
list2[[7]] = Top5
rm(Top5)
names(list2)[7] = "Top 5"
rm(i)
rm(j)
