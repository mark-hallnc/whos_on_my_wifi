import 'dart:io';

/// Presentation cleanup only; raw protocol values remain in service/UPnP data.
class IdentityText {
  static String? clean(String? value) {
    if (value == null || value.length > 1024) return null;
    final text = value
        .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    return text;
  }

  static String? name(String? value) {
    var text = clean(value);
    if (text == null || text.length > 255) return null;
    text = text
        .replaceFirst(RegExp(r'\.+$'), '')
        .replaceFirst(RegExp(r'\.local$', caseSensitive: false), '')
        .trim();
    final lower = text.toLowerCase();
    if (text.isEmpty ||
        const {
          'localhost',
          'android',
          'unknown',
          'unknown device',
          'device',
          'generic',
          'default',
          'n/a',
          'none',
          'null',
        }.contains(lower) ||
        lower.startsWith('_') ||
        lower.startsWith('urn:') ||
        lower.contains('._tcp') ||
        lower.contains('._udp') ||
        InternetAddress.tryParse(text) != null ||
        RegExp(r'^[0-9.:-]+$').hasMatch(text) ||
        RegExp(
          r'^(?:uuid:)?\{?[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}\}?$',
          caseSensitive: false,
        ).hasMatch(text)) {
      return null;
    }
    // Cast/RAOP machine instance IDs are not friendly identities.
    if (RegExp(
      r'^(?:chromecast-|[0-9a-f]{12}@)[0-9a-f-]{20,}$',
      caseSensitive: false,
    ).hasMatch(text)) {
      return null;
    }
    return text;
  }

  static String? model(String? value) {
    final text = name(value);
    if (text == null ||
        const {
          'model',
          'generic model',
          'printer',
          'tv',
          'television',
          'media renderer',
          'mediarenderer',
          'router',
        }.contains(text.toLowerCase())) {
      return null;
    }
    return text;
  }

  static String? manufacturer(String? value) {
    final text = clean(value);
    if (text == null || name(text) == null) return null;
    // Exact aliases only: no broad suffix stripping or substring company guesses.
    return const {
          'samsung': 'Samsung',
          'samsung electronics': 'Samsung',
          'samsung electronics co.,ltd': 'Samsung',
          'samsung electronics co.,ltd.': 'Samsung',
          'samsung electronics co., ltd': 'Samsung',
          'samsung electronics co., ltd.': 'Samsung',
          'google': 'Google',
          'google llc': 'Google',
          'google, inc.': 'Google',
          'espressif': 'Espressif',
          'espressif inc.': 'Espressif',
          'apple': 'Apple',
          'apple, inc.': 'Apple',
          'apple inc.': 'Apple',
          'hp': 'HP',
          'hp inc.': 'HP',
          'hewlett-packard': 'HP',
          'hewlett packard': 'HP',
          'roku': 'Roku',
          'roku, inc.': 'Roku',
          'roku inc.': 'Roku',
        }[text.toLowerCase()] ??
        text;
  }
}
