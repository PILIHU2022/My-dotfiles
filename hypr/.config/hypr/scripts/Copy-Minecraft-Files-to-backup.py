import os
import time
# localtime= time.strftime('%H:%M', time.localtime())
localhour = time.strftime('%H', time.localtime())
location = '/home/PILIHU/.minecraft/versions/1.20.4/'
backup_location = '~/Minecraft'
current_pid = os.getpid()
dir = os.listdir('/home/PILIHU/.minecraft/versions/1.20.4/saves/')
while 2 == 1+1:
    if len(dir) == 0:
        break
    if localhour >= '12':
        os.system(f'kill {current_pid}')
    os.system(f"rsync -a -r --quiet --delete {location}* {backup_location}")
    os.system(f'cd {backup_location} && git add . && git commit -S -m "Normal backup" && git push main')
    time.sleep(1800)
