#!/bin/bash

sudo apt-get update
sudo apt-get install -y php php-cli php-pgsql cron php-curl

# Crear un archivo de cron job
CRON_JOB="* * * * * php /home/vagrant/collector/index.php"
(crontab -l ; echo "$CRON_JOB") | crontab -


cat <<EOF | sudo tee /etc/cron.d/collector
* * * * * /usr/bin/php /home/vagrant/collector/index.php >> /home/vagrant/collector/collector.log 2>&1
EOF

cat <<'EOF' | sudo tee /home/vagrant/collector/collector.sh
#!/bin/bash
while true; do
    php /home/vagrant/collector/index.php
    sleep 10
done
EOF

sudo chmod +x /home/vagrant/collector/collector.sh

nohup /home/vagrant/collector/collector.sh > /home/vagrant/collector/collector.log 2>&1 &
