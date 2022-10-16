# обработать 39 файлов об исполнении Федерального бюджета и составить единый датафрейм
# использую 2ой уровень бюджетной классификации доходов


# загружаем необходимые библиотеки
import pandas as pd
import numpy as np
import os

path = "Путь к папке" # устанавливаем путь к папке с 39 файлами
output = pd.DataFrame()

for file in os.listdir(path): # для каждого файла в папке
    df = pd.read_excel(path + '/' + file, sheet_name=1,  header=None, dtype=str) # подгружаем файл
    period = df.iloc[3, 3] # вытаскиваем период
    period = period.replace('на ', '') # форматируем имя периода
    df = df.dropna(how='all', axis=1) # убираем пустые значения
    df = df.loc[17:, [0, 3, 5]] # только нужные строки и столбцы
    df.columns = ['Тип', "Код", "Сумма"] # переименовываем столбцы
    df['Период'] = period # проставляем период
    df['level_1'] = np.where(df["Код"].str.contains('0' * 16) == 1, 1, 0) # 1ый уровень классификации
    df['level_2'] = np.where(df["Код"].str.contains('0' * 14) == 1, 1, 0) # 2ой уровень классификации
    df["Сумма"] = df["Сумма"].str.replace(' ', '') # меняем неудобные нам знаки в строчках
    df["Сумма"] = df["Сумма"].str.replace(',', '.')# меняем неудобные нам знаки в строчках
    df["Сумма"] = df["Сумма"].astype(float)# меняем тип данных в строке сумма (доходов)
    df = df.loc[(df.level_1==0)&(df.level_2==1), ['Период','Тип', 'Сумма']] # оставляем только нужный нам уровень
    output = output.append(df) # добавляем в единый датафрейм
output['Сумма'] = round(output['Сумма']/10**9, 3) # превращаем число в миллиарды
output['Период'] = output['Период'].str.strip() # форматируем наименования периодов
output['Период'] = output['Период'].str.replace('"','') # форматируем наименования периодов
output['Период'] = output['Период'].str.replace('  ',' ') # форматируем наименования периодов
output['Период'] = output['Период'].str.replace('г.','') # форматируем наименования периодов
output['Период'] = np.where(output['Период'].str.startswith('0'), output['Период'], "0"+output['Период']) # форматируем наименования периодов
slovar = {'января':'Jan','февраля':'Feb', 'авста':'Aug','марта':'Mar', 'апреля':'Apr', 'мая':'May', 'июня':'Jun', 'июля':'Jul', 'августа':'Aug', 'сентября':'Sep', 'октября':'Oct', 'ноября':'Nov', 'декабря':'Dec'}
output = output.replace({'Период': slovar}, regex=True) # меняем названия месяцев с русского на английский, для конвертации в формат дат
output['Период'] = pd.to_datetime(output['Период']).dt.date # конвертируем период в формат дат

dict = pd.read_excel("Путь к файлу с мэппингом") # считываем файл с мэппингом
output = pd.merge(output, dict, left_on='Тип', right_on='before') # склеиваем датафрейм и мэппинг
output = output.drop(columns=['Тип', 'before']) # убираем ненужные строчки
output = output.rename(columns = {'after': "Вид"}) # переименовываем
grouped = output.groupby(['Вид', 'Период'])['Сумма'].sum().unstack().reset_index().fillna(0) # делаем еще одну удобную для анализа таблицу

with pd.ExcelWriter("Путь вывода файла") as writer: # записываем две таблицы на разные листы одного эксель-файла
    output.to_excel(writer, sheet_name='общаяя выгрузка', index=False)
    grouped.to_excel(writer, sheet_name='сгруппированная', index=False)

