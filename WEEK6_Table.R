#Import libraries I will likely need
library(lubridate)
library(here)
library(forecast)
library(readr)
library(Metrics)

#All these tables were derived in the file named 
#"Week5_TimeSeries_FORWEEK6_Editing.Rmd"
#I saved them as text files and am now importing them

data_2022 = read.table(here("Datasets", "data_2022.txt"))
fore_expxmth = read.table(here("Datasets", "fore_expxmth.txt"))
fore_holtexpxmth = read.table(here("Datasets", "fore_holtexpxmth.txt"))
fore_arimaauto = read.table(here("Datasets", "fore_arimaauto.txt"))
fore_arimamine = read.table(here("Datasets", "fore_arimamine.txt"))
prophet_sum = read.table(here("Datasets", "prophet_sum.txt"))
fore_knn = read.table(here("Datasets", "fore_knn.txt"))

#Now we make a new df called alldata where we show the forecasted values
#for the months of 2022 with different methods and the real values
alldata = data.frame(c(1:6))
alldata$Actual = data_2022$Freq[49:54]
alldata$SMS = as.numeric(fore_expxmth$Point.Forecast)
alldata$SMS_Holt = as.numeric(fore_holtexpxmth$Point.Forecast)
alldata$`Arima(5,3,2)` = as.numeric(fore_arimamine$Point.Forecast)
alldata$`Arima(0,1,1)` = as.numeric(fore_arimaauto$Point.Forecast)
alldata$Prophet = prophet_sum$Freq
alldata$KNN = fore_knn$prediction.prediction


#Now we make a table to show the error of calculation

#1st - Reverse alldata table so I don't have to preserve col/row names
Error_Tables = data.frame(t(alldata))
#Take out data I don't need
Error_Tables = Error_Tables[3:8,1:4]
#Rename to variables that are relevant
colnames(Error_Tables) = c("MAE", "TS", "MSE", "RSFE")
#Make all values equal to 0 so I can now calculate correct values!!!
Error_Tables[] = 0

#First we will get MAE from the accuracy function from Metrics library
Error_Tables$MAE[1] = mae(alldata$Actual, alldata$SMS)
Error_Tables$MAE[2] = mae(alldata$Actual, alldata$SMS_Holt)
Error_Tables$MAE[3] = mae(alldata$Actual, alldata$`Arima(5,3,2)`)
Error_Tables$MAE[4] = mae(alldata$Actual, alldata$`Arima(0,1,1)`)
Error_Tables$MAE[5] = mae(alldata$Actual, alldata$Prophet)
Error_Tables$MAE[6] = mae(alldata$Actual, alldata$KNN)

#Now get MSE from Metrics library
Error_Tables$MSE[1] = mse(alldata$Actual, alldata$SMS)
Error_Tables$MSE[2] = mse(alldata$Actual, alldata$SMS_Holt)
Error_Tables$MSE[3] = mse(alldata$Actual, alldata$`Arima(5,3,2)`)
Error_Tables$MSE[4] = mse(alldata$Actual, alldata$`Arima(0,1,1)`)
Error_Tables$MSE[5] = mse(alldata$Actual, alldata$Prophet)
Error_Tables$MSE[6] = mse(alldata$Actual, alldata$KNN)

#MAD from Metrics library to calculate TS
mad_SMS = mse(alldata$Actual, alldata$SMS)
mad_SMS_Holt = mse(alldata$Actual, alldata$SMS_Holt)
`mad_Arima(5,3,2)` = mse(alldata$Actual, alldata$`Arima(5,3,2)`)
`mad_Arima(0.1.1)` = mse(alldata$Actual, alldata$`Arima(0,1,1)`)
mad_Prophet = mse(alldata$Actual, alldata$Prophet)
mad_KNN = mse(alldata$Actual, alldata$KNN)

#Online is telling me I can calculate RSFE by doing
# rsfe <- sum(data$Actual-data$Forecast)
#I cannot find a package tht does it for you
Error_Tables$RSFE[1] = sum(alldata$Actual - alldata$SMS)
Error_Tables$RSFE[2] = sum(alldata$Actual - alldata$SMS_Holt)
Error_Tables$RSFE[3] = sum(alldata$Actual - alldata$`Arima(5,3,2)`)
Error_Tables$RSFE[4] = sum(alldata$Actual - alldata$`Arima(0,1,1)`)
Error_Tables$RSFE[5] = sum(alldata$Actual - alldata$Prophet)
Error_Tables$RSFE[6] = sum(alldata$Actual - alldata$KNN)


#TS (Tracking Signal) is calculated by doing RSFE/MAD
Error_Tables$TS[1] = Error_Tables$RSFE[1]/mad_SMS
Error_Tables$TS[2] = Error_Tables$RSFE[2]/mad_SMS_Holt
Error_Tables$TS[3] = Error_Tables$RSFE[3]/`mad_Arima(5,3,2)`
Error_Tables$TS[4] = Error_Tables$RSFE[4]/`mad_Arima(0.1.1)`
Error_Tables$TS[5] = Error_Tables$RSFE[5]/mad_Prophet
Error_Tables$TS[6] = Error_Tables$RSFE[5]/mad_KNN


