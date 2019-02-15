#!/bin/bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ -z `echo $2 | grep -oE '([0-9]*|\-r)'` ] || [ -z `echo $1 | sed 's/[^a-z1-9A-Z]*//g'` ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] 
then
	echo "Usage: $0 [-h] NAME [<port> | -r]"
	echo 'Arguments:'
	echo '-h     | Show this message'
	echo 'NAME   | Name of the project, will drop spaces and special characters'
	echo '<port> | Base port. ${port + 0} is Moodle, ${port + 1} is Camunda, ${port + 2} is Adminer, ${port + 3} is Mailhog.'
	echo '-r     | Remove the given instance'
	exit
fi

export PROCESS_NAME=`echo $1 | sed 's/[^a-z1-9A-Z]*//g'`
export PROCESS_PORT_MOODLE=`echo $2 | grep -o '[0-9]*'`

export PROCESS_PORT_CAMUNDA=$((${PROCESS_PORT_MOODLE} + 1))
export PROCESS_PORT_ADMINER=$((${PROCESS_PORT_MOODLE} + 2))
export PROCESS_PORT_MAILHOG=$((${PROCESS_PORT_MOODLE} + 3))

if docker ps -a | grep -qo swim_${PROCESS_NAME}_ && [ -z `echo $2 | grep -o '\-r'` ] && [ -z `echo $3 | grep -o '\-y'` ]
then
	echo "A process of the same name already exists. Do you wish to erase all data and re-create it? (y/n)"
	read res
	if [ "$res" != "y" ]
	then
		exit
	fi
fi

echo "Stopping possible running docker containers for project..."
docker ps -a | grep -q swim_${PROCESS_NAME}_ && docker stop `docker ps -a | grep swim_${PROCESS_NAME}_ | grep -o ^[a-z0-9]*`
echo "done"
echo "Removing existing docker containers for project..."
docker ps -a | grep -q swim_${PROCESS_NAME}_ && docker rm -v `docker ps -a | grep swim_${PROCESS_NAME}_ | grep -o ^[a-z0-9]*`
echo "done"
echo "Removing lingering persistent volumes for project..."
docker volume ls | grep -oq "swim${PROCESS_NAME}_.*$" && docker volume rm `docker volume ls | grep -o "swim${PROCESS_NAME}_.*$"`
echo "done"

echo $2 | grep -q '\-r' || docker-compose -p swim_${PROCESS_NAME} -f moodle-compose.yml up --force-recreate -d
