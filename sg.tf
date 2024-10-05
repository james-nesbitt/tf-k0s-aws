locals {

  // standard firewall rules [here we just leave it open until we can figure this out]
  k0s_securitygroups = {
    "controller" = {
      description = "Common security group for controller nodes"
      nodegroups  = [for n, ng in var.nodegroups : n if ng.role == "controller"]
      ingress_ipv4 = [
        {
          description : "Allow https traffic from anywhere for kube api server"
          from_port : 6443
          to_port : 6443
          protocol : "tcp"
          self : false
          cidr_blocks : ["0.0.0.0/0"]
        },
      ]
    }
  }
  
  common_security_groups = {
    "permissive" = {
      description = "Common SG for all cluster machines"
      nodegroups  = [for n, ng in var.nodegroups : n]
      ingress_ipv4 = [
        {
          description : "Permissive internal traffic [BAD RULE]"
          from_port : 0
          to_port : 0
          protocol : "-1"
          self : true
          cidr_blocks : []
        },
      ]
      egress_ipv4 = [
        {
          description : "Permissive outgoing traffic"
          from_port : 0
          to_port : 0
          protocol : "-1"
          cidr_blocks : ["0.0.0.0/0"]
          self : false
        }
      ]
    }

    "ssh" = {
      description = "Security for group for openning ssh port"
      nodegroups  = [for n, ng in local.nodegroups_wplatform : n if ng.platform == ""] # platform attribute is empty for linux in aws_ami data source
      ingress_ipv4 = [
        {
          description : "Allow ssh traffic from anywhere"
          from_port : 22
          to_port : 22
          protocol : "tcp"
          self : false
          cidr_blocks : ["0.0.0.0/0"]
        },
      ]
    }
  }

}
