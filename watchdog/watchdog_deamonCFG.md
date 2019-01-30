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
User=debian
ExecStart=/usr/bin/node /home/Infrastruktur/watchdog-main.js
WorkingDirectory=/home/Infrastruktur
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
