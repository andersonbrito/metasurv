#!/usr/bin/python

# Created by: Anderson Brito
#
# row2matrix.py -> It converts stacked rows of values in two columns into a matrix
#
#
# Release date: 2021-08-22
# Last update: 2021-09-22

import pandas as pd
import argparse
import time
from datetime import timedelta

pd.set_option('max_columns', 100)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Generate matrix of occurrences at the intersection of two columns",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--input", required=True, help="Matrix of daily case counts per location")
    parser.add_argument("--xvar", required=True, type=str, help="Data that goes in the X axis of the matrix")
    parser.add_argument("--xtype", required=False, type=str, help="Is the x variable a time variable (date)? If so, enter 'time'")
    parser.add_argument("--target", required=False, type=str, help="Target column, when variable is already aggregated")
    parser.add_argument("--sum-target",required=False, nargs=1, type=str, default='no',
                        choices=['no', 'yes'], help="Should values in target column be summed up?")
    parser.add_argument("--yvar", required=True, type=str, help="Data that goes in the Y axis of the matrix")
    parser.add_argument("--extra-columns", required=False, nargs='+', type=str, help="extra columns to export")
    parser.add_argument("--filter", required=False, type=str, help="Format: '~column_name:value'. Remove '~' to keep only that data category")
    parser.add_argument("--start-date", required=False, type=str,  help="Start date in YYYY-MM-DD format")
    parser.add_argument("--end-date", required=False, type=str,  help="End date in YYYY-MM-DD format")
    parser.add_argument("--output", required=True, help="TSV matrix")
    args = parser.parse_args()

    input = args.input
    x_var = args.xvar
    x_type = args.xtype
    target_variable = args.target
    sum_target = args.sum_target
    y_var = args.yvar
    extra_cols = args.extra_columns
    filter_value = args.filter
    start_date = args.start_date
    end_date = args.end_date
    output = args.output

    # path = '/Users/anderson/GLab Dropbox/Anderson Brito/ITpS/projetos_itps/metasurvBR/analyses/bubbles_20211016/'
    # input = path + 'caso_full.csv'
    # x_var = 'date'
    # x_type = 'time'
    # target_variable = 'new_confirmed'
    # y_var = 'state'
    # sum_target = 'no'
    # extra_cols = 'city_ibge_code, estimated_population_2019'
    # filter_value = 'place_type:state'
    # start_date = '2021-08-29' # start date above this limit
    # end_date = '2021-10-09' # end date below this limit
    # output = path + 'matrix.tsv'


    def load_table(file):
        df = ''
        if str(file).split('.')[-1] == 'tsv':
            separator = '\t'
            df = pd.read_csv(file, encoding='utf-8', sep=separator, dtype='str')
        elif str(file).split('.')[-1] == 'csv':
            separator = ','
            df = pd.read_csv(file, encoding='utf-8', sep=separator, dtype='str')
        elif str(file).split('.')[-1] in ['xls', 'xlsx']:
            df = pd.read_excel(file, index_col=None, header=0, sheet_name=0, dtype='str')
            df.fillna('', inplace=True)
        else:
            print('Wrong file format. Compatible file formats: TSV, CSV, XLS, XLSX')
            exit()
        return df


    df = load_table(input)
    df.fillna('', inplace=True)
    if filter_value not in ['', None]:
        if filter_value.startswith('~'):
            filter_value = filter_value[1:]
            df = df[~df[filter_value.split(':')[0]].isin([filter_value.split(':')[1]])]
        else:
            df = df[df[filter_value.split(':')[0]].isin([filter_value.split(':')[1]])]

    if x_type == 'time':
        today = time.strftime('%Y-%m-%d', time.gmtime())
        df[x_var] = pd.to_datetime(df[x_var])  # converting to datetime format
        if start_date == None:
            start_date = df[x_var].min()
        if end_date == None:
            end_date = today

        mask = (df[x_var] >= start_date) & (df[x_var] <= end_date)  # mask any lines with dates outside the start/end dates
        df = df.loc[mask]  # apply mask
        df[x_var] = df[x_var].dt.strftime('%Y-%m-%d')

    # print(df.head)
    if x_type == 'time':
        time_range = [day.strftime('%Y-%m-%d') for day in list(pd.date_range(pd.to_datetime(start_date), pd.to_datetime(end_date), freq='d'))]
        cols = time_range
    else:
        cols = sorted(df[x_var].unique().tolist())
    rows = sorted(df[y_var].unique().tolist())


    # print(cols)
    # print(rows)

    df2 = pd.DataFrame(index=rows, columns=cols)
    df2 = df2.fillna(0) # with 0s rather than NaNs

    # add other columns, if available
    if extra_cols == None:
        extra_cols = []
    else:
        extra_cols = [x.strip() for x in extra_cols[0].split(',')]

    for column in extra_cols:
        if column in df.columns.to_list():
            df2.insert(0, column, '')

    # give index a name
    df2.index.name = y_var
    if target_variable in ['', None]:
        df = df.groupby([x_var, y_var]).size().to_frame(name='count').reset_index() # group and count occorrences
    else:
        if sum_target == 'yes':
            print(x_var, y_var)
            df = df.groupby([x_var, y_var]).sum().to_frame(name='count').reset_index()
            # df['count'] = df[target_variable].groupby(df[[x_var, y_var]]).transform('sum')
        else:
            df = df.rename(columns={target_variable: 'count'})

    df.set_index(y_var, inplace=True)

    # fill extra columns with their original content
    for idx, row in df2.iterrows():
        for column in extra_cols:
            # print(df.columns.to_list())
            if column in df.columns.to_list():
                value = df.loc[idx, column][0]
                # value = df.loc[df.index == idx][column].values[0]
                df2.at[idx, column] = value

    df = df.reset_index()

    # populate output dataframe
    for idx, row in df.iterrows():
        x = df.loc[idx, x_var]
        y = df.loc[idx, y_var]
        count = df.loc[idx, 'count']
        if float(count) < 0:
            print(count)
            count = 0
        df2.at[y, x] = count

    # if filter_value not in ['', None]:
    #     df2.insert(0, filter_value.split(':')[0].strip(), '')
    #     df2[filter_value.split(':')[0].strip()] = filter_value.split(':')[1].strip()

    # save
    df2.to_csv(output, sep='\t', index=True)
    print('\nConversion successfully completed.\n')