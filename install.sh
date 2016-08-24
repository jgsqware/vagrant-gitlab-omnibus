#!/bin/sh

sudo apt-get -y install curl openssh-server ca-certificates postfix git

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install -y gitlab-ce

if [ -d "/opt/gitlab/embedded/cookbooks/gitlab" ]; then
    sudo mv /opt/gitlab/embedded/cookbooks/gitlab /opt/gitlab/embedded/cookbooks/gitlab.$(date +%s)
fi

sudo ln -fs /vagrant/omnibus-gitlab/files/gitlab-cookbooks/gitlab /opt/gitlab/embedded/cookbooks/gitlab