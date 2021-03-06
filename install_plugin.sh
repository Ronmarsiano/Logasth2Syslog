
#! /usr/local/bin/python3

echo "Try to update\\install ruby"

sudo apt  install ruby

echo "Remove old gem file"

sudo rm syslog-sentinel-1.0.0.gem

echo "Pulling data from github"

git pull 

echo "Building new logstash plugin"

gem build syslog-sentinel.gemspec

cwd=$(pwd)

cd /usr/share/logstash

echo "Remove old plugin"

sudo /usr/share/logstash/bin/logstash-plugin remove syslog-sentinel
sudo /usr/share/logstash/bin/logstash-plugin remove logstash-output-azure-loganalytics


cd ${cwd}

echo "Install new plugin"

sudo /usr/share/logstash/bin/logstash-plugin install syslog-sentinel-1.0.0.gem

echo "Done"

sudo /usr/share/logstash/bin/logstash -f  /etc/logstash/logstash-syslog.conf --path.settings /etc/logstash/




