# Providers

Provider modules expose functions named `numtrace_provider_<name>`.

The default working provider is DuckDuckGo HTML search.

Each provider receives a search query and should emit result records through the shared search layer.

If a provider cannot run, it should print a warning and return success so the rest of the analysis can continue.
