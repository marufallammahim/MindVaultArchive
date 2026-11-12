import 'package:material_ui/material_ui.dart';

/// Keeps Markdown source compatible with existing notes while rendering common
/// inline styles directly inside the editable field.
class MarkdownPreviewEditingController extends TextEditingController {
  MarkdownPreviewEditingController({super.text});

  static final _tokenPattern = RegExp(
    r'(\\*\\*[^\\n]+?\\*\\*|(?<!\\*)\\*[^\\n*]+?\\*(?!\\*)|(?<!_)_[^\\n_]+?_(?!_)|`[^`\\n]+`)',
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final source = text;
    final children = <InlineSpan>[];
    var cursor = 0;
    for (final match in _tokenPattern.allMatches(source)) {
      if (match.start > cursor) {
        children.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      final isBold = token.startsWith('**');
      final isItalic =
          !isBold && (token.startsWith('*') || token.startsWith('_'));
      final isCode = token.startsWith('`');
      final markerLength = isBold || isCode ? 2 : 1;
      children.add(
        TextSpan(
          text: token.substring(markerLength, token.length - markerLength),
          style: (style ?? const TextStyle()).copyWith(
            fontWeight: isBold ? FontWeight.w800 : null,
            fontStyle: isItalic ? FontStyle.italic : null,
            fontFamily: isCode ? 'monospace' : null,
            backgroundColor: isCode ? const Color(0x333F8CFF) : null,
            color: isCode ? const Color(0xFF9CC5FF) : null,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < source.length) {
      children.add(TextSpan(text: source.substring(cursor)));
    }
    return TextSpan(style: style, children: children);
  }
}
