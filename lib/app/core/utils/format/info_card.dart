String _decodeBasicHtmlEntities(String text) {
  return text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'");
}

String formatHTMLContent(String html) {
  var text = html
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ');

  text = _decodeBasicHtmlEntities(text);
  text = text.replaceAllMapped(
    RegExp(r'([:.;])\s*-\s*'),
    (match) => '${match.group(1)}\n- ',
  );
  text = text.replaceAll(RegExp(r'^\s*-\s*'), '- ');
  text = text
      .replaceAll(RegExp(r'\n\s*-\s*\n\s*'), '\n- ')
      .replaceAll(RegExp(r'\n\s*-\s*'), '\n- ');

  return text
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .trim();
}
