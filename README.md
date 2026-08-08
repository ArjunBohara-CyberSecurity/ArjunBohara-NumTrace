<p align="center">
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Bash-5%2B-yellow?style=for-the-badge&logo=gnu-bash">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Termux-black?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/OSINT-Public%20Sources-purple?style=for-the-badge">
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge">
</p>

# 🚀 ArjunBohara-NumTrace

---

## 📌 Overview

**ArjunBohara-NumTrace** is an advanced Bash-based phone-number OSINT framework designed to discover and analyze publicly available information associated with a phone number.

It combines **phone-number analysis, public web intelligence, footprint discovery, evidence correlation, and automated reporting** into a lightweight command-line tool.

> **Map the Public Footprint.**

---

## ✨ Features

- 📱 Phone Number Normalization
- 🌍 Country & Numbering-Plan Information
- 🔎 Public Web Footprint Discovery
- 🌐 DuckDuckGo Search Integration
- 🏢 Public Business Listings
- 📄 Public Document Discovery
- ⚠️ Public Reputation Signals
- 🕒 Historical Public Mentions
- 🧠 Evidence Correlation
- 📊 Conservative Confidence Assessment
- 📁 TXT Report Generation
- 🔧 JSON Report Generation
- 🌐 HTML Report Generation
- 📦 Batch Processing
- 💾 Local Caching
- 📴 Offline Analysis Mode
- 🛡 Self-Audit Mode
- 🔍 Dependency Checking
- 📱 Termux Support
- 🐧 Linux Support
- 🍎 macOS Support

---

## 🧰 Tech Stack

- Bash
- curl
- grep
- sed
- find
- mktemp
- date
- head
- tail
- wc
- tr
- wget
- openssl
- DuckDuckGo
- Public OSINT Sources

---

## 📦 Installation

### Linux / macOS

```bash
git clone https://github.com/ArjunBohara-CyberSecurity/ArjunBohara-NumTrace.git
cd ArjunBohara-NumTrace
chmod +x numtrace.sh install.sh uninstall.sh
./install.sh
```

### Termux

```bash
pkg update
pkg install bash curl grep sed wget openssl

git clone https://github.com/ArjunBohara-CyberSecurity/ArjunBohara-NumTrace.git
cd ArjunBohara-NumTrace

chmod +x numtrace.sh install.sh uninstall.sh
./install.sh
```

### System-Wide Installation

```bash
PREFIX=/usr/local ./install.sh
```

The installer:

- Copies the project into a local share directory
- Creates the `numtrace` launcher
- Creates `~/.config/numtrace/config`
- Creates the local cache directory

---

## ⚙️ Setup

### Configuration

NumTrace automatically creates:

```text
~/.config/numtrace/config
```

Example configuration:

```bash
NUMTRACE_CACHE_TTL="86400"
NUMTRACE_SEARCH_PROVIDERS="duckduckgo"
NUMTRACE_SEARCH_DELAY="1"
```

---

## 💻 Usage

```bash
./numtrace.sh +919876543210
./numtrace.sh --country IN +919876543210
./numtrace.sh --json +919876543210
./numtrace.sh --quiet +919876543210
./numtrace.sh --report ./reports +919876543210
./numtrace.sh --batch numbers.txt
./numtrace.sh --offline +919876543210
./numtrace.sh --check-deps
./numtrace.sh --self-audit +919876543210
./numtrace.sh --privacy
./numtrace.sh --config
./numtrace.sh --clear-cache
./numtrace.sh --version
./numtrace.sh --help
```

After installation:

```bash
numtrace +919876543210
```

---

## 🔍 Example

```bash
> numtrace +919876543210
```

### ✔ Output Includes:

- Normalized Phone Number
- Country Context
- Numbering-Plan Information
- Public Web Mentions
- Business Mentions
- Document Mentions
- Reputation Signals
- Historical Mentions
- Public Footprint Summary
- Correlation Score
- Confidence Assessment

⚠️ If evidence is insufficient, NumTrace reports `UNKNOWN` instead of guessing.

---

## 🧠 How It Works

1. Validates the supplied phone number
2. Normalizes the number using country context
3. Performs numbering-plan analysis
4. Searches publicly indexed web results
5. Collects public mentions
6. Classifies results into:
   - Web
   - Business
   - Documents
   - Reputation
   - Timeline
7. Correlates available evidence
8. Produces a conservative confidence assessment
9. Generates the final OSINT report

---

## 📁 Logging & Reports

Reports are written to:

```text
reports/
```

Generated formats:

