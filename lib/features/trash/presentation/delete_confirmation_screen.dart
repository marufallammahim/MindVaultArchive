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

    final cableOutline = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cable = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final tangledCable = Path()
      ..moveTo(42, 91)
      ..cubicTo(61, 72, 76, 55, 92, 65)
      ..cubicTo(111, 77, 87, 91, 103, 103)
      ..cubicTo(117, 114, 137, 95, 122, 79)
      ..cubicTo(109, 65, 120, 49, 137, 55)
      ..cubicTo(155, 62, 151, 84, 134, 91)
      ..cubicTo(117, 98, 118, 114, 135, 120)
      ..cubicTo(151, 126, 165, 109, 153, 97)
      ..moveTo(71, 111)
      ..cubicTo(84, 126, 103, 126, 113, 113)
      ..cubicTo(125, 98, 145, 101, 151, 116)
      ..moveTo(91, 54)
      ..cubicTo(100, 37, 124, 35, 136, 47)
      ..cubicTo(148, 59, 139, 70, 129, 73);
    canvas.drawPath(tangledCable, cableOutline);
    canvas.drawPath(tangledCable, cable);

    final handOutline = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final handFill = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    final crease = Paint()
      ..color = const Color(0xFF9A6A00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final hand = Path()
      ..moveTo(11, 118)
      ..cubicTo(4, 111, 6, 99, 12, 91)
      ..lineTo(30, 70)
      ..cubicTo(37, 62, 47, 69, 42, 77)
      ..lineTo(32, 90)
      ..lineTo(54, 69)
      ..cubicTo(62, 62, 71, 69, 64, 78)
      ..lineTo(44, 99)
      ..lineTo(67, 82)
      ..cubicTo(76, 76, 85, 85, 77, 94)
      ..lineTo(49, 119)
      ..cubicTo(39, 129, 21, 128, 11, 118)
      ..close();

    void drawHand({required bool mirrored}) {
      canvas.save();
      if (mirrored) {
        canvas.translate(220, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawShadow(hand, Colors.black, 3, false);
      canvas.drawPath(hand, handFill);
      canvas.drawPath(hand, handOutline);
      canvas.drawLine(const Offset(28, 105), const Offset(43, 91), crease);
      canvas.drawLine(const Offset(38, 113), const Offset(54, 99), crease);
      canvas.restore();
    }

    drawHand(mirrored: false);
    drawHand(mirrored: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeleteCablePainter oldDelegate) => false;
}
