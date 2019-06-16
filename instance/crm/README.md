MasterCRM infrastructure guide
==============================

## Git repositories

### List of git repositories

There are three git repositories associated with the project:
1. The infrastructure git repository, which you are looking at right now
2. The master repository, containing the base code for the project (this should contain the code on the master branch, and optionally a database backup to be replicated on the `db_backup` branch)
3. The backup repository, where all the code changes and database backups are committed (this MUST contain a master branch for the code and a `db_backup` branch for database replication)

### Repository configurations

With these git repositories three possible configurations exist:
1. The master configuration, where the master repository and the backup repository are identical. This ought to be used for production instances to prevent data loss and enable a quick recovery in case of system failure
2. The slave configuration, where the master repository differs from the backup repository. This is not recommended for production installations, as the master repository _will_ override all data in the slave on every restart, should it have a database backup.
3. The development configuration, where only a master repository is set. This means that the data from the master repository _will_ be replicated onto the host on every restart, and any changes the host makes _will not_ be retained off-site. This makes this configuration ideal for development.

## Local setup

The local setup is designed for local development environments. It has sensible defaults for local development, and does not replicate data anywhere. It will instead reset the contents of the database to what is on the cloned git repository on every restart.

Prerequisites: `docker` and `docker-compose`
1. Clone this repo
2. Run `$ start_crm.sh`
3. Wait for a few minutes
4. The CRM installation should be accessable on 127.0.0.1/mastercrm-vtiger/index.php

## Production setup

The production setup differs from the local setup in that it creates backups to a specified git repository of the vtigercrm folder as well as the database.

*Warning, do not attempt to run more than one production instance against the same git repository at the same time.* Otherwise they _will_ run into merge conflicts, and you are going to have a very bad time.

Prerequisites: `docker`, `docker-compose` and a git repository
1. Clone this repo
2. Configure your instance (see below)
3. Run `$ start_crm.sh`
4. Wait a few minutes
5. The CRM installation should be accessable on the configured URL, and replicating to the git repository

## Configuring the installation

The `start_crm.sh` file contains all the parameters that may be tweaked on the instance. You can change them as you see fit to achieve an optimal result. These environment variables may also be set manually from the shell, the `start_crm.sh` script is just a convenience feature. An explanation of the environment variables is as follows:

SWIM_CRM_CLONE_GIT_REPO_URL specifies the master repository URL (default: 'https://github.com/DHBW-sWIm/mastercrm-vtiger.git')
SWIM_CRM_BACKUP_GIT_REPO_URL specifies the backup repository URL (default: 'git@github.com:DHBW-sWIm/mastercrm-vtiger.git')
SWIM_CRM_BACKUP_GIT_REPO_SSH_KEY specifies the backup repository SSH key (default: '')
SWIM_CRM_MARIADB_PASSWORD specifies the database password *change this for production* (default: 'A very secure database password')
SWIM_CRM_HOSTNAME specifies the host name of the server (default: 'http://127.0.0.1')
