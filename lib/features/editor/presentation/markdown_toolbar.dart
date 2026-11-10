import 'package:flutter/material.dart';

/// Small Markdown authoring toolbar for the plain-text note editor.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  void _wrap(String before, String after) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = text.substring(start, end);
    final replacement = '$before$selected$after';
    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    onChanged();
  }

  void _prefixLine(String prefix) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final cursor = selection.isValid ? selection.start : text.length;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    controller.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
    onChanged();
  }

  Widget _tool(String tooltip, IconData icon, VoidCallback action) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: action,
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tick = String.fromCharCode(96);
    final tripleTick = List.filled(3, tick).join();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tool('Bold', Icons.format_bold, () => _wrap('**', '**')),
          _tool('Italic', Icons.format_italic, () => _wrap('_', '_')),
          _tool('Inline code', Icons.code, () => _wrap(tick, tick)),
          _tool('Heading', Icons.title, () => _prefixLine('## ')),
          _tool(
            'Bullet list',
            Icons.format_list_bulleted,
            () => _prefixLine('- '),
          ),
          _tool(
            'Checklist',
            Icons.check_box_outlined,
            () => _prefixLine('- [ ] '),
          ),
          _tool('Quote', Icons.format_quote, () => _prefixLine('> ')),
          _tool('Link', Icons.link, () => _wrap('[', '](url)')),
          _tool(
            'Code block',
            Icons.data_object,
            () => _wrap('$tripleTick\n', '\n$tripleTick'),
          ),
        ],
      ),
    );
  }
}
