/// Conditional export: uses dart:html on web, no-op stub elsewhere.
export 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart';
