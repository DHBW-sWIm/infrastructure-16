#!/bin/bash

while IFS='' read p; do ./make_process.sh $(echo $p | grep -o "^[0-9a-z]*") $(echo $p | grep -o "[0-9a-z]*$") -y; done <processes.yml
