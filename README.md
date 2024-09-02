# Qloapps with CapRover

Create a new app (e.g., "qloapp")

## persistent directories
In the "App Configs" tab, add these persistent directories:

> /var/www/html

> /var/lib/mysql

## Environmental Variables
In the "Environmental Variables" section, you can add (optional, as defaults are provided):
> DB_NAME=qloapp_db

> DB_USER=qloapp_user

> DB_PASS=your_strong_password

## Port Mapping
In Port Mapping section map  
> Container's port : 80
to
> Server's port : 8082 # this is what i use
## Click Save and Reboot
## Add Dockerfile
Go to the "Deployment" tab
Choose "Deploy from Dockerfile"
Paste the docker file
Click 'Deploy'
