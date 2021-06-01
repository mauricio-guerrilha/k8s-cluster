output "masters_ips_publicos" {
  value = aws_instance.k8s-master[*].public_ip
}

output "workers_ips_publicos" {
  value = aws_instance.k8s-worker[*].public_ip
}

output "masters_ips_privados" {
  value = aws_instance.k8s-master[*].private_ip
}

output "workers_ips_privados" {
  value = aws_instance.k8s-worker[*].private_ip
}

resource "local_file" "ansible-inventory" {
  content = templatefile("./files/inventory.tpl",
  {
    first-master = aws_instance.k8s-master.0.private_ip,
    add-master1 = aws_instance.k8s-master.1.private_ip,
    add-master2 = aws_instance.k8s-master.2.private_ip,
    worker1 = aws_instance.k8s-worker.0.private_ip,
    worker2 = aws_instance.k8s-worker.1.private_ip,
    worker3 = aws_instance.k8s-worker.2.private_ip,
    infra1 = aws_instance.k8s-infra.0.private_ip,
    infra2 = aws_instance.k8s-infra.1.private_ip
  }
  )
  filename = "./files/kubernetes/inventory"
}