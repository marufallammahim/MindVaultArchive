import 'package:material_ui/material_ui.dart';

/// TextEditingController that deliberately preserves a one-to-one mapping
/// between the underlying Markdown source and the rendered TextSpan.
///
/// TextField selection offsets are measured against the source string. Removing
/// Markdown delimiter characters in buildTextSpan shifts those offsets and can
/// make the caret jump or prevent reliable text entry. Keep every source
/// character in the span; Markdown preview is rendered separately.
class MarkdownPreviewEditingController extends TextEditingController {
  MarkdownPreviewEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return TextSpan(text: text, style: style);
  }
}
