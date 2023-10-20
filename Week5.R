#"Dumped Code"

#We're predicting 2022 so 2023 is useless & we're only analyzing
#missing person
data = data.frame(subset(data, Incident.Year != 2023 & 
Incident.Category == "Missing Person"))
#Get df with just 2022 data as that is what's being predicted
data_2022 = data.frame(subset(data, Incident.Year == 2022))
#Give a "Class" column where 2022 is test data
data_2022$Class = "Test"
#Same thing but with every year but 2022
data_rest = data.frame(subset(data, Incident.Year != 2022))
#Add "Class" col where everything else is train data
data_rest$Class = "Train"
#Take these two df and combine it back to original df
data = rbind(data_2022, data_rest)
#Take out the trash
rm(data_2022)
rm(data_rest)

#Honestly, this is same as data_2022 & data_rest. I'm kinda dumb for that
#but the idea is to split up test & train data
train_MP = subset(data, Class == "Train")
test_MP = subset(data, Class == "Test")

#This is where I went wrong.. there's supposed to be 12 rows for train
#since afterall we're predicting one year.. i did it wrong
nrow(train_MP) ; nrow(test_MP)

#trying to make a row for every month but i give up & will do it
#a different way
MissingPeople$"1" = 0; MissingPeople$"2" = 0; MissingPeople$"3" = 0; MissingPeople$"4"= 0
MissingPeople$"5"; MissingPeople$"6"; MissingPeople$"7"; MissingPeople$"8"
MissingPeople$"9"; MissingPeople$"10"; MissingPeople$"11"; MissingPeople$"12"

#Everything I did wrong with ts
data_2021 = t(data_2021$Freq)
data_2020 = t(data_2020$Freq)
data_2019 = t(data_2019$Freq)
data_2018 = t(data_2018$Freq)

#Combine them into one table
data_months = rbind(data_2018, data_2019, data_2020, data_2021)

#Rename columns and such
row.names(data_months) = c("2018", "2019", "2020", "2021")
colnames(data_months) = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

#All this loop does is construct a datetime object. It looks complicated, but I properly wrote it the fastest of anything.
i = 1
while(i <= length(prophet_df$Freq)){
  j = "String"
  month = "STRING"
  if(i <= 12)
    j = "2018-"
  else if(i <= 24)
    j = "2019-"
  else if(i <= 36)
    j = "2020-"
  else
    j = "2021-"
  
  month = i %% 12
  if(month == 0)
    month = 12
  if(month < 10)
    month = paste(0, month, sep = "")
  o = paste(j, month, "-15", sep = "")
  prophet_df$ds[i] = o
  
  i = i + 1
}
