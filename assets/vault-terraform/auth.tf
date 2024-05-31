# Enable userpass auth method
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create a user named 'student'
resource "vault_generic_endpoint" "student" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/student"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admins"],
  "password": "changeme"
}
EOT
}
