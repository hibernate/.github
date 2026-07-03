# Documentation Preview for Pull Requests

Deploy documentation previews automatically when PRs change documentation,
so reviewers can see rendered HTML without building locally.

## Integrating a new repository

Each repository needs three changes:

### Step 1: Add the build action to existing CI

Add a step **after** your main build in the CI workflow. The action detects whether
documentation changed and uploads an artifact if so. It does **not** build the docs
itself -- they must already be built by a prior step in your CI.

For **Maven/Gradle projects** where CI already builds docs:

```yaml
- name: Upload docs preview
  if: github.event_name == 'pull_request'
  uses: hibernate/.github/actions/build-docs-preview@main
  with:
    dist-path: 'documentation/target/dist'
    docs-paths: 'documentation/src'
```

For **Awestruct/Ruby sites** (hibernate.org, in.relation.to), ensure the site is
built in a prior step, then upload:

```yaml
- name: Upload docs preview
  uses: hibernate/.github/actions/build-docs-preview@main
  with:
    dist-path: '_site/'
    docs-paths: '.'
```

**Matrix builds**: If your CI uses a build matrix (e.g. Linux/Windows), gate the
step with an `if` condition so only one entry uploads. Otherwise, you'll get
conflicting artifacts.

### Step 2: Create the deploy workflow

Create `.github/workflows/deploy-docs-preview.yml`:

```yaml
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors

name: Deploy docs preview

on:
  workflow_run:
    workflows: ["GH Actions CI"]  # must match your CI workflow's name: field exactly
    types: [completed]

defaults:
  run:
    shell: bash

permissions: { }

jobs:
  deploy:
    name: Deploy docs preview
    if: >-
      github.event.workflow_run.event == 'pull_request'
      && github.event.workflow_run.conclusion != 'cancelled'
    runs-on: ubuntu-latest
    permissions:
      actions: read
      pull-requests: write
    steps:
      - uses: hibernate/.github/actions/deploy-docs-preview@main
        with:
          repo-name: 'hibernate-?'  # change to your repo name
          deploy-token: ${{ secrets.DOCUMENTATION_PREVIEW_DEPLOY_TOKEN }}
          github-token: ${{ github.token }}
```

### Step 3: Create the teardown workflow

Create `.github/workflows/teardown-docs-preview.yml`:

```yaml
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors

name: Teardown docs preview

on:
  pull_request_target:
    types: [closed]

defaults:
  run:
    shell: bash

permissions: { }

jobs:
  teardown:
    name: Teardown docs preview
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: hibernate/.github/actions/teardown-docs-preview@main
        with:
          repo-name: 'hibernate-?'  # change to your repo name
          deploy-token: ${{ secrets.DOCUMENTATION_PREVIEW_DEPLOY_TOKEN }}
          github-token: ${{ github.token }}
```
