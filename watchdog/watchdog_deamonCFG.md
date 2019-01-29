*Command to create this file/directory:*

`sudo vi /lib/systemd/system/moodleWatchdog.service`

```
** File Start **

[Unit]
Description=moodleWatchdog
Documentation=On Github
After=network.target

[Service]
Type=simple
User=                                                      // system user name
ExecStart=/usr/bin/node /home/watchdog/watchdog-main.js    // plugin and main script location
WorkingDirectory=/home/watchdog/                           // has to be the folder of the main script
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
