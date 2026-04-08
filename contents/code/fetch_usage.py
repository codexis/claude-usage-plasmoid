#!/usr/bin/env python3
"""
Fetches Claude AI usage data and prints JSON to stdout.
Called by the Plasma widget via DataSource.
"""
import json
import urllib.request
import urllib.error
import ssl
from pathlib import Path

USAGE_API_URL = "https://api.anthropic.com/api/oauth/usage"
CREDENTIALS_FILE = Path.home() / ".claude" / ".credentials.json"
CONFIG_FILE = Path.home() / ".config" / "claude-usage-widget" / "config.json"


def load_token():
    if CREDENTIALS_FILE.exists():
        try:
            data = json.loads(CREDENTIALS_FILE.read_text())
            token = data.get("claudeAiOauth", {}).get("accessToken")
            if token and token.strip():
                return token.strip()
        except Exception:
            pass
    if CONFIG_FILE.exists():
        try:
            data = json.loads(CONFIG_FILE.read_text())
            token = data.get("oauth_token")
            if token and token.strip():
                return token.strip()
        except Exception:
            pass
    return None


def fetch_usage(token):
    headers = {
        "Accept": "application/json",
        "User-Agent": "claude-usage-widget/1.0",
        "Authorization": f"Bearer {token}",
        "anthropic-beta": "oauth-2025-04-20",
    }
    req = urllib.request.Request(USAGE_API_URL, headers=headers, method="GET")
    ctx = ssl.create_default_context()
    with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
        return json.loads(resp.read().decode())


def main():
    token = load_token()
    if not token:
        print(json.dumps({"error": "no_token"}))
        return

    try:
        data = fetch_usage(token)
        print(json.dumps(data))
    except urllib.error.HTTPError as e:
        print(json.dumps({"error": f"http_{e.code}"}))
    except urllib.error.URLError as e:
        reason = e.reason
        if hasattr(reason, "errno"):
            msg = "no network" if reason.errno in (-2, -3, 11001) else f"network error ({reason.errno})"
        else:
            msg = "connection failed"
        print(json.dumps({"error": msg}))
    except TimeoutError:
        print(json.dumps({"error": "timeout"}))
    except Exception:
        print(json.dumps({"error": "unexpected error"}))


if __name__ == "__main__":
    main()
