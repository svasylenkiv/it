#!/bin/bash
CASEGLIDE_ROOT=/var/www/caseglide
CASEGLIDE_LOG=/var/www/logs/
CASEGLIDE_ERROR_PAGES=/var/www/error_pages
HOSTNAME="${env}-Unified"
sudo hostnamectl set-hostname $HOSTNAME
EC2_DNS=$(hostname -f)

install_dotnet_nginx() {
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sleep 10
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo wget -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/fedora/39/prod.repo
sudo yum update -y
sleep 20
sudo dnf update
sleep 20
sudo dnf install -y dotnet-sdk-9.0
sudo dnf install -y nginx
sudo systemctl start nginx.service
sudo systemctl enable nginx.service
sudo systemctl status nginx.service
}

create_caseglide_service() {
sudo mkdir -p $CASEGLIDE_ROOT
sudo mkdir -p $CASEGLIDE_LOG
sudo mkdir -p $CASEGLIDE_ERROR_PAGES
sudo useradd -m -d $CASEGLIDE_ROOT caseglide
sudo chown -R caseglide:caseglide $CASEGLIDE_ROOT
sudo chown -R caseglide:caseglide $CASEGLIDE_LOG
sudo chown -R caseglide:caseglide $CASEGLIDE_ERROR_PAGES
sudo chmod 755 $CASEGLIDE_LOG
sudo chmod 755 $CASEGLIDE_ERROR_PAGES

echo "caseglide ALL=(ALL) NOPASSWD: /bin/systemctl start caseglide.service, /bin/systemctl stop caseglide.service" | sudo tee -a /etc/sudoers.d/caseglide-caseglide
if [ $? -eq 0 ]; then
  echo "Sudoers rule added successfully."
else
  echo "Failed to add sudoers rule."
fi

cat > /etc/systemd/system/caseglide.service<<EOF
[Unit]
Description=Caseglide .NET Web API App running on Linux
After=network.target

[Service]
WorkingDirectory=$CASEGLIDE_ROOT
ExecStart=/usr/local/newrelic-dotnet-agent/run.sh /usr/bin/dotnet $CASEGLIDE_ROOT/CaseGlide.Site.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-caseglide
User=caseglide
Environment=ASPNETCORE_ENVIRONMENT=${aspnetcore_environment}
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment=CORECLR_ENABLE_PROFILING=1
Environment=CORECLR_PROFILER={8A2F8C9B-9C4A-4D38-99F3-19B28F9A01A5}
Environment=CORECLR_PROFILER_PATH=/usr/local/newrelic-netcore20-agent/libNewRelicProfiler.so
Environment=NEW_RELIC_LICENSE_KEY=${newrelic_license_key}
Environment=NEW_RELIC_APP_NAME=$HOSTNAME

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable caseglide.service
sudo systemctl start caseglide.service
}

