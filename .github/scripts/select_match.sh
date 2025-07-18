#!/bin/bash

# Script to select a match ID based on date criteria
# Priorities:
# 1. Today's match (UK timezone)
# 2. Yesterday's match (UK timezone)
# 3. Next future match
# 4. Most recent past match

# Get current date in UK timezone (YYYY-MM-DD format)
TODAY=$(TZ="Europe/London" date +"%Y-%m-%d")
YESTERDAY=$(TZ="Europe/London" date -d "yesterday" +"%Y-%m-%d")

# Parse matches.json
MATCHES_JSON=$(cat matches.json)

# Try to find today's match
TODAY_MATCH=$(echo "$MATCHES_JSON" | jq -r ".[] | select(.date == \"$TODAY\") | .matchId" | head -1)
if [ -n "$TODAY_MATCH" ]; then
  echo "$TODAY_MATCH"
  exit 0
fi

# Try to find yesterday's match
YESTERDAY_MATCH=$(echo "$MATCHES_JSON" | jq -r ".[] | select(.date == \"$YESTERDAY\") | .matchId" | head -1)
if [ -n "$YESTERDAY_MATCH" ]; then
  echo "$YESTERDAY_MATCH"
  exit 0
fi

# Find the next future match
NEXT_MATCH=$(echo "$MATCHES_JSON" | jq -r "[.[] | select(.date > \"$TODAY\")] | sort_by(.date) | .[0].matchId // empty")
if [ -n "$NEXT_MATCH" ]; then
  echo "$NEXT_MATCH"
  exit 0
fi

# Find the most recent past match
LAST_MATCH=$(echo "$MATCHES_JSON" | jq -r "[.[] | select(.date < \"$TODAY\")] | sort_by(.date) | reverse | .[0].matchId // empty")
if [ -n "$LAST_MATCH" ]; then
  echo "$LAST_MATCH"
  exit 0
fi

# Fallback to the first match in the file if nothing else works
FALLBACK_MATCH=$(echo "$MATCHES_JSON" | jq -r ".[0].matchId // empty")
if [ -n "$FALLBACK_MATCH" ]; then
  echo "$FALLBACK_MATCH"
  exit 0
fi

# If we reach here, there's a problem with the matches.json file
echo "Error: No valid matches found" >&2
exit 1
