resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-key"
  public_key = var.ssh_pub_key
}