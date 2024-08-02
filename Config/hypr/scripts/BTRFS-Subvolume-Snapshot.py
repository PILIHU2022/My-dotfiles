'''Btrfs子卷快照'''
import os
import time
# from datetime import datetime, timedelta
# date = time.strftime('%Y-%m-%d',time.localtime())
# before_date=date - timedelta(1)
# print(before_date)
# x = time.strftime('%Y-%m-%d', datetime.now()+timedelta(days=1))
# z = datetime.now()+timedelta(days=1)
# y = time.strftime("%Y-%m-%d")
# print(x)
# print(y)
# print(z)
location = '/Snapshots'
unfull_date = time.strftime('%Y-%m', time.localtime())
today_date_of_day = int(time.strftime('%d', time.localtime()))
yesterday_date_of_day = today_date_of_day - 1
yesterday_full_date = f'{unfull_date}-{yesterday_date_of_day}'
today_date = time.strftime('%Y-%m-%d', time.localtime())
# Btrfs delete yesterday's snapshot
os.system(f'doas btrfs subvolume delete  / {location}/{yesterday_full_date}')
# Btrfs create today's snapshot for root(/)
os.system(f'doas btrfs subvolume snapshot / {location}/{today_date}')
