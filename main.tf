variable "image" {}
variable "name" {}
variable "public_key" {}

resource "random_id" "pod" {
  byte_length = 8
}

resource "kubernetes_secret" "public-key-secret" {
  metadata {
    name = "${var.name}-${random_id.pod.hex}-secret"
    labels = {
      "pod.hobbyfarm.io/name" = "${var.name}-${random_id.pod.hex}"
    }
  }

  data = {
    public_key = var.public_key
  }
}

resource "kubernetes_pod" "pod" {
  metadata {
    name = "${var.name}-${random_id.pod.hex}"
    labels = {
      "pod.hobbyfarm.io/name" = "${var.name}-${random_id.pod.hex}" 
    }
  }

  spec {
    container {
      image = var.image
      name = var.name
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
        secret_name = kubernetes_secret.public-key-secret.metadata[0].name
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
    generate_name = "${var.name}-${random_id.pod.hex}-service"
  }

  spec {
    selector = {
      "pod.hobbyfarm.io/name" = "${var.name}-${random_id.pod.hex}"
    }

    port {
      port = 22
      target_port = 22
    }

    type = "ClusterIP"

  }
}
output "private_ip" {
  value = kubernetes_service.pod-service.spec[0].cluster_ip
}

output "public_ip" {
  value = kubernetes_service.pod-service.spec[0].cluster_ip
}

output "hostname" {
  value = kubernetes_service.pod-service.spec[0].cluster_ip
}
