import 'package:material_ui/material_ui.dart';

/// Compact formatting controls for the live Markdown note editor.
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
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.045),
      ),
      onPressed: action,
      icon: Icon(icon, color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tick = String.fromCharCode(96);
    final tripleTick = List.filled(3, tick).join();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF242427),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: SingleChildScrollView(
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
      ),
    );
  }
}
