import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/theme.dart';

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

  Widget _tool(
    BuildContext context,
    String tooltip,
    IconData icon,
    VoidCallback action,
  ) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.ink,
        side: const BorderSide(color: AppTheme.ink, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: action,
      icon: Icon(icon, color: AppTheme.ink),
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
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppTheme.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.ink,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _tool(context, 'Bold', Icons.format_bold, () => _wrap('**', '**')),
            _tool(
              context,
              'Italic',
              Icons.format_italic,
              () => _wrap('_', '_'),
            ),
            _tool(context, 'Inline code', Icons.code, () => _wrap(tick, tick)),
            _tool(context, 'Heading', Icons.title, () => _prefixLine('## ')),
            _tool(
              context,
              'Bullet list',
              Icons.format_list_bulleted,
              () => _prefixLine('- '),
            ),
            _tool(
              context,
              'Checklist',
              Icons.check_box_outlined,
              () => _prefixLine('- [ ] '),
            ),
            _tool(
              context,
              'Quote',
              Icons.format_quote,
              () => _prefixLine('> '),
            ),
            _tool(context, 'Link', Icons.link, () => _wrap('[', '](url)')),
            _tool(
              context,
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
