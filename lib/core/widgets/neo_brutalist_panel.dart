import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/theme.dart';

/// A reusable, accessible panel for the app's Neo-Brutalist surface language.
///
/// The hard offset shadow is deliberately unblurred. Material remains the
/// interaction surface so nested ListTiles, controls and focus states keep
/// their normal semantics and ripple behavior.
class NeoBrutalistPanel extends StatelessWidget {
  const NeoBrutalistPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
    this.radius = 7,
    this.shadowOffset = 4,
    this.borderWidth = 2.5,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final double shadowOffset;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF5F1EC)
        : AppTheme.ink;
    final backgroundColor =
        color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
