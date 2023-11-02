# -*- coding: utf-8 -*-
"""
Created on Fri Oct 20 00:00:02 2023

@author: TreeP
"""

# -*- coding: utf-8 -*-
"""
LTSM Attempt and bringing R stuff into Python
"""
#This is supposed to set a seed for all code below to make results
#repeatable and comparable. I got this information from:
#https://machinelearningmastery.com/reproducible-results-neural-networks-keras/
from numpy.random import seed;
seed(59);
from pathlib import Path;
import os as os;
os.chdir("C:/Users/TreeP/AppData/Local/Programs/Python/Python311/Lib/site-packages");
import tensorflow as tf;
tf.random.set_seed(59);

import pandas as pd;
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

#Import daily data through dfs manipulated in R
LSTM_ByDay = pd.read_csv("LSTM_ByDay.txt", sep = " ");

#This takes out all dates after 2022-06-30
LSTM_ByDay = LSTM_ByDay[0:1616]

#This code is all from YouTuber Greg Hogg in this video:
#https://www.youtube.com/watch?v=c0k-YLQGKjY&t=301s

#This function spits data up into sets of <window_size>
#The purpose of this exercise is to have a set of <>
#predict the next value. So the past <> vals determine
#the next value... This is to use LSTM!!!
def df_to_X_y(df, window_size):
    df_as_np = df.to_numpy();
    X = [];
    y = [];
    for i in range(len(df_as_np) - window_size):
        row = [[a] for a in df_as_np[i:i+window_size]];
        X.append(row);
        label = df_as_np[i+window_size];
        y.append(label);
    return np.array(X), np.array(y);

#Insert your data
WINDOW_SIZE = 32;
X, y = df_to_X_y(LSTM_ByDay["Freq"], WINDOW_SIZE);
print(X.shape, y.shape);

#Define your training & etc sets
#Notice that 1434 is where 2022-01-01 begins minus 6
#Minus 6 is important because cannot predict value w/o 5 prev values
X_train, y_train = X[:1267], y[:1267];
X_val, y_val = X[1267:1406], y[1267:1406];
X_test, y_test = X[1406:], y[1406:];
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
model1.add(InputLayer((32, 1)));
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
model1.compile(loss = MeanSquaredError(), optimizer = Adam(learning_rate = .001),
metrics = [RootMeanSquaredError()]);

#this makes the actual model that will be used for predictions   
model1.fit(X_train, y_train, validation_data = (X_val, y_val), 
epochs = 1000, callbacks = [cp]);


#Below, the predictions are made for all and df are made as well
from tensorflow.keras.models import load_model;
model1 = load_model("model1/");

train_predictions = model1.predict(X_train).flatten();
train_results = pd.DataFrame(data = {"Train Predictions":
train_predictions, "Actuals": y_train, "Date": LSTM_ByDay["Var1"][32:1299]});

val_predictions = model1.predict(X_val).flatten();
val_results = pd.DataFrame(data = {"Validation Predictions":
val_predictions, "Actuals": y_val, "Date": LSTM_ByDay["Var1"][1299:1438]});
    
test_predictions = model1.predict(X_test).flatten(); 
test_results = pd.DataFrame(data = {"Test Predictions":
test_predictions, "Actuals": y_test, "Date": LSTM_ByDay["Var1"][1438:]});
    
#I have the dfs grayed out b/c I will run this many more times to
#see the varying results, but I will just keep files I already have.
#I do not want to store new results everytime
#train_results.to_csv("lSTM_Train_ByDay.txt", sep = " ");
#val_results.to_csv("lSTM_Val_ByDay.txt", sep = " ");
#test_results.to_csv("lSTM_Test_ByDay.txt", sep = " ");

#Now, we will do some plots still courtesy of YouTuber Greg Hogg
#It lowkey, highkey didn't work but whatever
import matplotlib.pyplot as plt

plt.plot(train_results["Train Predictions"][:])
plt.plot(train_results["Actuals"])[:]

plt.plot(val_results["Validation Predictions"][:])
plt.plot(val_results["Actuals"][:])

plt.plot(test_results["Test Predictions"][:])
plt.plot(test_results["Actuals"][:])

#Now time for error/result calculations
#Unfortunately, to make these comparable to the by-month
#models I've done in R, I will have to sum these by month
#in order to draw a by month comparison
#I will actually do a day & month version... actually

Jan = sum(test_results["Test Predictions"][:30]);
Feb = sum(test_results["Test Predictions"][30:57]);
Mar = sum(test_results["Test Predictions"][57:88]);
Apr = sum(test_results["Test Predictions"][88:118]);
May = sum(test_results["Test Predictions"][118:149]);
Jun = sum(test_results["Test Predictions"][149:]);

df_month = pd.DataFrame(data = {"Month":(Jan, Feb, Mar, Apr, May, Jun), 
"Actual":(128, 119, 163, 148, 159, 137)})

data_day = df_month["Month"];
actual_res_day = df_month["Actual"];

# Importing mean, absolute from numpy 
#Copied from: https://www.geeksforgeeks.org/absolute-deviation-and-absolute-mean-deviation-using-numpy-python/
from numpy import mean, absolute 
  
data = test_results["Test Predictions"];

# Absolute mean deviation 
mad_month = mean(absolute(data - mean(data)));
mad_day = mean(absolute(data_day - mean(data_day)));

#Need actual values to compute rest of metrics
actual_res = test_results["Actuals"];

#Calculate MAE
from sklearn.metrics import mean_absolute_error;
mae_month = mean_absolute_error(actual_res, data);
mae_day = mean_absolute_error(actual_res_day, data_day);

#Calculate MSE
from sklearn.metrics import mean_squared_error
mse_month = mean_squared_error(actual_res, data);
mse_day = mean_squared_error(actual_res_day, data_day);

#Calculate RSFE (running sum forecast error)
rsfe_month = sum(actual_res - data);
rsfe_day = sum(actual_res_day - data_day);

#Calculate TS (tracking signal)
ts_month = rsfe_month/mad_month;
ts_day = rsfe_day/mad_day;

#Finally, make a dataframe to hold such results
results = pd.DataFrame([(mae_day, ts_day, mse_day, rsfe_day), 
(mae_month,ts_month,mse_month,rsfe_month)], columns = ["MAE", "TS", 
"MSE", "RSFE"], index = ["E:1000_LR:.00001_Day", "E:1000_LR:.00001_Month"]);

#Export them as txt files
#results.to_csv("LSTM_Errors_E1000_LRp00001.txt", sep = " ");
#test_results.to_csv("LSTM_Results_E1000_LRp00001.txt", sep = " ");



    











