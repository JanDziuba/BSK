#!/bin/bash

# Start the first process
exec gunicorn --chdir /app/client_project client_project.wsgi:application --bind 0.0.0.0:8000 --workers 3 &
  
# Start the second process
/usr/sbin/sshd -D &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?
