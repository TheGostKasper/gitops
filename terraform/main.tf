

terraform {
  required_version = ">= 0.12.26"
}

resource "kubernetes_service_account" "example" {
  metadata {
    name = "my-service-account"
  }

  automount_service_account_token = true
  
  secret {
    name = "${kubernetes_secret.example.metadata.0.name}"
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "my-secret"
  }
}
