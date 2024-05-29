# The best practice is to use remote state file and encrypt it since your state files may contains sensitive data (secrets)
# terraform {
#       backend "s3" {
#             bucket = "remote-terraform-state-dev"
#             encrypt = true
#             key = "terraform.tfstate"
#             region = "us-east-1"
#       }
# }

# We are a different local state location that deposits the terraform state to the tfstate directory for convenience (optional)
terraform {
  backend "local" {
    path = "tfstate/terraform.tfstate"
  }
}

# Use Vault provider
provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables:
  #    - VAULT_ADDR
  #    - VAULT_TOKEN
  #    - VAULT_CACERT
  #    - VAULT_CAPATH
  #    - etc.
  # But you can also set values within the provider block
  address = "http://127.0.0.1:8200"
}
