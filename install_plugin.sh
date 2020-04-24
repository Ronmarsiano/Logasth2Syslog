
#! /usr/local/bin/python3

echo "Try to update\\install ruby"

sudo apt  install ruby

echo "Remove old gem file"

sudo rm foo-1.0.0.gem

echo "Pulling data from github"

git pull 

echo "Building new logstash plugin"

gem build foo.gemspec

cwd=$(pwd)

cd /usr/share/logstash

echo "Remove old plugin"

sudo /usr/share/logstash/bin/logstash-plugin remove foo

cd ${cwd}

echo "Install new plugin"

sudo /usr/share/logstash/bin/logstash-plugin install foo-1.0.0.gem

echo "Done"

sudo /usr/share/logstash/bin/logstash -f  /etc/logstash/logstash-syslog.conf --path.settings /etc/logstash/




