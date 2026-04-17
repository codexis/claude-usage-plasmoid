import unittest
from unittest.mock import patch, MagicMock
import json
import urllib.error
import socket
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'package', 'contents', 'code')))
import fetch_usage


class TestLoadToken(unittest.TestCase):
    @patch('fetch_usage.CREDENTIALS_FILE')
    @patch('fetch_usage.CONFIG_FILE')
    def test_load_token_from_credentials(self, mock_config, mock_credentials):
        mock_credentials.exists.return_value = True
        mock_credentials.read_text.return_value = json.dumps({
            "claudeAiOauth": {"accessToken": " test_token_1 "}
        })

        token = fetch_usage.load_token()
        self.assertEqual(token, "test_token_1")

    @patch('fetch_usage.CREDENTIALS_FILE')
    @patch('fetch_usage.CONFIG_FILE')
    def test_load_token_from_config(self, mock_config, mock_credentials):
        mock_credentials.exists.return_value = False
        mock_config.exists.return_value = True
        mock_config.read_text.return_value = json.dumps({
            "oauth_token": " test_token_2 "
        })

        token = fetch_usage.load_token()
        self.assertEqual(token, "test_token_2")

    @patch('fetch_usage.CREDENTIALS_FILE')
    @patch('fetch_usage.CONFIG_FILE')
    def test_load_token_no_file(self, mock_config, mock_credentials):
        mock_credentials.exists.return_value = False
        mock_config.exists.return_value = False

        token = fetch_usage.load_token()
        self.assertIsNone(token)

    @patch('fetch_usage.CREDENTIALS_FILE')
    @patch('fetch_usage.CONFIG_FILE')
    def test_load_token_credentials_preferred_over_config(self, mock_config, mock_credentials):
        mock_credentials.exists.return_value = True
        mock_credentials.read_text.return_value = json.dumps({
            "claudeAiOauth": {"accessToken": "creds_token"}
        })
        mock_config.exists.return_value = True
        mock_config.read_text.return_value = json.dumps({
            "oauth_token": "config_token"
        })

        token = fetch_usage.load_token()
        self.assertEqual(token, "creds_token")


class TestFetchUsage(unittest.TestCase):
    @patch('urllib.request.urlopen')
    def test_fetch_usage_success(self, mock_urlopen):
        mock_resp = MagicMock()
        mock_resp.read.return_value = json.dumps({"usage": "test"}).encode('utf-8')
        mock_resp.__enter__.return_value = mock_resp
        mock_urlopen.return_value = mock_resp

        data = fetch_usage.fetch_usage("dummy_token")
        self.assertEqual(data, {"usage": "test"})


class TestMain(unittest.TestCase):
    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_success(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.return_value = {"usage5h": 0.5}

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"usage5h": 0.5}))

    @patch('fetch_usage.load_token')
    @patch('builtins.print')
    def test_main_no_token(self, mock_print, mock_load):
        mock_load.return_value = None

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "no_token"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_http_401(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = urllib.error.HTTPError("url", 401, "Unauthorized", {}, None)

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "auth_error"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_http_403(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = urllib.error.HTTPError("url", 403, "Forbidden", {}, None)

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "auth_error"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_http_500(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = urllib.error.HTTPError("url", 500, "Internal Server Error", {}, None)

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "http_500"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_url_error_no_network(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = urllib.error.URLError(socket.gaierror())

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "no network"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_url_error_other(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        reason = OSError("connection refused")
        mock_fetch.side_effect = urllib.error.URLError(reason)

        fetch_usage.main()
        call_arg = mock_print.call_args[0][0]
        self.assertIn("network:", json.loads(call_arg)["error"])

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_timeout(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = TimeoutError()

        fetch_usage.main()
        mock_print.assert_called_once_with(json.dumps({"error": "timeout"}))

    @patch('fetch_usage.load_token')
    @patch('fetch_usage.fetch_usage')
    @patch('builtins.print')
    def test_main_unexpected_error(self, mock_print, mock_fetch, mock_load):
        mock_load.return_value = "token"
        mock_fetch.side_effect = ValueError("something went wrong")

        fetch_usage.main()
        call_arg = json.loads(mock_print.call_args[0][0])
        self.assertIn("unexpected:", call_arg["error"])
        self.assertIn("ValueError", call_arg["error"])


if __name__ == '__main__':
    unittest.main()
