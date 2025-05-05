terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "homelab/tofu-cluster-cni.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = {
      s3 = "https://dcfa5af67bebf90c53f37a36690b8858.eu.r2.cloudflarestorage.com"
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "kubectl" {
  load_config_file = true
}

data "http" "gateway_classes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml"
}
data "http" "gateways" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml"
}
data "http" "http_routes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml"
}
data "http" "reference_grants" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml"
}
data "http" "grcp_routes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml"
}
data "http" "tls_routes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
}

resource "kubectl_manifest" "add_gateway_classes" {
  yaml_body = data.http.gateway_classes.body
}
resource "kubectl_manifest" "add_gateways" {
  yaml_body = data.http.gateways.body
}
resource "kubectl_manifest" "add_http_routes" {
  yaml_body = data.http.http_routes.body
}
resource "kubectl_manifest" "add_reference_grants" {
  yaml_body = data.http.reference_grants.body
}
resource "kubectl_manifest" "grcp_routes" {
  yaml_body = data.http.grcp_routes.body
}
resource "kubectl_manifest" "tls_routes" {
  yaml_body = data.http.tls_routes.body
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  namespace  = "kube-system"
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "kubeProxyReplacement"
    value = true
  }
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }
  set {
    name  = "cgroup.autoMount.enabled"
    value = false
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }
  set {
    name  = "k8sServiceHost"
    value = "localhost"
  }
  set {
    name  = "k8sServicePort"
    value = 7445
  }
  set {
    name  = "gatewayAPI.enabled"
    value = true
  }
  set {
    name  = "gatewayAPI.enableAlpn"
    value = true
  }
  set {
    name  = "gatewayAPI.enableAppProtocol"
    value = true
  }
}
