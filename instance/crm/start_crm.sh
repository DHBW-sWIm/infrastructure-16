#!/bin/bash
export SWIM_CRM_CLONE_GIT_REPO_URL='https://github.com/DHBW-sWIm/mastercrm-vtiger.git'
export SWIM_CRM_BACKUP_GIT_REPO_URL='git@github.com:DHBW-sWIm/mastercrm-vtiger.git'
export SWIM_CRM_BACKUP_GIT_REPO_SSH_KEY=''
export SWIM_CRM_MARIADB_PASSWORD='A very secure database password'
export SWIM_CRM_HOSTNAME='http://127.0.0.1'
export SWIM_CRM_PORT='8080'
docker build -t crm_php --build-arg SWIM_CRM_CLONE_GIT_REPO_URL=${SWIM_CRM_CLONE_GIT_REPO_URL} php
docker build -t crm_db sql
docker-compose -p swim_mastercrm_vtiger up -d
