# -*- coding: utf-8 -*-
"""
LTSM Attempt and bringing R stuff into Python
It's actually not a failure. I got it to work, but
with that being said, it works just like SMS... it's giving
me an average.. lmao. Why is it so bad like this?
Serious so.. so lame.
"""
import os as os;
import pandas as pd;
from pathlib import Path;
os.chdir("C:/Users/TreeP/AppData/Local/Programs/Python/Python311/Lib/site-packages");
import tensorflow as tf;
import numpy as np;


#Figure out what directory I'm currently in
cur_dir = Path.cwd();
#print(cur_dir);

#Set a new directory path for importing my already made text files
new_dir = Path("C:/Users/TreeP/OneDrive/Documents/RScripts/MATH4990/Datasets");
#Make that my actual directory
os.chdir(new_dir);

#Check you really got the right directory
cur_dir = os.getcwd();
#print(cur_dir);

#Import all old date from R
data_2022 = pd.read_csv("data_2022.txt");
fore_expxmth = pd.read_csv("fore_expxmth.txt");
fore_holtexpxmth = pd.read_csv("fore_holtexpxmth.txt");
fore_arimaauto = pd.read_csv("fore_arimaauto.txt");
fore_arimamine = pd.read_csv("fore_arimamine.txt");
prophet_sum = pd.read_csv("prophet_sum.txt");
fore_knn = pd.read_csv("fore_knn.txt");
Error_Tables = pd.read_csv("error_tables.txt");

#Fix Table cux it got imported wrong
i = 0;
while(i < len(data_2022["Freq"])):
     if(i < 9):
         data_2022["Freq"][i] = data_2022["Freq"][i][2:5] 
         i = i + 1;
     else:
         data_2022["Freq"][i] = data_2022["Freq"][i][3:6] 
         i = i + 1;

#Make a loop so I can have dates as index for dataframe
dates = [];
i = 0;
j = 1;
cur = "";
while(i < len(data_2022["Freq"])):
     if(i < 12):
         cur = "2018-"
     elif(i < 24):
         cur = "2019-"
     elif(i < 36):
         cur = "2020-"
     elif(i < 48):
        cur = "2021-"
     elif(i < 60):
        cur = "2022-"
     if(j < 10):
        cur = cur + str(0) + str(j);
        dates.append(cur);
     else:
        if(j == 13):
            j = 1;
        cur = cur + str(j);
        dates.append(cur);
     if(i%12 == 0):
         j = 1;
     i = i + 1;
     j = j + 1;

#Make new column called dates to eventually make index for plotting
data_2022["dates"] = dates;
#print(data_2022);

#Parse datetime with pandas while also setting index to dates
data_2022.index = pd.to_datetime(data_2022["dates"], format = "%Y-%m");
#print(data_2022);

#Turn freq frame into numeric b/c for some reason, it is an object
data_2022["Freq"] = pd.to_numeric(data_2022["Freq"]);

#Plot this ts
temp2 = data_2022["Freq"];
temp2.plot();

first6 = data_2022["Freq"][0:54]

#This code is all from YouTuber Greg Hogg in this video:
#https://www.youtube.com/watch?v=c0k-YLQGKjY&t=301s

#This function spits data up into sets of <window_size>
#The purpose of this exercise is to have a set of <>
#predict the next value. So the past <> vals determine
#the next value... This is to use LSTM!!!
def df_to_X_y(df, window_size = 5):
    df_as_np = df.to_numpy();
    X = [];
    y = [];
    for i in range(len(df_as_np) - window_size):
        row = [[a] for a in df_as_np[i:i+5]];
        X.append(row);
        label = df_as_np[i+5];
        y.append(label);
    return np.array(X), np.array(y);

#Insert your data
WINDOW_SIZE = 5;
X, y = df_to_X_y(first6, WINDOW_SIZE);
print(X.shape, y.shape);

#Define your training & etc sets
X_train, y_train = X[:30], y[:30];
X_val, y_val = X[35:43], y[35:43];
X_test, y_test = X[43:], y[43:];
print(X_train.shape, y_train.shape, X_val.shape, y_val.shape, X_test.shape, y_test.shape);

#The meaning of X shape output for your sanity..
#The first val is the length, 2nd is window/set
#size, 3rd is how many variables (being used? predicting? not sure)
#y output is "labels" -- YouTube guy said this

from tensorflow.keras.models import Sequential;
from tensorflow.keras.layers import *;
from tensorflow.keras.callbacks import ModelCheckpoint;
from tensorflow.keras.losses import MeanSquaredError;
from tensorflow.keras.metrics import RootMeanSquaredError;
from tensorflow.keras.optimizers import Adam;

model1 = Sequential();
#5 as in window_size, 1 as in # of variables
model1.add(InputLayer((5, 1)));
#he said to just use 64.. and does not explain
model1.add(LSTM(64));
model1.add(Dense(8, "relu"));
model1.add(Dense(1, "linear"));

#Mine outputs the same as his so I consider this a success
model1.summary();

cp = ModelCheckpoint("model1/", save_best_only = True)
#Higher learning rate is, faster model will decrease
#maximum loss. You don't want this a big number b/c
#we're aiming for most optimal model, want to
#test thoroughly
model1.compile(loss = MeanSquaredError(), optimizer = Adam(learning_rate = .005),
metrics = [RootMeanSquaredError()]);

#this makes the actual model that will be used for predictions   
model1.fit(X_train, y_train, validation_data = (X_val, y_val), 
epochs = 310, callbacks = [cp]);


#Below, the predictions are made for all and df are made as well
from tensorflow.keras.models import load_model;
model1 = load_model("model1/");

train_predictions = model1.predict(X_train).flatten();
train_results = pd.DataFrame(data = {"Train Predictions":
train_predictions, "Actuals": y_train});
    
val_predictions = model1.predict(X_val).flatten();
val_results = pd.DataFrame(data = {"Validation Predictions":
val_predictions, "Actuals": y_val});
    
test_predictions = model1.predict(X_test).flatten(); 
test_results = pd.DataFrame(data = {"Test Predictions":
test_predictions, "Actuals": y_test});
    
#I have the dfs grayed out b/c I will run this many more times to
#see the varying results, but I will just keep files I already have.
#I do not want to store new results everytime
#train_results.to_csv("lSTM_Train_ByMonth.txt", sep = " ");
#val_results.to_csv("lSTM_Val_ByMonth.txt", sep = " ");
#test_results.to_csv("lSTM_Test_ByMonth.txt", sep = " ");

#Now, we will do some plots still courtesy of YouTuber Greg Hogg
#It lowkey, highkey didn't work but whatever
import matplotlib.pyplot as plt

plt.plot(train_results["Train Predictions"][:])
plt.plot(train_results["Actuals"])[:]

plt.plot(val_results["Validation Predictions"][:])
plt.plot(val_results["Actuals"][:])

plt.plot(test_results["Test Predictions"][:])
plt.plot(test_results["Actuals"][:])

print(test_results);

print(os.getcwd());








