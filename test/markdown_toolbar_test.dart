import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/features/editor/presentation/markdown_toolbar.dart';

void main() {
  testWidgets('bold action wraps the current text selection', (tester) async {
    final controller = TextEditingController(text: 'hello world');
    controller.selection = const TextSelection(baseOffset: 6, extentOffset: 11);
    var changed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownToolbar(
            controller: controller,
            onChanged: () => changed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Bold'));
    await tester.pump();

    expect(controller.text, 'hello **world**');
    expect(changed, isTrue);
    expect(controller.selection.baseOffset, 14);
    controller.dispose();
  });

  testWidgets('heading action prefixes the current line', (tester) async {
    final controller = TextEditingController(text: 'First line\nSecond line');
    controller.selection = const TextSelection.collapsed(offset: 15);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownToolbar(
            controller: controller,
            onChanged: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Heading'));
    await tester.pump();

    expect(controller.text, 'First line\n## Second line');
    controller.dispose();
  });
}
