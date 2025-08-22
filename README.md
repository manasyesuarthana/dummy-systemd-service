# Dummy Systemd Service
This project involves creating a dummy systemd service that we can start, stop, enable, and disable. For this scenario, this service will output a statement and logs it into a file in `/var/log`.

This README.md will lay out the steps on how I achieved this and how the reader can do the same. 

This project is a part of the roadmap.sh DevOps project series, specifically [Dummy Systemd Service](https://roadmap.sh/projects/dummy-systemd-service)

## Steps for Completion

### 1. Create Service Script
Write a shell script for the dummy service. Mine will be similar to the one given in the project guidelines, which is the output a statement and output it into a file in `/var/log` for every 10 seconds. 

**dummy.sh**:
```bash
#!/bin/bash

while true
    do
        #sudo is needed to write into the /var/log dir
        sudo echo "Hello systemd..." >> /var/log/dummy-service.log
        sleep 10
    done
```
In the script above, the statement is `Hello systemd...` into `/var/log/dummy-service.log`. This line requires sudo because writing into the `/var/log` directory requires root privileges.

### 2. Create a .service file
The service name will by dummy, so the service will be called `dummy.service`. 

**dummy.service**:
```
[Unit]
Description=Systemd Dummy Service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root # used to run sudo, not good in prod environments however :v
ExecStart=/path/to/dummy.sh # modify this to your script location

[Install]
WantedBy=multi-user.target
```
The service file is divided into three sections: `Unit`, `Service`, and `Install`. You can read more about it in the **systemd manual**: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html

Let us break down what each line does:

**Unit**
- `Description`: A short description for the service. 
- `After=network.target`: Will run the system after the network is ready.

**Service:**
- `Type`: The type of service. In this case, it is **simple**, meaning that it is a normal, simple service that runs in the background.
- `Restart`: Will tell whether or not the system should restart the service whenever it fails.
- `RestartSec`: The amount of time (in seconds) the system will wait before restarting the service. 
- `User`: This is the user that will be running the service.
- `ExecStart`: This is the script that will be run by the service.

**Install:**
- `WantedBy=multi-user.target`: States that the system should treat the service as part of the normal, non-graphical, multi-user system startup, allowing us to run `systemctl enable`.

### 3. Setup the service
Move the `dummy.service` file into `/etc/systemd/service`.
```bash
mv ./dummy.service /etc/systemd/system/
```

The service is now ready to be used. The next section will tell you how you can set this up after cloning this repo.

## Getting Started
1. Clone the repository
```bash
git clone https://github.com/manasyesuarthana/dummy-systemd-service.git
```
2. Edit the dummy.service file, replace the ExecStart line with the script location
```
ExecStart=/path/to/dummy-systemd-service/dummy.sh
```

3. Give execute permissions to the dummy.sh file
```bash
chmod 500 ./dummy-systemd-service/dummy.sh
```

3. Move `dummy.service` into `/etc/systemd/system`
```bash
mv ./dummy-systemd-service/dummy.service /etc/systemd/system/
```


## Interacting with the service
1. Seeing the status of the service:
```
$ sudo systemctl status dummy
○ dummy.service - Systemd Dummy Service
     Loaded: loaded (/etc/systemd/system/dummy.service; disabled; preset: enabled)
     Active: inactive (dead)
```

2. Starting the service:
```
$ sudo systemctl start dummy
$ sudo systemctl status dummy
● dummy.service - Systemd Dummy Service
     Loaded: loaded (/etc/systemd/system/dummy.service; disabled; preset: enabled)
     Active: active (running) since Fri 2025-08-22 20:31:32 WITA; 3s ago
   Main PID: 1635 (dummy.sh)
      Tasks: 2 (limit: 9339)
     Memory: 624.0K (peak: 2.3M)
        CPU: 19ms
     CGroup: /system.slice/dummy.service
             ├─1635 /bin/bash /home/path/to/dummy.sh
             └─1638 sleep 10

```

- Output logs:
```
$ cat /var/log/dummy-service.log
Hello systemd...
Hello systemd...
Hello systemd...
Hello systemd...
Hello systemd...
Hello systemd...
Hello systemd...
```

3. Enabling the Service:
```
$ sudo systemctl enable dummy
Created symlink /etc/systemd/system/multi-user.target.wants/dummy.service → /etc/systemd/system/dummy.service.
```

4. Stopping the service:
```
$ sudo systemctl stop dummy
$ sudo systemctl status dummy
○ dummy.service - Systemd Dummy Service
     Loaded: loaded (/etc/systemd/system/dummy.service; enabled; preset: enabled)
     Active: inactive (dead) since Fri 2025-08-22 20:39:21 WITA; 5s ago
   Duration: 7min 48.573s
    Process: 1635 ExecStart=/path/to/dummy.sh (code=killed, signal=TERM)
   Main PID: 1635 (code=killed, signal=TERM)
        CPU: 605ms
```

5. Disabling the service:
```
$ sudo systemctl disable dummy
Removed "/etc/systemd/system/multi-user.target.wants/dummy.service".
```

6. Look at the service logs:
```
$ sudo journalctl dummy
Aug 22 20:38:53 DESKTOP sudo[1821]: pam_unix(sudo:session): session closed for user root
Aug 22 20:39:03 DESKTOP sudo[1824]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/echo 'Hello systemd...'
Aug 22 20:39:03 DESKTOP sudo[1824]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=0)
Aug 22 20:39:03 DESKTOP sudo[1824]: pam_unix(sudo:session): session closed for user root
Aug 22 20:39:13 DESKTOP sudo[1827]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/echo 'Hello systemd...'
Aug 22 20:39:13 DESKTOP sudo[1827]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=0)
Aug 22 20:39:13 DESKTOP sudo[1827]: pam_unix(sudo:session): session closed for user root
Aug 22 20:39:21 DESKTOP systemd[1]: Stopping dummy.service - Systemd Dummy Service...
Aug 22 20:39:21 DESKTOP systemd[1]: dummy.service: Deactivated successfully.
Aug 22 20:39:21 DESKTOP systemd[1]: Stopped dummy.service - Systemd Dummy Service.
```