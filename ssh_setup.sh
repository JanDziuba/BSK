#!/bin/bash

make -C /app
chown root:root /app/officer_app
chmod 4755 /app/officer_app
printf "ForceCommand cd /app && ./officer_app" >> /etc/ssh/sshd_config
service ssh start
