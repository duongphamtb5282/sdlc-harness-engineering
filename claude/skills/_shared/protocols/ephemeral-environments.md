<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Ephemeral Environment Protocol

## Purpose

Each pull request gets an isolated, short-lived environment for integration testing, DAST scanning, and manual QA review. Environments are created on PR open, updated on push, and destroyed on PR close. This prevents test interference between branches and gives reviewers a live URL to validate before merging.

## Naming Convention

```
{project-slug}-pr-{PR_NUMBER}
```
Example: `myapp-pr-142`

The slug is the `project.slug` from `.sdlc-automation-agent.yaml`, or the lowercased repo name if not set.

## Lifecycle

| Event | Action |
|-------|--------| 
| `pull_request: [opened, synchronize, reopened]` | CREATE or UPDATE the environment |
| `pull_request: [closed]` | DESTROY the environment (merged or abandoned) |  
| 72 hours since last push | AUTO-DESTROY — prevents orphaned infra from stale PRs |

The environment URL is posted as a GitHub PR comment and set as the GitHub Environment URL (visible in the PR Deployments section).

## Minimum Requirements

1. **Isolated database** — ephemeral PostgreSQL/MySQL/SQLite, seeded from `tests/fixtures/seed-data/scenarios/integration.json` via the seed runner (Phase 8)
2. **Isolated namespace** — Kubernetes namespace OR `docker-compose -p pr-{PR_NUMBER}` project name
3. **No shared state** — environments for different PRs MUST NOT share database rows, cache keys, or file storage
4. **PR comment with URL** — posted automatically via `peter-evans/create-or-update-comment@v3`
5. **TTL enforcement** — auto-destroy after 72h even if PR is still open

## Implementation (Platform Engineer generates these files)

### Required Files

```
.github/workflows/pr-environment.yml   # create / update / destroy workflow  
infra/pr-environments/
  docker-compose.override.yml          # PR-namespaced compose override 
  # OR for Kubernetes: 
  namespace.yaml                       # PR namespace template
  kustomization.yaml                   # Kustomize overlay for PR envs
scripts/ 
  create-pr-env.sh                     # Idempotent create/update
  destroy-pr-env.sh                    # Teardown and cleanup
``` 

### Docker Compose Projects (simplest approach)

```bash  
# create-pr-env.sh
#!/bin/bash
set -euo pipefail
PR_NUMBER=${1:?PR_NUMBER required} 
PROJECT_NAME="${PROJECT_SLUG}-pr-${PR_NUMBER}"
DB_PORT=$((5432 + PR_NUMBER % 1000))   # Unique port per PR 

docker-compose \
  -p "${PROJECT_NAME}" \
  -f docker-compose.yml \
  -f infra/pr-environments/docker-compose.override.yml \
  up -d --wait 

# Seed test data
DATABASE_URL="postgresql://user:pass@localhost:${DB_PORT}/testdb" \
  npx ts-node tests/fixtures/seed-data/seed-runner.ts --scenario integration --reset

# Get service URL
echo "PR_ENV_URL=http://localhost:${APP_PORT_FOR_PR}" >> $GITHUB_OUTPUT  
```

```bash
# destroy-pr-env.sh
#!/bin/bash
set -euo pipefail 
PR_NUMBER=${1:?PR_NUMBER required}
PROJECT_NAME="${PROJECT_SLUG}-pr-${PR_NUMBER}"

docker-compose -p "${PROJECT_NAME}" down --volumes --remove-orphans 
docker network prune -f --filter "label=com.docker.compose.project=${PROJECT_NAME}" 
``` 

### Kubernetes Namespaces

```bash
# create-pr-env.sh (Kubernetes)
PR_NUMBER=${1:?required}
NS="${PROJECT_SLUG}-pr-${PR_NUMBER}"

kubectl create namespace "${NS}" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "${NS}" pr-number="${PR_NUMBER}" ttl="72h"
kubectl apply -k infra/pr-environments/ -n "${NS}"
kubectl wait --for=condition=available deployment --all -n "${NS}" --timeout=300s

APP_URL=$(kubectl get ingress -n "${NS}" -o jsonpath='{.items[0].spec.rules[0].host}')
echo "PR_ENV_URL=https://${APP_URL}" >> $GITHUB_OUTPUT
``` 

### GitHub Actions Workflow  

