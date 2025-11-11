#!/bin/bash
# Script to disable all GitHub Actions workflows in the repository
# Usage: ./scripts/disable-actions.sh

# Repository details
OWNER="octodemo"
REPO="actions-playground"

echo "🔍 Fetching all workflows for ${OWNER}/${REPO}..."
echo ""

# Get all workflows and save to temp file
WORKFLOWS_FILE=$(mktemp)
gh api -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "repos/${OWNER}/${REPO}/actions/workflows" \
  --paginate \
  --jq '.workflows[] | "\(.id)\t\(.name)\t\(.state)"' > "$WORKFLOWS_FILE"

# Counter for tracking
disabled=0
already_disabled=0
failed=0
total=0

# Process workflows
while IFS=$'\t' read -r id name state; do
  ((total++))
  
  if [[ "$state" == "disabled_manually" ]] || [[ "$state" == "disabled_inactivity" ]]; then
    echo "⏭️  Skipping '$name' (ID: $id) - already disabled ($state)"
    ((already_disabled++))
  else
    echo "🔒 Disabling workflow '$name' (ID: $id)..."
    
    if gh api --method PUT \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "repos/${OWNER}/${REPO}/actions/workflows/${id}/disable" > /dev/null 2>&1; then
      echo "✅ Successfully disabled '$name'"
      ((disabled++))
    else
      echo "❌ Failed to disable '$name'"
      ((failed++))
    fi
  fi
  echo ""
done < "$WORKFLOWS_FILE"

# Clean up
rm "$WORKFLOWS_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Summary:"
echo "   Total workflows: ${total}"
echo "   Newly disabled: ${disabled}"
echo "   Already disabled: ${already_disabled}"
echo "   Failed: ${failed}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
