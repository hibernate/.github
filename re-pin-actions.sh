#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright Red Hat Inc. and Hibernate Authors
#
# Re-pins hibernate/.github action references in .github/workflows/
# to the current HEAD commit.
#
# Usage: ./re-pin-actions.sh

set -euo pipefail

cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

NEW_SHA=$(git rev-parse HEAD)

REFS=$(grep -rhoE 'hibernate/\.github/actions/[A-Za-z0-9._-]+@[0-9a-f]{40}' .github/workflows | sort -u || true)

STALE=""
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  path="${ref%@*}"
  name="${path##*/}"
  sha="${ref##*@}"
  if ! git cat-file -e "${sha}^{commit}" 2>/dev/null; then
    echo "WARNING: ${name} is pinned to unknown commit ${sha:0:7}; will re-pin."
    STALE+="$name@$sha"$'\n'
    continue
  fi
  if ! git diff --quiet "$sha" HEAD -- "actions/$name/"; then
    echo "${name}: pinned at ${sha:0:7}, but actions/${name}/ changed since then."
    STALE+="$name@$sha"$'\n'
  fi
done <<< "$REFS"

if [ -z "$STALE" ]; then
  echo "All action pins are up to date; nothing to do."
  exit 0
fi

find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 \
  | xargs -0 sed -i -E "s|(hibernate/\.github/actions/[A-Za-z0-9._-]+)@[0-9a-f]{40}|\1@$NEW_SHA|g"

echo "Done. Updated pins to ${NEW_SHA:0:7}."
