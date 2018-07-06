# stop moodle
docker-compose -f moodle.yml stop

# restart moodle
docker-compose -f moodle.yml up -d

# make sure the link is existent
docker exec -ti swim-moodle chown root:root /bitnami/moodle-config.php
docker exec -ti swim-moodle ln -sf /bitnami/moodle-config.php /opt/bitnami/moodle/config.php
