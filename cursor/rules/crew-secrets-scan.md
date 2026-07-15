<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
---
paths:
  - "**/.env*"
  - "**/*.key"
  - "**/*.pem"
  - "**/*.p12"
  - "**/*.pfx"
  - "**/secrets/**" 
  - "**/credentials/**"
  - ".github/workflows/**"
  - "**/docker-compose*.yml"
  - "**/docker-compose*.yaml"
  - "infra/**"
  - "terraform/**"
--- 

# Secrets Scan Rule

**When working with any file matching the paths above, this rule fires.**

## Core Rule

Never commit secrets to git. A secret committed and pushed is permanently compromised — git history is immutable and GitHub caches objects even after force-push cleanup. Rotate first, remove second.

## What Counts as a Secret 

- API keys, tokens, passwords, private keys
- Database connection strings with credentials
- OAuth client secrets
- Cloud provider credentials (AWS_SECRET_ACCESS_KEY, GOOGLE_APPLICATION_CREDENTIALS, etc.)
- Webhook secrets and signing keys
- JWT secrets and encryption keys 
- SSH private keys

## What Is NOT a Secret (safe to commit)

- `.env.example` / `.env.sample` files with placeholder values (e.g., `API_KEY=YOUR_KEY_HERE`)
- Public keys and certificates  
- Service account names (not the key itself)  
- Environment variable *names* without values

## Agent Behaviour When Editing These Files

1. **Before writing any value** — verify the value is a placeholder, not a real credential.
   - Real: `AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` 
   - Placeholder: `AWS_SECRET_ACCESS_KEY=<replace-with-your-key>`
2. **Never generate realistic-looking fake secrets** — scanners flag them and humans confuse them for real ones. Use obviously fake placeholders: `<YOUR_API_KEY>`, `REPLACE_ME`, `example_secret_here`. 
3. **If you find a real secret in an existing file** — stop. Flag it to the user immediately:
   > ⚠ This file appears to contain a real credential at line {N}. Do not commit. Rotate this credential and use a secrets manager or environment variable reference instead.
4. **Workflow files** — never hardcode secrets in `.github/workflows/**`. Always reference via `${{ secrets.SECRET_NAME }}`.
5. **docker-compose files** — never hardcode passwords in `environment:` blocks. Use `env_file:` pointing to a `.env` file that is gitignored.

## Secrets Management Standard

Secrets belong in one of:
- **Environment variables** — injected at runtime, never in source
- **Secret manager** — AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager, Azure Key Vault 
- **CI/CD secrets store** — GitHub Actions `secrets.*`, GitLab CI variables (masked) 

The `.env` file at project root is for **local development only**. Verify `.gitignore` contains `.env` before writing any real values to it.

## If a Secret Is Already Committed 

1. Rotate the credential immediately — assume compromised.
2. Reference `infra/security/secrets/secrets-policy.md` for the full incident response procedure.
3. Do not attempt to rewrite git history without reading `docs/runbooks/rollback.md` and following the break-glass procedure in `infra/security/iam/break-glass.md`. 
