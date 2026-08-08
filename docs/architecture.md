# Architecture

NumTrace is split into a thin executable entrypoint plus reusable shell modules.

## Layers

- `numtrace.sh` handles CLI parsing, menus, and orchestration
- `lib/phone.sh` normalizes and classifies numbers
- `lib/search.sh` coordinates public search providers
- `lib/business.sh`, `lib/documents.sh`, `lib/reputation.sh`, `lib/timeline.sh`, and `lib/correlation.sh` derive evidence views
- `lib/report.sh` renders TXT, JSON, and HTML output
- `lib/cache.sh` stores local cached responses
- `lib/dependencies.sh` checks optional tools and package-manager hints

## Principles

- Public OSINT only
- No fabricated certainty
- Unknown is preferred over guessing
- Provider failures must not terminate the whole run

