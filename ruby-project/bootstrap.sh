# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

if [ ! -f /var/lock/provision.lock ]; then
  echo adding swap file
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >> /etc/fstab

  echo updating package information
  apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
  apt-get -y update >/dev/null 2>&1

  install Ruby ruby2.3 ruby2.3-dev
  update-alternatives --set ruby /usr/bin/ruby2.3 >/dev/null 2>&1
  update-alternatives --set gem /usr/bin/gem2.3 >/dev/null 2>&1

  echo installing Bundler


  #required packages
  gem install bundler -N >/dev/null 2>&1
  install SQLite sqlite3 libsqlite3-dev
  install Rails rails
  install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
  install 'Blade dependencies' libncurses5-dev
  install 'ExecJS runtime' nodejs

  #optional ruby development packages
#   install 'development tools' build-essential
#   install Git git
#   install memcached memcached
#   install Redis redis-server
#   install RabbitMQ rabbitmq-server
#
#   install PostgreSQL postgresql postgresql-contrib libpq-dev
#   sudo -u postgres createuser --superuser vagrant
#   sudo -u postgres createdb -O vagrant activerecord_unittest
#   sudo -u postgres createdb -O vagrant activerecord_unittest2
#
#   debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
#   debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
#   install MySQL mysql-server libmysqlclient-dev
#   mysql -uroot -proot <<EOL
# CREATE USER 'rails'@'localhost';
# CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
# CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
# GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
# GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
# GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
# EOL

  # Needed for docs generation.
  update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

  echo loading Ruby Service
  mkdir -p /etc/ruby-on-rails-vagrant
  cat > /etc/ruby-on-rails-vagrant/launch.sh <<EOL
#!/bin/sh -

while [ ! -f /vagrant/bin/rails ]
do
    sleep 1
done

cd /vagrant
source ./setup-env.sh
ruby ./bin/rails server --binding=0.0.0.0
EOL

  chmod +x /etc/ruby-on-rails-vagrant/launch.sh

  cat > /etc/systemd/system/ruby.service <<EOL
[Units]
Description="ruby on rails daemon"
After=network.target

[Service]
Type=simple
ExecStart =/bin/sh -c 'exec /etc/ruby-on-rails-vagrant/launch.sh'

[Install]
WantedBy=default.target
EOL

  touch /var/lock/provision.lock

fi

cd /vagrant

echo installing bundle
bundle install

echo starting ruby service
systemctl daemon-reload
systemctl start ruby.service

echo setting up heroku
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
heroku --version

echo 'You will need to finish the heroku install by logging in and adding your ssh keys'
echo 'heroku login'
echo 'heroku keys:add'

echo 'all set, rock on!'
