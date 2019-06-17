#/bin/bash

mkdir ~/.ssh || true
echo "${SSH_KEY}" > ~/.ssh/id_rsa
chmod 700 ~/.ssh/id_rsa
echo '|1|8tYwrIw/csnntllGSol/xexzzv4=|MViHCeSKmWBN8xx2gu5yMdtEIus= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|WiU5b2UFMrcNDpI9ZTNoMSt01gg=|T4y8PCoy8c6d3KGHJ9POPO4CPjY= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
'>~/.ssh/known_hosts
git config --global user.name sWIm-crm
git config --global user.email sWIm-crm@protonmail.com

sleep 20
while ! mysqladmin ping -h mariadb -u root -p"${MARIADB_PASSWORD}" --silent; do
	sleep 10
	echo Waiting for database server to start...
done

mysql -h mariadb -u root -p"${MARIADB_PASSWORD}" -e "CREATE DATABASE vtiger_crm"
mysql -h mariadb -u root -p"${MARIADB_PASSWORD}" vtiger_crm < /db_backup/mastercrm-vtiger/backup.sql


cd /var/www/html/mastercrm-vtiger
echo "<?php \$dbpass = '${MARIADB_PASSWORD}'; ?>" > db_pass.php
echo "<?php \$site_URL = '${HOSTNAME}'; ?>" > hostname.php
apache2-foreground & while true
do
	for i in {1..30}
	do
		chmod -R a+wx .
		sleep 1m
		git pull
	done

	if [ -z "${SSH_KEY}" ]; then
		echo "[Warning] SSH key not set: not backing up."
	else
		git remote set-url origin "${BACKUP_GIT_REPO_URL}"
		git add .
		git commit -m "Config backup"
		git push
		cd /db_backup/mastercrm-vtiger
		git remote set-url origin "${BACKUP_GIT_REPO_URL}"
		git pull
		mysqldump -h mariadb -u root -p"${MARIADB_PASSWORD}" vtiger_crm > /db_backup/mastercrm-vtiger/backup.sql
		git add .
		git commit -m "Database backup"
		git push
		cd /var/www/html/mastercrm-vtiger
	fi
done 
