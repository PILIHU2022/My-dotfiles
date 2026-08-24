'''Btrfs子卷快照'''
import os
import re
import datetime
location = '/Snapshots'
ls = os.listdir(location)
pattern = r'^\d{4}-\d{2}-\d{2}$'
regex = re.compile(pattern)
today_date = datetime.date.today()
oneday = datetime.timedelta(days=1)
# Btrfs delete yesterday's snapshot
for folder in ls:
    if regex.match(folder):
        os.system(f'doas btrfs subvolume delete {location}/{folder}')
# Btrfs create today's snapshot for root(/)
os.system(f'doas btrfs subvolume snapshot / {location}/{today_date}')
