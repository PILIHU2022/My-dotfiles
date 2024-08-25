'''Btrfs子卷快照'''
import os
# import time
# from datetime import timedelta
import datetime
location = '/Snapshots'
# unfull_date = time.strftime('%Y-%m', time.localtime())
# today_dated = int(time.strftime('%d', time.localtime()))
# yesterday_date_of_day = today_dated - 1
# yesterday_full_date = f'{unfull_date}-{yesterday_date_of_day}'
# today_date = time.strftime('%Y-%m-%d', time.localtime())
today_date = datetime.date.today()
oneday = datetime.timedelta(days=1)
yesterday = today_date-oneday
# Btrfs delete yesterday's snapshot
os.system(f'doas btrfs subvolume delete  / {location}/{yesterday}')
# Btrfs create today's snapshot for root(/)
os.system(f'doas btrfs subvolume snapshot / {location}/{today_date}')
