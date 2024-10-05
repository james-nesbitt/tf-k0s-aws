// constants
locals {

  // only hosts with these roles will be used for k0s
  k0s_roles = ["controller", "worker"]

}

locals {
  // The SAN URL for the kubernetes load balancer ingress that is for the MKE load balancer
  KUBE_URL = module.provision.ingresses["kube"].lb_dns
  
  // we should get this as an input
  // @TODO get the external-address from the KUBE_URL local
  k0s_config = <<EOT
apiVersion: k0s.k0sproject.io/v1beta1
kind: ClusterConfig
metadata:
  name: k0s
spec:
  api:
    externalAddress: ${local.KUBE_URL}
  controllerManager: {}
  extensions:
    helm:
      concurrencyLevel: 5
      charts: null
      repositories: null
    storage:
      create_default_storage_class: false
      type: external_storage
  installConfig:
    users:
      etcdUser: etcd
      kineUser: kube-apiserver
      konnectivityUser: konnectivity-server
      kubeAPIserverUser: kube-apiserver
      kubeSchedulerUser: kube-scheduler
EOT

  // flatten nodegroups into a set of objects with the info needed for each node, by combining the group details with the node detains
  hosts_ssh = tolist(concat([for k, ng in local.nodegroups : [for l, ngn in ng.nodes : {
    label : ngn.label
    role : ng.role

    address : ngn.public_address

    ssh_address : ngn.public_ip
    ssh_user : ng.ssh_user
    ssh_port : ng.ssh_port
    ssh_key_path : abspath(local_sensitive_file.ssh_private_key.filename)
  } if contains(local.k0s_roles, ng.role) && ng.connection == "ssh"]]...)) // filter for ssh hosts with recognized roles

}

// k0sctl install from provisioned cluster
resource "k0sctl_config" "cluster" {
  # Tell the k0s provider to not bother installing/uninstalling
  skip_destroy = var.k0sctl.skip_destroy
  skip_create  = var.k0sctl.skip_create

  metadata {
    name = var.name
  }

  spec {
    // ssh hosts
    dynamic "host" {
      for_each = nonsensitive(local.hosts_ssh)

      content {
        role = host.value.role
        ssh {
          address  = host.value.ssh_address
          user     = host.value.ssh_user
          port     = host.value.ssh_port
          key_path = host.value.ssh_key_path
        }
      }
    }

    # K0s configuration
    k0s {
      version = var.k0sctl.version
      config  = local.k0s_config
    } // k0s

  } // spec
}
