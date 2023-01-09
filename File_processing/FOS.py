# process 39 files with data on Consolidated Federal Budget revenues and create a single dataframe
# I use the 2nd level of the budget classification of income


# upload necessary libraries
import pandas as pd
import numpy as np
import os

path = "path_to_file" # path to file
output = pd.DataFrame()

for file in os.listdir(path): # for each file in folder
    df = pd.read_excel(path + '/' + file, sheet_name=1,  header=None, dtype=str) # upload file
    period = df.iloc[3, 3] # take period
    period = period.replace('на ', '') # change period format
    df = df.dropna(how='all', axis=1) # drop nans
    df = df.loc[17:, [0, 3, 5]] # I remain only necessary columns
    df.columns = ['Тип', "Код", "Сумма"] # rename columns
    df['Период'] = period # add period
    df['level_1'] = np.where(df["Код"].str.contains('0' * 16) == 1, 1, 0) # 1st level of classification
    df['level_2'] = np.where(df["Код"].str.contains('0' * 14) == 1, 1, 0) # 2nd level of classification
    df["Сумма"] = df["Сумма"].str.replace(' ', '') # change unnecessary punctuation marks in lines 
    df["Сумма"] = df["Сумма"].str.replace(',', '.')# change unnecessary punctuation marks in lines
    df["Сумма"] = df["Сумма"].astype(float)# change datatype in revenue column
    df = df.loc[(df.level_1==0)&(df.level_2==1), ['Период','Тип', 'Сумма']] # remain only necessary columns
    output = output.append(df) # add to summarizing dataframe
output['Сумма'] = round(output['Сумма']/10**9, 3) # turn numbers into billions
output['Период'] = output['Период'].str.strip() # format the names of the periods
output['Период'] = output['Период'].str.replace('"','') # format the names of the periods
output['Период'] = output['Период'].str.replace('  ',' ') # format the names of the periods
output['Период'] = output['Период'].str.replace('г.','') # format the names of the periods
output['Период'] = np.where(output['Период'].str.startswith('0'), output['Период'], "0"+output['Период']) # format the names of the periods
slovar = {'января':'Jan','февраля':'Feb', 'авста':'Aug','марта':'Mar', 'апреля':'Apr', 'мая':'May', 'июня':'Jun', 'июля':'Jul', 'августа':'Aug', 'сентября':'Sep', 'октября':'Oct', 'ноября':'Nov', 'декабря':'Dec'}
output = output.replace({'Период': slovar}, regex=True) # I change the names of months from Russian to English, to convert to the date format
output['Период'] = pd.to_datetime(output['Период']).dt.date # coner to date format

dict = pd.read_excel("path_to_mapping_file") # upload file with mapping
output = pd.merge(output, dict, left_on='Тип', right_on='before') # merge dataframe and mapping
output = output.drop(columns=['Тип', 'before']) # drop unnecessary columns
output = output.rename(columns = {'after': "Вид"}) # rename columns
grouped = output.groupby(['Вид', 'Период'])['Сумма'].sum().unstack().reset_index().fillna(0) # create anouther table which is convenient to analyze

with pd.ExcelWriter("path_out") as writer: # we write two tables on different sheets of the same excel file
    output.to_excel(writer, sheet_name='общаяя выгрузка', index=False)
    grouped.to_excel(writer, sheet_name='сгруппированная', index=False)

