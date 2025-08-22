#!/bin/bash

while true
    do
        #sudo is needed to write into the /var/log dir
        sudo echo "Hello systemd..." >> /var/log/dummy-service.log
        sleep 10
    done