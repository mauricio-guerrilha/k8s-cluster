all:
 vars:
   kubernetes_apiserver_advertise_address: ${first-master}
   kubernetes_control_plane_endpoint: ${first-master}
   ansible_ssh_common_args: -oStrictHostKeyChecking=no
   ansible_user: ec2-user
   ansible_ssh_private_key_file: /home/ec2-user/id_rsa
 children:
   master_nodes:
     hosts:
       ${first-master}:
     vars:
       kubernetes_role: "master"
       kubernetes_pod_network.cidr: 172.30.0.0/16
   additional_master_nodes:
     hosts:
       ${add-master1}:
       ${add-master2}:
     vars:
      kubernetes_role: "add_master"
   worker_nodes:
     hosts:
       ${worker1}:
       ${worker2}:
       ${worker3}:
   infra_nodes:
      hosts:
       ${infra1}:
       ${infra2}:
