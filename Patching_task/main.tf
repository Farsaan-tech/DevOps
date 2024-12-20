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
