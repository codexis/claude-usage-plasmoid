#!/usr/bin/env python3
"""
Fetches Claude AI usage data and prints JSON to stdout.
Called by the Plasma widget via DataSource.
Pass --debug to get verbose logging on stderr.
"""
import json
import logging
import socket
import ssl
import sys
import urllib.error
import urllib.request
from pathlib import Path

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG if "--debug" in sys.argv else logging.WARNING,
    format="%(levelname)s %(message)s",
)

USAGE_API_URL = "https://api.anthropic.com/api/oauth/usage"
CREDENTIALS_FILE = Path.home() / ".claude" / ".credentials.json"
CONFIG_FILE = Path.home() / ".config" / "claude-usage-widget" / "config.json"

# Keep in sync with the API rollout date shown in Claude Code OAuth docs.
ANTHROPIC_BETA = "oauth-2025-04-20"


def _find_project_root() -> Path | None:
    for parent in Path(__file__).resolve().parents:
        if (parent / ".git").exists():
            return parent
    return None


_root = _find_project_root()
MOCK_RESPONSE = (_root / "dev" / "mock" / "response.json") if _root else None


def load_token():
    if CREDENTIALS_FILE.exists():
        try:
            data = json.loads(CREDENTIALS_FILE.read_text())
            token = data.get("claudeAiOauth", {}).get("accessToken")
            if token and token.strip():
                return token.strip()
        except Exception as e:
            logging.debug("Could not read credentials file: %s", e)

    if CONFIG_FILE.exists():
        try:
            data = json.loads(CONFIG_FILE.read_text())
            token = data.get("oauth_token")
            if token and token.strip():
                return token.strip()
        except Exception as e:
            logging.debug("Could not read config file: %s", e)

    return None


def fetch_usage(token):
    headers = {
        "Accept": "application/json",
        "User-Agent": "claude-usage-widget/1.0",
        "Authorization": f"Bearer {token}",
        "anthropic-beta": ANTHROPIC_BETA,
    }
    req = urllib.request.Request(USAGE_API_URL, headers=headers, method="GET")
    ctx = ssl.create_default_context()
    with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
        return json.loads(resp.read().decode())


def main():
    if MOCK_RESPONSE and MOCK_RESPONSE.exists():
        try:
            text = MOCK_RESPONSE.read_text()
            json.loads(text)  # validate
            logging.debug("Using mock response, skipping API call")
            print(text)
            return
        except (json.JSONDecodeError, OSError) as e:
            logging.warning("Mock response invalid, falling back to API: %s", e)

    token = load_token()
    if not token:
        print(json.dumps({"error": "no_token"}))
        return

    try:
        data = fetch_usage(token)
        print(json.dumps(data))
    except urllib.error.HTTPError as e:
        logging.debug("HTTP error %s: %s", e.code, e)
        if e.code in (401, 403):
            print(json.dumps({"error": "auth_error"}))
        else:
            print(json.dumps({"error": f"http_{e.code}"}))
    except urllib.error.URLError as e:
        logging.debug("URL error: %s", e)
        if isinstance(e.reason, socket.gaierror):
            msg = "no network"
        else:
            msg = f"network: {e.reason}"
        print(json.dumps({"error": msg}))
    except TimeoutError:
        print(json.dumps({"error": "timeout"}))
    except Exception as e:
        logging.exception("Unexpected error")
        print(json.dumps({"error": f"unexpected: {type(e).__name__}"}))


if __name__ == "__main__":
    main()
