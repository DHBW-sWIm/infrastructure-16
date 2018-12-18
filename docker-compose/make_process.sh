#!/bin/bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ -z `echo $2 | grep -oE '([0-9]*|\-r)'` ] || [ -z `echo $1 | sed 's/[^a-z1-9A-Z]*//g'` ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] 
then
	echo "Usage: $0 [-h] NAME [<port> | -r]"
	echo 'Arguments:'
	echo '-h     | Show this message'
	echo 'NAME   | Name of the project, will drop spaces and special characters'
	echo '<port> | Port to expose the moodle instance on'
	echo '-r     | Remove the given instance'
	exit
fi

export MOODLE_PORT=`echo $2 | grep -o '[0-9]*'`
export PLUGIN_NAME=`echo $1 | sed 's/[^a-z1-9A-Z]*//g'`

echo "Stopping possible running docker containers for project..."
docker ps -a | grep -q swim_${PLUGIN_NAME}_ && docker stop `docker ps -a | grep swim_${PLUGIN_NAME}_ | grep -o ^[a-z0-9]*`
echo "done"
echo "Removing existing docker containers for project..."
docker ps -a | grep -q swim_${PLUGIN_NAME}_ && docker rm `docker ps -a | grep swim_${PLUGIN_NAME}_ | grep -o ^[a-z0-9]*`
echo "done"
echo "Removing lingering persistent volumes for project..."
docker volume ls | grep -oq "swim${PLUGIN_NAME}_.*$" && docker volume rm `docker volume ls | grep -o "swim${PLUGIN_NAME}_.*$"`
echo "done"

echo $2 | grep -q '\-r' || docker-compose -p swim_${PLUGIN_NAME} -f moodle-compose.yml up --force-recreate -d