create_dotnet_app() {
cd /tmp
sudo dotnet new webapi -o CaseGlide.Site
cd CaseGlide.Site
sudo dotnet publish -c Release
sudo cp -r /tmp/CaseGlide.Site/bin/Release/net8.0/publish/* $CASEGLIDE_ROOT
sudo chown -R caseglide:caseglide $CASEGLIDE_ROOT
sudo systemctl restart caseglide.service
}

create_nginx_config() { 
# Create proxy config
cat > /etc/nginx/proxy.conf<<EOF3
proxy_redirect          off;

proxy_set_header        Host $host;
proxy_set_header        X-Real-IP $remote_addr;
proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header        X-Forwarded-Proto $scheme;

client_max_body_size    20480m;
client_body_buffer_size 128k;

proxy_connect_timeout   180s;
proxy_send_timeout      180s;
proxy_read_timeout      180s;

proxy_buffering         off;
proxy_buffers           32 4k;
EOF3

# Create nginx config
cat > /etc/nginx/nginx.conf<<EOF2
events {
    worker_connections  1024;
}

http {
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    limit_req_zone $binary_remote_addr zone=req_per_ip:10m rate=100r/s;

    server_tokens off;
    sendfile on;

    keepalive_timeout 29;
    client_body_timeout 10;
    client_header_timeout 10;
    send_timeout 10;

    include /etc/nginx/proxy.conf;

    upstream unified_project {
        server 127.0.0.1:5000;
        keepalive 32;
    }

    server {
        listen                    80;
        server_name               $EC2_DNS.caseglidead.caseglide.com;


        location ~ ^/(async-hub|ai-chat-hub) {
            proxy_pass         http://unified_project;
            proxy_http_version 1.1;
            proxy_set_header   Upgrade    $http_upgrade;
            proxy_set_header   Connection $connection_upgrade;
            proxy_set_header   Connection "";
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            include /etc/nginx/proxy.conf;
        }

        location / {
            proxy_pass http://unified_project;
            limit_req zone=req_per_ip burst=200 nodelay;
        }
        error_page 404 /custom_404.html;
        location = /custom_404.html {
        	root $CASEGLIDE_ERROR_PAGES;
                internal;
        }
        error_page 500 502 503 504 /custom_50x.html;
        location = /custom_50x.html {
        	    root $CASEGLIDE_ERROR_PAGES;
            	internal;
        }
		location /status {
				stub_status on;
				access_log off;
		}
    }
}
EOF2
}

install_infrastructure_agent_for_linux() {
sudo curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=${new_relic_api_key} NEW_RELIC_ACCOUNT_ID=2103331 /usr/local/bin/newrelic install -y
sleep 60
}

install_new_relic_dotnet_agent() {
sudo wget https://download.newrelic.com/548C16BF.gpg -O /etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic
cat << REPO | sudo tee "/etc/yum.repos.d/newrelic-dotnet-agent.repo"
[newrelic-dotnet-agent-repo]
name=New Relic .NET Core packages for Enterprise Linux
baseurl=https://yum.newrelic.com/pub/newrelic/el7/\$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic
REPO
sudo yum -y install newrelic-dotnet-agent
source /etc/profile.d/newrelic-dotnet-agent-path.sh && source /usr/local/newrelic-dotnet-agent/setenv.sh

export NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true
export NEW_RELIC_LICENSE_KEY="${newrelic_license_key}"
export NEW_RELIC_APP_NAME="$HOSTNAME"

sudo cp $CORECLR_NEWRELIC_HOME/newrelic.config $CASEGLIDE_ROOT
sudo sed -i 's/REPLACE_WITH_LICENSE_KEY/'"${newrelic_license_key}"'/g' $CASEGLIDE_ROOT/newrelic.config
sudo sed -i 's/My Application/'"$HOSTNAME"'/g' $CASEGLIDE_ROOT/newrelic.config
sudo curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=${new_relic_api_key} NEW_RELIC_ACCOUNT_ID=2103331 /usr/local/bin/newrelic install -n logs-integration -y
sleep 60
}

install_newrelic_nginx() {
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo nginx -t && sudo nginx -s reload
sudo yum install nri-nginx -y
sleep 30
sudo cp nginx-config.yml.sample nginx-config.yml
sudo cp /etc/newrelic-infra/logging.d/nginx-log.yml.example /etc/newrelic-infra/logging.d/nginx-log.yml
}

install_trend_micro_agent() {
sudo wget https://app.deepsecurity.trendmicro.com:443/software/agent/amzn2023/x86_64/agent.rpm?tenantID=116727
sudo rpm -i agent.rpm?tenantID=116727
sudo yum info ds_agent -y
sudo /opt/ds_agent/dsa_control -a dsm://agents.deepsecurity.trendmicro.com:443/ "tenantID:4592C139-D5C1-2C74-2A8C-D20A3D305BA3" "token:153BB21E-0E9A-1C6B-E50D-41070F44AD89" "policyid:4"
}

install_github_runner() {
# Download
mkdir /opt/actions-runner && cd /opt/actions-runner
curl -o actions-runner-linux-x64-2.309.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.309.0/actions-runner-linux-x64-2.309.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.309.0.tar.gz   
sudo chown -R caseglide. /opt/actions-runner

# Configure
curl --request POST 'https://api.github.com/orgs/CaseGlide/actions/runners/registration-token' --header "Authorization: token ${gh_token}" > output.txt
runner_token=$(jq -r '.token' output.txt)
#echo "gh_token = ${gh_token}"
echo "runner_token = $runner_token"
dt=$(date '+%d%m%Y_%H%M%S')
su -m caseglide -c "./config.sh --url https://github.com/CaseGlide --token $runner_token --name Runner-${github_runner_label}-$dt --labels unified-project,${github_runner_label} --unattended --replace"

cat > /etc/systemd/system/github-runner.service<<EOF4
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
User=caseglide
WorkingDirectory=/opt/actions-runner
ExecStart=/opt/actions-runner/run.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF4

sudo systemctl daemon-reload
sudo systemctl enable github-runner.service
sudo systemctl start github-runner.service
}

install_cloudwatch() {
    sudo yum install -y amazon-cloudwatch-agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux
    sudo systemctl start amazon-cloudwatch-agent
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl status amazon-cloudwatch-agent
}

main() {
    install_dotnet_nginx
    create_caseglide_service
	# create_dotnet_app
    create_nginx_config
	install_infrastructure_agent_for_linux
	install_new_relic_dotnet_agent
	install_newrelic_nginx

    install_trend_micro_agent
    install_github_runner
    install_cloudwatch

    systemctl daemon-reload
    systemctl restart nginx.service
}

main >> /tmp/unified.log 2>&1

curl -k https://$EC2_DNS/weatherforecast >> /tmp/unified_curl.log

