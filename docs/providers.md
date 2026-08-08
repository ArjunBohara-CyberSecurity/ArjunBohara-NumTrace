# Providers

NumTrace supports a modular provider model.

## Built-in providers

- DuckDuckGo HTML search, best effort
- Optional additional providers can be added later without changing the core CLI

## Behavior

- Providers may fail independently
- Missing credentials only disable the affected provider
- Network timeouts are reported and do not abort the full run
