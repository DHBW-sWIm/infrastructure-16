# Watchdog
This repository contains the script that is sending automatic notifications when a service is down

## Control Flow

First the start method is called, which calls the start up method once and the mainLoop method periodically. 

The startup sets the nodeMailer transporter and the initial mailOptions.

The main loop runs the checkHost method for each host object in the hosts array. 

The checkHost method creates a TCP socket and checks if it can establish connection with a timeout of 5000 ms with a host. If it is successfull the lastState is set to true, in every other case the handleError method is called with the host and the error parameters.

The handleError method checks if the lastState was true, if so a log file is created and a mail is sent, else nothing happenes. If there is an error with creating log files or sending emails, the log is written to the console.


## Config

There are 3 config options: transporterOptions, mailOptions and hosts.

In the transporterOptions one can set the mail server settings (host, port, secure) and the authorization data, which involves user and pass.

In the mailOptions one can set the From and To email addresses, for the notifications.

In the hosts array one can create host objects which describe: a name (for identification purposes), host (for the connection address), port, lastState (for logic purposes initial true).

## Server setup

The repository should be downloaded to `/home/watchdog/` folder.

Then configure the system deamon as described in the `watchdog_deamonCFG` file.

To start the service type:

```
sudo systemctl daemon-reload
sudo systemctl start moodleWatchdog
```

Other commands to interact with the service:

```
sudo systemctl start moodleWatchdog                                    // start service
sudo systemctl stop moodleWatchdog                                     // stop service
sudo systemctl restart moodleWatchdog                                  // restart service (has to be done after the code is changed)
sudo systemctl status moodleWatchdog                                   // short status of the service
sudo journalctl -u moodleWatchdog --since "2019-02-07 09:20:00"        // complete service log since the date
```
