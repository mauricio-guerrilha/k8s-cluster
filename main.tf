data "aws_ami" "oSuseTW" {
  owners = [679593333241]
  most_recent = true
  filter {
    name = "name"
    values = ["openSUSE-Tumbleweed-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "k8s-master" {
  count = var.k8s_nodes_master
  ami           = data.aws_ami.oSuseTW.id
  instance_type = var.k8s_nodes_master_type
  key_name = aws_key_pair.k8s-key.key_name
  subnet_id = aws_subnet.k8s-subnet.id
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  availability_zone = "${var.aws_region}a"
  associate_public_ip_address = "true"

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s-worker" {
  count = var.k8s_nodes_worker
  ami           = data.aws_ami.oSuseTW.id
  instance_type = var.k8s_nodes_worker_type
  key_name = aws_key_pair.k8s-key.key_name
  subnet_id = aws_subnet.k8s-subnet.id
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  availability_zone = "${var.aws_region}a"
  associate_public_ip_address = "true"

  tags = {
    Name = "k8s-worker"
  }
}

resource "aws_instance" "k8s-infra" {
  count = var.k8s_nodes_infra
  ami           = data.aws_ami.oSuseTW.id
  instance_type = var.k8s_nodes_infra_type
  key_name = aws_key_pair.k8s-key.key_name
  subnet_id = aws_subnet.k8s-subnet.id
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  availability_zone = "${var.aws_region}a"
  associate_public_ip_address = "true"

  tags = {
    Name = "k8s-infra"
  }
}

resource "local_file" "ssh-rsa-priv-key" {
  filename = "id_rsa"
  content = var.ssh_priv_key
}

resource "null_resource" "copy_role" {

  triggers = {
    trigger = 1
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.k8s-master[0].public_ip
    private_key = var.ssh_priv_key
  }

  provisioner "file" {
    source = "./files/kubernetes"
    destination = "/home/ec2-user"
  }
  
  provisioner "file" {
    source = "id_rsa"
    destination = "/home/ec2-user/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 /home/ec2-user/id_rsa",
      "sudo zypper in -y ansible",
      "cd /home/ec2-user/kubernetes && ansible-playbook -i inventory playbook.yml"
    ]
  }
}
