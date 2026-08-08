# Privacy

NumTrace is designed to support public-footprint auditing.

## Data sent externally

- Optional search queries for public providers
- Optional API requests when keys are configured

## Stored locally

- Cache entries
- Generated reports
- User config

## Deleting data

- Use `./numtrace.sh --clear-cache`
- Remove reports from the `reports/` directory
- Remove `~/.config/numtrace/config` to disable API-backed providers

