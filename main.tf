variable "image" {
  type = "string"
}
variable "name" {
  type = "string"
}
variable "public_key" {
  type = "string"
}

provider "kubernetes" {
  load_config_file = false
  host     = "https://10.43.0.1"
  token    = "${file("/var/run/secrets/kubernetes.io/serviceaccount/token")}"
  cluster_ca_certificate = "${file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")}"
}

locals {
  pod_id = "${var.name}"
  namespace = "${file("/var/run/secrets/kubernetes.io/serviceaccount/namespace")}"
}

resource "kubernetes_secret" "public-key-secret" {
  metadata {
    name = "pod-${local.pod_id}-secret"
    namespace = "${local.namespace}"
    labels = {
      "field.hobbyfarm.io/pod" = "${local.pod_id}"
    }
  }

  data = {
    public_key = "${var.public_key}"
  }
}

resource "kubernetes_pod" "pod" {
  metadata {
    name = "pod-${var.name}"
    namespace = "${local.namespace}"
    labels = {
      "field.hobbyfarm.io/pod" = "${local.pod_id}"
    }
  }

  spec {
    container {
      image = "${var.image}"
      name = "${var.name}"
      stdin = true
      tty = true
      port {
        name = "ssh"
        container_port = 22
      }

      volume_mount {
        name = "ssh-secret"
        mount_path = "/root/.ssh"
        read_only = true
      }
    }
    volume {
      name = "ssh-secret"
      secret {
        secret_name = "${kubernetes_secret.public-key-secret.metadata.0.name}"
        items {
          key = "public_key"
          path = "authorized_keys"
        }
      }
    }
  }
}

resource "kubernetes_service" "pod-service" {
  metadata {
    name = "service-${local.pod_id}"
    namespace = "${local.namespace}"
  }

  spec {
    selector {
      "field.hobbyfarm.io/pod" = "${local.pod_id}"
    }

    port {
      port = 22
      target_port = 22
    }

    type = "ClusterIP"

  }
}

output "private_ip" {
  value = "${kubernetes_service.pod-service.spec.0.cluster_ip}"
}

output "public_ip" {
  value = "${kubernetes_service.pod-service.spec.0.cluster_ip}"
}

output "hostname" {
  value = "${kubernetes_service.pod-service.spec.0.cluster_ip}"
}
