provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "patching" {
  key_name   = "patching"
  public_key = file("C:/Users/syedf/Desktop/DevOps/Patching_task/patching_key.pub")
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-00eb69d236edcfaf8"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.patching.key_name
  associate_public_ip_address = true
  tags = {
    Name = "jenkins_server"
  }

user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              set -e

              # Update package list
              sudo apt-get update -y

              # Install OpenJDK 17
              sudo apt-get install -y openjdk-17-jdk

              # Add Jenkins repository key
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key

              # Add Jenkins repository
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

              # Update package list again
              sudo apt-get update -y

              # Install fontconfig, Jenkins
              sudo apt-get install -y fontconfig jenkins

              # Start and enable Jenkins service
              sudo systemctl start jenkins
              sudo systemctl enable jenkins

EOF



}


resource "aws_instance" "ansible" {
  ami                         = "ami-00eb69d236edcfaf8"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.patching.key_name
  associate_public_ip_address = true
  tags = {
    Name = "ansible_server"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y ansible
              EOF
}

output "ansible_server_public_ip" {
  value = aws_instance.ansible.public_ip
}

output "jenkins_server_public_ip" {
  value = aws_instance.jenkins.public_ip
}
