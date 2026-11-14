import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/branding_assets.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';

/// Reference-inspired confirmation before moving a note to Trash.
class DeleteConfirmationScreen extends ConsumerWidget {
  const DeleteConfirmationScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final noteQuery = db.select(db.notes)
      ..where((note) => note.id.equals(noteId));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder(
          stream: noteQuery.watchSingleOrNull(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load note: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            final note = snapshot.data;
            if (note == null) {
              return _missing(context);
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      tooltip: 'Go back',
                      onPressed: () => context.pop(false),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.ink, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primary,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.memory(
                        BrandingAssets.appLogo,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'You sure\nabout this?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 39,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'If you delete this note, fret not, you can still find it in the bin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .78),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 220,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primary,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const CustomPaint(painter: _DeleteCablePainter()),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.ink,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF27F80),
                        foregroundColor: const Color(0xFF251416),
                        elevation: 0,
                        side: const BorderSide(color: AppTheme.ink, width: 2.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: () => context.pop(true),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(
                        'Delete this note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text(
                      'No, keep it',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _missing(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.note_alt_outlined, size: 48, color: Colors.white),
        const SizedBox(height: 12),
        const Text(
          'This note is no longer available.',
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Go back'),
        ),
      ],
    ),
  );
}

class _DeleteCablePainter extends CustomPainter {
  const _DeleteCablePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 220, size.height / 140);

    final outline = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final yellowFill = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    final yellowLine = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cable = Path()
      ..moveTo(118, 55)
      ..cubicTo(139, 43, 145, 27, 166, 29)
      ..cubicTo(184, 30, 190, 45, 183, 62);
    canvas.drawPath(cable, outline);
    canvas.drawPath(cable, yellowLine);

    final plug = RRect.fromRectAndRadius(
      const Rect.fromLTWH(104, 43, 25, 24),
      const Radius.circular(5),
    );
    canvas.drawRRect(plug, yellowFill);
    canvas.drawRRect(plug, outline);
    canvas.drawLine(const Offset(110, 43), const Offset(110, 32), outline);
    canvas.drawLine(const Offset(122, 43), const Offset(122, 32), outline);

    final hand = Path()
      ..moveTo(52, 118)
      ..cubicTo(46, 107, 42, 92, 43, 81)
      ..cubicTo(44, 72, 55, 70, 60, 80)
      ..lineTo(63, 90)
      ..lineTo(64, 55)
      ..cubicTo(65, 42, 80, 42, 82, 55)
      ..lineTo(82, 84)
      ..lineTo(88, 47)
      ..cubicTo(90, 34, 105, 37, 106, 50)
      ..lineTo(103, 87)
      ..lineTo(113, 62)
      ..cubicTo(118, 51, 132, 57, 128, 70)
      ..lineTo(116, 100)
      ..cubicTo(112, 117, 96, 130, 78, 131)
      ..cubicTo(67, 131, 58, 126, 52, 118)
      ..close();
    canvas.drawShadow(hand, Colors.black, 3, false);
    canvas.drawPath(hand, yellowFill);
    canvas.drawPath(hand, outline);

    final sparkle = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(158, 91), const Offset(158, 105), sparkle);
    canvas.drawLine(const Offset(151, 98), const Offset(165, 98), sparkle);
    canvas.drawLine(const Offset(190, 91), const Offset(190, 101), sparkle);
    canvas.drawLine(const Offset(185, 96), const Offset(195, 96), sparkle);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeleteCablePainter oldDelegate) => false;
}
