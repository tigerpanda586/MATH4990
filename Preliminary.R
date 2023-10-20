#Reads Data from CSV file into DF
#install.packages("lubridate")
library(here)
library(dplyr)
data = read.csv(here("Datasets", "Police_Department_Incident_Reports__2018_to_Present.csv"))
View(data)

#Change format of all time to HH:MM in order to make Time column
#into Time variable
#library(chron)
#i = 1
#while(i <= length(data$Incident.Time))
#{
#  first = strsplit(data$Incident.Time[i], ":")[[1]][1]
#  second = strsplit(data$Incident.Time[i], ":")[[1]][2]
#  if(as.numeric(first, length = 1) < 10)
#  {
#    data$Incident.Time[i] = paste0("0", first, ":", second) 
#  }
#  print(data$Incident.Time[i])
#  print(i)
#  i = i +1
#}

#Change Incident.Time column to lubridate readable
library(lubridate)
data$Incident.Time = hm(data$Incident.Time)
#Lubridate other time columns
data$Incident.Datetime = parse_date_time(data$Incident.Datetime, orders = "mdy HM")
data$Incident.Date = parse_date_time(data$Incident.Date, orders = "mdy")

#Make separate DF w/ no duplicate incidents
data_unique = group_by(data, data$Incident.ID) %>% slice(1)
View(data_unique)

#Make table of frequency of each type of incident
Category_Count = table(data$Incident.Category)
#Make into DF
df_cat = data.frame(Category_Count)
#Rename Columns for my mental ease
names(df_cat)[names(df_cat) == "Var1"] = "Category"
names(df_cat)[names(df_cat) == "Freq"] = "Category_Count"
View(df_cat)

#Do the same thing but with unique DF
#Category_Count_unique = table(data_unique$Incident.Category)
#df_cat_unique = data.frame(Category_Count_unique)
#names(df_cat_unique)[names(df_cat_unique) == "Var1"] = "Category"
#names(df_cat_unique)[names(df_cat_unique) == "Freq"] = "Category_Count"
#View(df_cat_unique)

#Set up avg time of day column
df_cat$avg_time_of_day = 0
#Set up mode of neighborhood
df_cat$neighborhood_mode = " "

#Take only times of day & Incident.Category out of DF: data_unique
df_cat_details = data.frame(data$Incident.Category, 
data$Incident.Time, data$Analysis.Neighborhood)
#We're fix times to standard format and make them time variables for comparison


View(df_cat_details)

#This while loop Makes a DF for each type of crime
#Make a list of pointers to each dataframe
list_all_cat = list()
#First one causes error b/c does not have a name so do it manually
list_all_cat[[1]] = assign("Empty_Row", data.frame(subset(df_cat_details, 
df_cat_details$data.Incident.Category == df_cat$Category[1])))
i = 2
while(i <= length(df_cat$Category))
{
  list_all_cat[[i]] = assign(paste(df_cat$Category[i]), data.frame(df_cat$Category == i))
  i = i + 1
}

#list_all_cat[[i]] = assign(paste(df_cat$Category[i]), data.frame(subset(df_cat_details, 
                                                                        df_cat_details$data.Incident.Category == df_cat$Category[i])))
#mean(times(Empty_row$data.Incident.Time[1]))
#i = 2
#while(i <= length(df_cat$Category))
#{
#  df_cat$avg_time_of_day[i] = mean(times(i))
#  i = i + 1
#}

View(list_all_cat[[2]])
list_all_cat[[2]]$data.Incident.Time[1:10]
mean(list_all_cat[[2]]$data.Incident.Time[1:10])
i = 1
while(i <= length(data$Report.Type.Description))
{
  if()                        
  i = i + 1
}

