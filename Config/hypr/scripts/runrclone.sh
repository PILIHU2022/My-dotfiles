#! /bin/bash
rclone mount OneDrive:Backup /mnt/Backup --vfs-cache-mode writes
rclone mount OneDrive_QQ:Backup /mnt/Backup_QQ --vfs-cache-mode writes

