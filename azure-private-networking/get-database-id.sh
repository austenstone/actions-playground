#!/bin/bash

# Script to retrieve GitHub organization or enterprise databaseId using GraphQL
# Usage: ./get-database-id.sh <type> <name>
#   type: either "org" or "enterprise"
#   name: the organization login or enterprise slug

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <type> <name>"
    echo "  type: 'org' or 'enterprise'"
    echo "  name: organization login or enterprise slug"
    echo ""
    echo "Examples:"
    echo "  $0 org octodemo"
    echo "  $0 enterprise octodemo"
    exit 1
fi

TYPE=$1
NAME=$2

case "$TYPE" in
    org|organization)
        echo "Querying organization databaseId for: $NAME"
        gh api graphql -f query="$(cat get-org-database-id.graphql)" -F login="$NAME" --jq '.data.organization | "Organization: \(.login)\nDatabase ID: \(.databaseId)"'
        ;;
    enterprise|ent)
        echo "Querying enterprise databaseId for: $NAME"
        gh api graphql -f query="$(cat get-enterprise-database-id.graphql)" -F slug="$NAME" --jq '.data.enterprise | "Enterprise: \(.slug)\nDatabase ID: \(.databaseId)"'
        ;;
    *)
        echo "Error: Invalid type '$TYPE'. Must be 'org' or 'enterprise'"
        exit 1
        ;;
esac
