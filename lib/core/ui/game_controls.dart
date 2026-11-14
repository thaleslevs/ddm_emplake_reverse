import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/game_palette.dart';

const _snap = Duration(milliseconds: 90);

class GameTitle extends StatelessWidget {
  const GameTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final size = width < 480 ? 48.0 : 72.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Ornament(color: p.gold, mirrored: false),
        SizedBox(width: size * 0.3),
        Text(text.toUpperCase(), style: GameType.display(size, p.text)),
        SizedBox(width: size * 0.3),
        _Ornament(color: p.gold, mirrored: true),
      ],
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament({required this.color, required this.mirrored});

  final Color color;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final line = Container(width: 28, height: 2, color: color.withValues(alpha: 0.7));
    final diamond = Transform.rotate(angle: 0.785398, child: Container(width: 7, height: 7, color: color));
    final children = [line, const SizedBox(width: 6), diamond];
    return Row(mainAxisSize: MainAxisSize.min, children: mirrored ? children.reversed.toList() : children);
  }
}

class GameTabs<T> extends StatelessWidget {
  const GameTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _GameTab(
                label: label(value),
                selected: value == selected,
                onTap: onSelected == null ? null : () => onSelected!(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameTab extends StatelessWidget {
  const _GameTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return _Pressable(
      onTap: onTap,
      selected: selected,
      builder: (state) {
        final face = selected ? p.gold : (state.hovered ? p.panelRaised : p.panel);
        final edge = selected ? Color.lerp(p.gold, p.ink, 0.45)! : p.backgroundDeep;
        final border = state.focused
            ? p.blue
            : selected
            ? p.gold
            : (state.hovered ? p.borderStrong : p.border);
        return _Bevel(
          face: face,
          edge: edge,
          border: border,
          pressed: state.pressed || selected,
          radius: 4,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: Text(
            label.toUpperCase(),
            style: GameType.display(24, selected ? p.ink : (state.hovered ? p.text : p.textMuted)),
          ),
        );
      },
    );
  }
}

enum GameButtonKind { primary, secondary, neutral }

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.kind = GameButtonKind.neutral,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final GameButtonKind kind;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final (face, edge, ink) = switch (kind) {
      GameButtonKind.primary => (p.red, p.equalsEdge, p.text),
      GameButtonKind.secondary => (p.panel, p.backgroundDeep, p.textMuted),
      GameButtonKind.neutral => (p.panelRaised, p.operatorEdge, p.text),
    };
    final enabled = onPressed != null;

    return AnimatedOpacity(
      duration: _snap,
      opacity: enabled ? 1 : 0.38,
      child: _Pressable(
        onTap: onPressed,
        builder: (state) => _Bevel(
          face: state.hovered ? Color.lerp(face, p.text, 0.08)! : face,
          edge: edge,
          border: state.focused ? p.blue : Color.lerp(face, p.backgroundDeep, 0.35)!,
          pressed: state.pressed,
          radius: 4,
          padding: const EdgeInsets.fromLTRB(18, 10, 22, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: ink),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), style: GameType.display(26, ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class PressState {
  const PressState({required this.hovered, required this.pressed, required this.focused});
  final bool hovered;
  final bool pressed;
  final bool focused;
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.builder, this.selected = false});

  final VoidCallback? onTap;
  final Widget Function(PressState state) builder;
  final bool selected;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: _enabled,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap?.call())},
        child: GestureDetector(
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: widget.builder(
            PressState(hovered: _hovered && _enabled, pressed: _pressed, focused: _focused),
          ),
        ),
      ),
    );
  }
}

class _Bevel extends StatelessWidget {
  const _Bevel({
    required this.face,
    required this.edge,
    required this.border,
    required this.pressed,
    required this.radius,
    required this.padding,
    required this.child,
  });

  final Color face;
  final Color edge;
  final Color border;
  final bool pressed;
  final double radius;
  final EdgeInsets padding;
  final Widget child;

  static const depth = 4.0;

  @override
  Widget build(BuildContext context) {
    final lift = pressed ? 1.0 : depth;
    return AnimatedContainer(
      duration: _snap,
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: depth - lift),
      decoration: BoxDecoration(
        color: edge,
        borderRadius: BorderRadius.circular(radius + 1),
        border: Border.all(color: border, width: 1.5),
      ),
      padding: EdgeInsets.only(bottom: lift),
      child: AnimatedContainer(
        duration: _snap,
        curve: Curves.easeOut,
        padding: padding,
        decoration: BoxDecoration(color: face, borderRadius: BorderRadius.circular(radius)),
        child: child,
      ),
    );
  }
}
