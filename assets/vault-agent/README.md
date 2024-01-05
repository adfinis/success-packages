# Vault Agent

1. Fill the `vault-token` file with your Vault token.
2. Start the vault-agent using `vault agent -config=vault-agent-config.hcl`

You should see:

- `application.creds` file created with the credentials obtained from Vault.

Once you change the secret in Vault, the file will be updated automatically. You should see:

- `rotated.txt` fill with a date and time of the last rotation.
