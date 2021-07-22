# !/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install apt install -y git-core
apt install terraform
ssh-keygen -t rsa -b 4096 -m PEM
openssl rsa -in ~/.ssh/id_rsa -outform pem > /tmp/id_rsa.pem
chmod 600 /tmpid_rsa.pem
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
terraform init
terraform plan
terrafrom apply
mkdir -p /tmp/git
cd /tmp/git/
https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