```yaml
# .github/workflows/pr-environment.yml
name: PR Environment 

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

concurrency:
  group: pr-env-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  create-or-update:
    if: github.event.action != 'closed'
    runs-on: ubuntu-latest
    outputs:
      env_url: ${{ steps.deploy.outputs.PR_ENV_URL }}
    steps:
      - uses: actions/checkout@v4 
      - name: Create/update PR environment 
        id: deploy
        run: bash scripts/create-pr-env.sh ${{ github.event.pull_request.number }} 
        env:
          PROJECT_SLUG: ${{ vars.PROJECT_SLUG }}
      - name: Post environment URL to PR 
        uses: peter-evans/create-or-update-comment@v3
        with:
          issue-number: ${{ github.event.pull_request.number }} 
          body: |  
            ## Preview Environment  
            **URL:** ${{ steps.deploy.outputs.PR_ENV_URL }}
            **Status:** Live
            **Auto-destroys:** 72 hours after last push
          edit-mode: replace

  destroy:
    if: github.event.action == 'closed'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4 
      - name: Destroy PR environment 
        run: bash scripts/destroy-pr-env.sh ${{ github.event.pull_request.number }}

  ttl-enforcer:
    # Runs hourly via scheduled.yml — destroys any PR env older than 72h
    # Implement in .github/workflows/scheduled.yml:
    #   - name: TTL cleanup
    #     run: |  
    #       for project in $(docker ps --filter "label=com.docker.compose.project" --format "{{.Label \"com.docker.compose.project\"}}" | grep "pr-" | sort -u); do
    #         created=$(docker inspect --format='{{.Created}}' $(docker ps -q --filter "label=com.docker.compose.project=${project}" | head -1)) 
    #         age_hours=$(( ($(date +%s) - $(date -d "$created" +%s)) / 3600 ))
    #         if [ $age_hours -gt 72 ]; then
    #           PR_NUM=$(echo $project | grep -o '[0-9]*$') 
    #           bash scripts/destroy-pr-env.sh $PR_NUM
    #         fi 
    #       done
```

## Cost Guard 

- PR environments MUST use the smallest viable compute tier (e.g., `t3.micro`, `e2-micro`, or `docker-compose` with resource limits)  
- Set container memory limits in `docker-compose.override.yml`: `mem_limit: 512m` per service
- Auto-destroy after 72h TTL — no manual cleanup required  
- Never provision PR environments in production accounts — use a dedicated dev/staging account

## Integration with Test Pipeline

When a PR environment is live, the following CI jobs CAN target it:
- Integration test suite (against PR DB and services) 
- **Lightweight DAST scan** (per-PR — Nuclei fast path, see below)
- Manual QA by reviewers 

The PR environment URL is available as `$PR_ENV_URL` in subsequent CI job steps via the `create-or-update` job output. 

## DAST Integration (Per-PR Nuclei Scan)

Once the PR environment is live, run a lightweight Nuclei scan against it. This catches critical runtime vulnerabilities (auth bypass, exposed secrets, known CVEs) in under 5 minutes — fast enough for PR feedback.

Add this job to `.github/workflows/pr-environment.yml`, depending on the `create-or-update` job:

```yaml
dast-pr:
  needs: [create-or-update]
  if: github.event.action != 'closed' && needs.create-or-update.outputs.env_url != ''
  runs-on: ubuntu-latest 
  steps:
    - uses: actions/checkout@v4
    - name: Install Nuclei
      run: | 
        wget -q https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_linux_amd64.zip 
        unzip -q nuclei_linux_amd64.zip 
        sudo mv nuclei /usr/local/bin/
        nuclei -update-templates -silent  
    - name: Run Nuclei lightweight scan
      id: nuclei
      run: |
        nuclei \
          -u "${{ needs.create-or-update.outputs.env_url }}" \
          -t cves/ -t exposures/ -t vulnerabilities/ -t misconfiguration/ \
          -severity critical,high \
          -j \
          -o nuclei-pr-findings.json \ 
          -silent || true
        CRITICAL=$(jq '[.[] | select(.info.severity == "critical")] | length' nuclei-pr-findings.json 2>/dev/null || echo 0)
        HIGH=$(jq '[.[] | select(.info.severity == "high")] | length' nuclei-pr-findings.json 2>/dev/null || echo 0)
        echo "critical=$CRITICAL" >> $GITHUB_OUTPUT
        echo "high=$HIGH" >> $GITHUB_OUTPUT 
    - name: Post findings as PR comment
      uses: peter-evans/create-or-update-comment@v3
      with:
        issue-number: ${{ github.event.pull_request.number }}
        body: |
          ## DAST Scan Results (Nuclei)
          **Target:** ${{ needs.create-or-update.outputs.env_url }} 
          **Critical:** ${{ steps.nuclei.outputs.critical }}
          **High:** ${{ steps.nuclei.outputs.high }}
          ${{ steps.nuclei.outputs.critical > 0 && '> **BLOCKED** — Critical vulnerabilities must be resolved before merge.' || (steps.nuclei.outputs.high > 0 && '> **WARNING** — High severity findings detected. Review before merge.' || '> All checks passed.') }} 
        edit-mode: replace
    - name: Upload findings artifact
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: dast-pr-${{ github.event.pull_request.number }}
        path: nuclei-pr-findings.json 
    - name: Block on Critical findings  
      if: steps.nuclei.outputs.critical > 0
      run: |  
        echo "::error::DAST found ${{ steps.nuclei.outputs.critical }} critical vulnerability(ies). Fix before merging."
        exit 1 
``` 

**Gate behaviour:**
| Finding | Action |
|---------|--------|
| Critical | `exit 1` — blocks merge |
| High | PR comment warning — does not block (logged for sprint review) | 
| Medium/Low | Not scanned in PR path (weekly ZAP covers these) | 
| Nuclei unavailable | Skip silently — log as note in PR comment |

**Separation of concerns:**
- **Per-PR (this workflow):** Nuclei — fast (<5min), critical/high only, templates-based
- **Weekly scheduled (`dast.yml`):** OWASP ZAP full scan — slow (5–30min), all severities, OpenAPI-driven
