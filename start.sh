#!/bin/bash
docker run -d --privileged -p 111:111 -p 2049:2049 -p 4002:4002 -p 80:9000 -p 1025:1025 --name test test  
