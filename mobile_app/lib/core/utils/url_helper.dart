import '../api/api_config.dart';

class UrlHelper {
  UrlHelper._();

  /// Fixes relative URLs coming from the backend by prefixing the base URL.
  static String? fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // If it's already an absolute URL (starts with http) or an asset (starts with assets)
    if (url.startsWith('http') || url.startsWith('assets/')) {
      return url;
    }
    
    // Remove leading slash if present to avoid double slashes
    final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    return '${ApiConfig.baseUrl}/$cleanUrl';
  }
}