```text
YYYY-MM-DD_HH-MM_PHONE.txt
YYYY-MM-DD_HH-MM_PHONE.json
YYYY-MM-DD_HH-MM_PHONE.html
```

### TXT Report

Human-readable summary containing:

- Normalized target
- Numbering-plan information
- Public footprint counts
- Reputation summary
- Correlation score
- Limitations

### JSON Report

Machine-readable output suitable for downstream tools and automation.

### HTML Report

Lightweight HTML rendering of the generated report.

---

## 🔎 Search Provider

NumTrace currently ships with:

- DuckDuckGo

The provider architecture is modular, allowing additional providers to be added without rewriting the core CLI.

If a provider is unavailable, NumTrace warns and continues where possible.

---

## 💾 Local Caching

NumTrace supports local response caching.

Default cache lifetime:

```bash
NUMTRACE_CACHE_TTL="86400"
```

Clear cached data:

```bash
./numtrace.sh --clear-cache
```

---

## 📴 Offline Mode

Run NumTrace without network lookups:

```bash
./numtrace.sh --offline +919876543210
```

Offline mode still performs:

- Number normalization
- Local analysis
- Report generation

---

## 📦 Batch Processing

Process multiple phone numbers from a file:

```bash
./numtrace.sh --batch numbers.txt
```

One number is processed per line.

NumTrace continues processing if an individual number fails.

---

## 🛡️ Privacy & Security

- Uses public sources only
- Does not print secrets
- Stores cache locally
- Supports `--offline`
- Supports cache deletion
- Treats external content as untrusted
- Avoids executing remote content
- Does not access private accounts

---

## 🚫 What NumTrace Does NOT Do

- ❌ GPS tracking
- ❌ Cell-tower triangulation
- ❌ SIM-owner lookup
- ❌ Leaked database searching
- ❌ Credential recovery
- ❌ OTP interception
- ❌ Account takeover
- ❌ Private WhatsApp extraction
- ❌ Private Telegram extraction
- ❌ Covert tracking
- ❌ Malware
- ❌ Spyware
- ❌ Authentication bypass

**Numbering information is not the same as current physical location.**

---

## ⚠️ Accuracy & Limitations

NumTrace deliberately prefers:

```text
UNKNOWN
```

over fabricated information.

Public OSINT results may be incomplete because of:

- Search-engine indexing
- Deleted webpages
- Private profiles
- Incorrect public information
- Stale listings
- Number recycling
- Provider availability
- Search-engine rate limits

Important:

```text
Public mention ≠ ownership
Name match ≠ identity
Numbering region ≠ live location
```

NumTrace does not claim ownership or identity without sufficient public evidence.

---

## 🛑 Security Notes

- Designed for lawful OSINT and defensive research
- Use only on numbers you are authorized to investigate
- Respect privacy and applicable laws
- Public information may be outdated or incorrect
- Search results are not proof of identity
- OSINT correlation should not be treated as absolute confirmation

---

## 🔧 Troubleshooting

### `curl` not found

Debian / Kali / Ubuntu:

```bash
sudo apt install curl
```

Termux:

```bash
pkg install curl
```

### `bash` not found

Install Bash or use an environment that provides it.

### No Results

Possible causes:

- Number has little public footprint
- Number is not publicly indexed
- Offline mode is enabled
- Network provider timed out
- Search-engine limitations

### Dependency Check

```bash
./numtrace.sh --check-deps
```

---

## 🧪 Development

### Project Layout

```text
ArjunBohara-NumTrace/
│
├── numtrace.sh
├── install.sh
├── uninstall.sh
│
├── lib/
├── providers/
├── config/
├── docs/
├── reports/
└── tests/
```

### Syntax Check

```bash
bash -n numtrace.sh lib/*.sh providers/*.sh tests/*.sh
```

### Tests

```bash
./tests/test_utils.sh
./tests/test_phone.sh
./tests/test_json.sh
./tests/test_input.sh
./tests/test_batch.sh
./tests/test_signal.sh
```

---

## 🧑‍💻 Developer

- **Arjun Bohara**

---

## 📜 Version

```text
ArjunBohara-NumTrace v1.0.0
```

---

## ⚖️ Ethical Use

NumTrace is intended for:

- Defensive security research
- Lawful OSINT
- Public-footprint analysis
- Self-exposure audits
- Research and education
- Authorized investigations

Use NumTrace responsibly and respect privacy, applicable laws, and the terms of services you query.

---

## ⭐ Final Words

> **Map the Public Footprint.** 🗺️
