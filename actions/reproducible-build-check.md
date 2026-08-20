# Reproducible Build Check

Verify project build reproducibility: building the same source twice must
produce bit-for-bit identical artifacts.

## How it works

One check, two native comparison mechanisms depending on the build system:

- **Gradle** — the project is built twice into two separate local Maven
  repositories (`publishToMavenLocal` with `--no-build-cache --no-daemon`), then
  the artifact checksums are diffed. Any mismatch fails the check and is listed
  in a `.buildcompare` report.
- **Maven** — the reference artifacts are produced with
  `mvn clean install -Preproducibility-check`, then the project is rebuilt and
  compared against them with Maven's native
  `mvn clean verify artifact:compare` goal.

Everything is driven from the `reproducible-build-check.yml` reusable workflow in
this repository. Per-repo settings live in `actions/resolve-ci-config/config.yml`;
the *build system*, *Java version*, and *build arguments* are reused from the same
configuration as the other CI workflows.

The workflow only *verifies* reproducibility; it does not magically make built
artifacts reproducible.

## Prerequisites

- **Gradle** projects: archive tasks must be configured for reproducibility
  (`reproducibleFileOrder = true`, `preserveFileTimestamps = false`, a fixed
  `outputTimestamp`, etc.).
- **Maven** projects: a `reproducibility-check` profile and the
  `reference.repo` used by `artifact:compare` (default: `hibernate-maven-central`)
  must be defined in the project (typically via `project.build.outputTimestamp`
  and the `maven-artifact-plugin`).

## Integrating a new repository

### Step 1: Enable it in the configuration

In this repository, set `reproducibility-check: true` for your repo in
`actions/resolve-ci-config/config.yml` (the `build-system` and `java-version`
settings are already shared with the other CI features):

```yaml
hibernate/hibernate-example:
  default:
    reproducibility-check: true
  settings:
    build-system: gradle   # or maven
    java-version: '25'
```

Maven projects may override the reference repository id:

```yaml
  settings:
    build-system: maven
    repro-reference-repo: hibernate-maven-central
```

### Step 2: Create the caller workflow

Create `.github/workflows/reproducible-build-check.yml` in your project. The
project decides *when* the check runs — typically after a merge to the relevant
branches, plus a periodic schedule to catch environment/dependency drift:

```yaml
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors

name: Reproducible build check

on:
  push:
    branches: [ main, '*.x' ]   # tune to your branches
  schedule:
    - cron: '0 3 * * 1'         # tune to your cadence (here: weekly, Monday 03:00 UTC)

permissions: { }

jobs:
  check:
    uses: hibernate/.github/.github/workflows/reproducible-build-check.yml@main
    secrets: inherit
```

If `reproducibility-check` is not enabled for the repository in `config.yml`, the
workflow resolves to a no-op (the check job is skipped), so it is safe to add the
caller before flipping the flag.

## Diagnosing failures

- A failed run uploads a `buildcompare` artifact containing the `.buildcompare`
  report(s). For Gradle it lists the mismatching files and the `diffoscope`
  commands to inspect them; for Maven it is produced by `artifact:compare`.
- Reproducibility must be verified in the **same environment** (same JDK and
  wrapper version), which is why the workflow builds twice in a single job rather
  than across a matrix of toolchains.
