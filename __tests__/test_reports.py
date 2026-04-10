"""
Tests for GET /api/reports/me
"""

import pytest

from conftest import backend_required


@backend_required
class TestReports:

    def test_report_without_token_returns_401(self, session, base_url):
        resp = session.get(f"{base_url}/api/reports/me")
        assert resp.status_code == 401

    def test_report_with_token_returns_200_or_404(self, auth_session, base_url):
        """
        200 means PDF was generated; 404 is acceptable if the user has no
        activity recorded yet for the requested period.
        """
        resp = auth_session.get(f"{base_url}/api/reports/me")
        assert resp.status_code in (200, 404), (
            f"Unexpected status {resp.status_code}: {resp.text[:200]}"
        )

    def test_report_content_type_is_pdf(self, auth_session, base_url):
        resp = auth_session.get(f"{base_url}/api/reports/me")
        if resp.status_code == 200:
            ct = resp.headers.get("Content-Type", "")
            assert "application/pdf" in ct, f"Expected PDF content-type, got: {ct}"

    def test_report_response_is_not_empty(self, auth_session, base_url):
        resp = auth_session.get(f"{base_url}/api/reports/me")
        if resp.status_code == 200:
            assert len(resp.content) > 0, "PDF response body is empty"

    def test_report_pdf_starts_with_pdf_magic_bytes(self, auth_session, base_url):
        resp = auth_session.get(f"{base_url}/api/reports/me")
        if resp.status_code == 200:
            assert resp.content[:4] == b"%PDF", (
                f"Response does not look like a PDF: {resp.content[:20]!r}"
            )

    def test_report_content_disposition_header(self, auth_session, base_url):
        """The response should include a filename in Content-Disposition."""
        resp = auth_session.get(f"{base_url}/api/reports/me")
        if resp.status_code == 200:
            cd = resp.headers.get("Content-Disposition", "")
            assert "kairos-reporte" in cd, (
                f"Expected 'kairos-reporte' in Content-Disposition: {cd!r}"
            )

    def test_report_explicit_month_and_year(self, auth_session, base_url):
        resp = auth_session.get(f"{base_url}/api/reports/me?month=3&year=2026")
        assert resp.status_code in (200, 404)

    def test_report_invalid_month_clamped_or_rejected(self, auth_session, base_url):
        """month=13 is invalid — server should either 400 or treat it gracefully."""
        resp = auth_session.get(f"{base_url}/api/reports/me?month=13&year=2026")
        assert resp.status_code in (200, 400, 404)
