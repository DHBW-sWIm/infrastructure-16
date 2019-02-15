#!/bin/bash
docker start $(docker ps -a | grep swim | grep -o '^[a-z0-9]*')

