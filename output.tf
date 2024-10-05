
// The host ssh information
// Primarily used if you need ssh info externally (e.g. for ansible)
output "hosts_ssh" {
  description = "Host connection by ssh"
  value     = local.hosts_ssh
  sensitive = true
}

// Use this to serve any TF kube/helm context
// Primarily used if you use remotestate in another chart
output "kube_connect" {
  description = "parametrized config for kubernetes/helm provider configuration"
  sensitive   = true
  value = {
    host               = k0sctl_config.cluster.kube_host
    client_certificate = k0sctl_config.cluster.client_cert
    client_key         = k0sctl_config.cluster.private_key
    ca_certificate     = k0sctl_config.cluster.ca_cert
    tlsverifydisable   = k0sctl_config.cluster.kube_skiptlsverify
  }
}

// These could be usefull, but are more for debugging
// We are creating k0s/kube contexts in TF, so these
// serve no real function.

output "kube_yaml" {
  description = "kubernetes config file yaml (for debugging)"
  sensitive   = true
  value       = k0sctl_config.cluster.kube_yaml
}

output "k0sctl_yaml" {
  description = "k0sctl config file yaml (for debugging)"
  sensitive   = true
  value       = k0sctl_config.cluster.k0s_yaml
}

// Below outputs are more for debugging than function
// as they only make sense from the perpective of the
// provision module.

output "nodes" {
  description = "Nodegroups with node lists"
  value       = local.nodegroups
  sensitive   = true
}

output "ingresses" {
  description = "Ingresses with dns information"
  value       = local.ingresses
}

output "platforms" {
  description = "Platforms used in the stack"
  value       = local.platforms_with_ami
  sensitive   = true
}
