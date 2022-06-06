#cloud-config
users:
- name: composer
  uid: 2000
  groups: docker

write_files:
- path: /etc/systemd/system/composer.service
  permissions: 0644
  owner: root
  content: |
    [Unit]
    Description=Composer Service
    Requires=docker.service network-online.target
    After=docker.service network-online.target

    [Service]
    User=composer
    Environment="HOME=/home/composer/airbyte"
    ExecStart=/usr/bin/docker run --rm -v  /var/run/docker.sock:/var/run/docker.sock -v "/home/composer/airbyte/.docker:/root/.docker" -v "/home/composer/airbyte:/home/composer/airbyte" -w="/home/composer/airbyte" docker/compose:1.29.2 up
    ExecStop=/usr/bin/docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "/home/composer/airbyte/.docker:/root/.docker" -v "/home/composer/airbyte:/home/composer/airbyte" -w="/home/composer/airbyte" docker/compose:1.29.2 rm -f
    Restart=on-failure
    RestartSec=10

    [Install]
    WantedBy=multi-user.target

runcmd:
- mkdir -p /home/composer/airbyte
- cd /home/composer/airbyte
- wget https://raw.githubusercontent.com/airbytehq/airbyte/master/{.env,docker-compose.yaml}
- systemctl daemon-reload
- systemctl enable --now --no-block composer.service