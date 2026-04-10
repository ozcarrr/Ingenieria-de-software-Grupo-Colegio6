"""
Tests for the SignalR ChatHub at /hubs/chat

These are basic HTTP-level checks (negotiate endpoint + WebSocket upgrade).
Full message flow tests require a WebSocket client library.
"""

import pytest
import requests

from conftest import backend_required, BASE_URL


@backend_required
class TestChatHubNegotiate:
    """
    SignalR clients begin with a POST to /hubs/chat/negotiate.
    We verify that the endpoint exists and returns the expected negotiation payload.
    """

    HUB_URL = f"{BASE_URL}/hubs/chat"

    def test_negotiate_without_token_returns_401_or_200(self, session):
        """
        The hub is not [Authorize]-protected, so negotiate may return 200.
        If auth were required it would be 401. Either is acceptable.
        """
        resp = session.post(
            f"{self.HUB_URL}/negotiate",
            params={"negotiateVersion": "1"},
        )
        assert resp.status_code in (200, 401), (
            f"Unexpected negotiate status: {resp.status_code}"
        )

    def test_negotiate_returns_connection_token(self, session):
        resp = session.post(
            f"{self.HUB_URL}/negotiate",
            params={"negotiateVersion": "1"},
        )
        if resp.status_code == 200:
            body = resp.json()
            assert "connectionToken" in body or "connectionId" in body, (
                f"Negotiate response missing connection info: {body}"
            )

    def test_negotiate_with_jwt_token(self, auth_token):
        """Negotiate with Bearer token in query string (SignalR convention)."""
        resp = requests.post(
            f"{self.HUB_URL}/negotiate",
            params={"negotiateVersion": "1", "access_token": auth_token},
        )
        assert resp.status_code in (200, 401)
        if resp.status_code == 200:
            body = resp.json()
            assert "connectionToken" in body or "connectionId" in body

    def test_negotiate_response_has_available_transports(self, session):
        resp = session.post(
            f"{self.HUB_URL}/negotiate",
            params={"negotiateVersion": "1"},
        )
        if resp.status_code == 200:
            body = resp.json()
            assert "availableTransports" in body, (
                f"Missing availableTransports in: {body}"
            )
            transports = [t["transport"] for t in body["availableTransports"]]
            assert "WebSockets" in transports or "LongPolling" in transports, (
                f"Expected at least one transport in: {transports}"
            )

    def test_hub_url_does_not_return_404(self, session):
        """A GET to the hub URL should not 404 (it may redirect or 400)."""
        resp = session.get(self.HUB_URL)
        assert resp.status_code != 404, (
            f"Hub endpoint returned 404 — check that MapHub<ChatHub>(\"/hubs/chat\") "
            "is wired up in Program.cs"
        )
