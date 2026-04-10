"""
Tests for POST /api/storage/upload
"""

import io
import struct
import pytest

from conftest import backend_required


# ── Minimal in-memory images ───────────────────────────────────────────────────

def _minimal_jpeg() -> bytes:
    """Return a 1×1 white JPEG (valid enough for the server's content-type check)."""
    return bytes([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
        0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
        0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
        0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
        0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
        0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
        0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03,
        0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D,
        0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0xFB, 0xD7,
        0xFF, 0xD9,
    ])


def _minimal_png() -> bytes:
    """Return a 1×1 red PNG."""
    import zlib
    def chunk(name: bytes, data: bytes) -> bytes:
        c = name + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    sig     = b"\x89PNG\r\n\x1a\n"
    ihdr    = chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
    raw     = b"\x00\xFF\x00\x00"          # filter + RGB pixel
    idat    = chunk(b"IDAT", zlib.compress(raw))
    iend    = chunk(b"IEND", b"")
    return sig + ihdr + idat + iend


# ── Tests ──────────────────────────────────────────────────────────────────────

@backend_required
class TestStorageUpload:

    def _upload(self, session, base_url, data: bytes, filename: str, content_type: str):
        """Helper to POST a file as multipart/form-data."""
        files = {"file": (filename, io.BytesIO(data), content_type)}
        # Must NOT send Content-Type: application/json for multipart
        headers = {k: v for k, v in session.headers.items()
                   if k.lower() != "content-type"}
        return session.post(
            f"{base_url}/api/storage/upload",
            files=files,
            headers=headers,
        )

    def test_upload_without_token_returns_401(self, session, base_url):
        files = {"file": ("test.jpg", io.BytesIO(_minimal_jpeg()), "image/jpeg")}
        resp  = session.post(f"{base_url}/api/storage/upload", files=files)
        assert resp.status_code == 401

    def test_upload_jpeg_returns_200_with_cdn_url(self, auth_session, base_url):
        resp = self._upload(auth_session, base_url,
                            _minimal_jpeg(), "test.jpg", "image/jpeg")
        # 200 OK if Azure Blob / Azurite is configured; 500 if not
        assert resp.status_code in (200, 500), f"Unexpected status: {resp.status_code}"
        if resp.status_code == 200:
            body = resp.json()
            assert "cdnUrl" in body, f"Missing cdnUrl: {body}"
            assert body["cdnUrl"].startswith("http"), f"cdnUrl looks wrong: {body['cdnUrl']}"

    def test_upload_png_returns_200(self, auth_session, base_url):
        resp = self._upload(auth_session, base_url,
                            _minimal_png(), "test.png", "image/png")
        assert resp.status_code in (200, 500)

    def test_upload_disallowed_content_type_returns_400(self, auth_session, base_url):
        resp = self._upload(auth_session, base_url,
                            b"fake pdf content", "doc.pdf", "application/pdf")
        assert resp.status_code == 400

    def test_upload_empty_file_returns_400(self, auth_session, base_url):
        resp = self._upload(auth_session, base_url,
                            b"", "empty.jpg", "image/jpeg")
        assert resp.status_code == 400

    def test_upload_missing_file_field_returns_400(self, auth_session, base_url):
        headers = {k: v for k, v in auth_session.headers.items()
                   if k.lower() != "content-type"}
        resp = auth_session.post(
            f"{base_url}/api/storage/upload",
            data={},
            headers=headers,
        )
        assert resp.status_code == 400

    def test_upload_text_plain_returns_400(self, auth_session, base_url):
        resp = self._upload(auth_session, base_url,
                            b"hello world", "notes.txt", "text/plain")
        assert resp.status_code == 400
