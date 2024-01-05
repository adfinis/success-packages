pid_file = "./pidfile"

vault {
  address = "http://localhost:8200"
  retry {
    num_retries = 5
  }
}

auto_auth {
  method {
    type = "token_file"

    config = {
      token_file_path = "vault-token"
    }
  }
}

cache {
}

api_proxy {
  use_auto_auth_token = true
}

listener "tcp" {
  address     = "127.0.0.1:8100"
  tls_disable = true
}

template_config {
   static_secret_render_interval = "10s"
   exit_on_retry_failure         = true
}

template {
  source      = "application.creds.ctmpl"
  destination = "application.creds"
  command     = "date > rotated.txt"
}
