# Documentation Preview for Pull Requests

Deploy documentation previews automatically when PRs change documentation,
so reviewers can see rendered HTML without building locally.

## How it works

Three reusable pieces, all managed from this repository:

1. **`build-docs-preview` action** — runs in your existing CI workflow. Detects doc
   changes, checks author permissions, and uploads built docs as an artifact.
2. **`ci-reporting.yml` reusable workflow** — triggered by `workflow_run` after CI
   completes. Downloads the artifact and deploys to Surge. Posts a PR comment with
   the preview link.
3. **`pr-cleanup.yml` reusable workflow** — triggered on PR close. Tears down the
   Surge site and updates the comment.

Feature flags and per-repo settings live in `actions/resolve-ci-config/config.yml`
in this repository. Adding or removing features requires no changes in project repos.

## Prerequisites

- A `SURGE_PREVIEW_TOKEN` org-level secret with a valid [Surge](https://surge.sh) token.
  The reusable workflows pass this to the deploy/teardown actions via environment variable.

## Integrating a new repository

### Step 1: Add to the configuration

In this repository, add your repo to `actions/resolve-ci-config/config.yml`:

```yaml
hibernate/hibernate-example:
  default:
    docs-preview: true
  settings:
    build-system: gradle
    java-version: '25'
```

### Step 2: Add the build step to existing CI

Add a step **after** your documentation build in the CI workflow. The action
detects whether documentation changed and uploads an artifact if so. It does
**not** build the docs itself — they must already be built by a prior step.

```yaml
- name: Upload docs preview
  uses: hibernate/.github/actions/build-docs-preview@main
  with:
    dist-path: 'documentation/target/dist'
    src-paths: |
      documentation/src
```

**Matrix builds**: If your CI uses a build matrix, gate the step with an `if`
condition so only one entry uploads.

### Step 3: Create the reporting workflow

Create `.github/workflows/ci-report.yml` (or add the job to your existing one):

```yaml
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors

name: CI reporting

on:
  workflow_run:
    workflows: ["GH Actions CI"]  # must match your CI workflow's name: field
    types: [completed]

permissions: { }

jobs:
  report:
    uses: hibernate/.github/.github/workflows/ci-reporting.yml@main
    secrets: inherit
```

### Step 4: Create the cleanup workflow

Create `.github/workflows/pr-cleanup.yml`:

```yaml
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors

name: PR cleanup

on:
  pull_request_target:
    types: [closed]

permissions: { }

jobs:
  cleanup:
    uses: hibernate/.github/.github/workflows/pr-cleanup.yml@main
    secrets: inherit
```

## Security model

- The `build-docs-preview` action runs in the `pull_request` context (CI), which
  has read-only access. For org members it detects doc changes automatically; for
  external contributors an org member must add a `docs-preview` label.
- The `ci-reporting` and `pr-cleanup` workflows run from trusted code on the
  default branch via `workflow_run` and `pull_request_target`. PR authors cannot
  tamper with them. Both workflows are restricted to the `hibernate` org.
- External contributor workflows require manual approval before running, which
  provides the trust gate — no preview is deployed without an org member's action.
- Secrets are passed via `secrets: inherit` and only accessed by the specific jobs
  that need them.
