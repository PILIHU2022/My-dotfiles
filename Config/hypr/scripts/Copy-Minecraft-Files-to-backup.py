import os
import time
location = '~/.minecraft/versions/1.20.4/'
backup_location = '~/Minecraft'
while 2 == 1+1:
    os.system(f"rsync -a -r --quiet --delete {location}* {backup_location}")
    os.system(f'cd {backup_location} && git add . && git commit -S -m "Normal backup" && git push main')
    time.sleep(1800)
