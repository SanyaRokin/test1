terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
resource "aws_instance" "server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.xlarge"
  key_name = "id_rsa"
  vpc_security_group_ids = ["${aws_security_group.allow_traffic.id}"]
  tags = {
    Name = "Server"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt install docker.io -y",
      "sudo docker pull jetbrains/teamcity-server",
      "sudo docker run -u 0 -d --name teamcity-server-instance -v /opt/docker/teamCity/teamcity_server/datadir:/data/teamcity_server/datadir -v /opt/docker/teamCity/teamcity_server/logs:/opt/teamcity/logs -p 9111:8111 jetbrains/teamcity-server"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("/tmp/id_rsa.pem")}"
      host        = self.public_ip
    }
  }
}
resource "aws_instance" "agent" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.xlarge"
  key_name = "id_rsa"
  vpc_security_group_ids = ["${aws_security_group.allow_traffic.id}"]
  tags = {
    Name = "Agent"
  }
  depends_on = [aws_instance.server]
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt install unzip && sudo apt install default-jdk -y && sudo apt-get install git-core -y"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("/tmp/id_rsa.pem")}"
      host        = aws_instance.agent.public_ip
    }
  }
}

resource "aws_instance" "git" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  key_name = "id_rsa"
  vpc_security_group_ids = ["${aws_security_group.allow_traffic.id}"]
  tags = {
    Name = "Git"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt-get install git-core -y",
      "mkdir -p /tmp/project-1.git && cd /tmp/project-1.git"
      "git init --bare"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("/tmp/id_rsa.pem")}"
      host        = aws_instance.agent.public_ip
    }
  }

}

resource "aws_security_group" "allow_traffic" {
  name = "allow_traffic"
  description = "Allow all traffic"
  ingress {
    description = "All"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "server-ip" {
    value = aws_instance.server.public_ip
}
output "agent-ip" {
    value = aws_instance.agent.public_ip
}
output "git-ip" {
    value = aws_instance.git.public_ip
}
