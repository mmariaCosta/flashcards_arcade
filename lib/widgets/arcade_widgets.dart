import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/arcade_theme.dart';

// ─── SCANLINES OVERLAY ───
class ScanlinesOverlay extends StatelessWidget {
  final Widget child;
  const ScanlinesOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      IgnorePointer(
        child: CustomPaint(
          painter: _ScanlinesPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    ]);
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── GRID BACKGROUND ───
class GridBackground extends StatefulWidget {
  final Widget child;
  const GridBackground({super.key, required this.child});
  @override
  State<GridBackground> createState() => _GridBackgroundState();
}

class _GridBackgroundState extends State<GridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Stack(children: [
      CustomPaint(
        painter: _GridPainter(opacity: _anim.value),
        child: const SizedBox.expand(),
      ),
      widget.child,
    ]),
  );
}

class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArcadeColors.cyan.withOpacity(0.04 * opacity)
      ..strokeWidth = 0.5;
    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _GridPainter old) => old.opacity != opacity;
}

// ─── NEON TEXT ───
class NeonText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final bool isPixel;
  final TextAlign align;
  const NeonText(this.text, {
    super.key,
    this.size = 14,
    this.color = ArcadeColors.cyan,
    this.isPixel = false,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final style = isPixel
        ? ArcadeFonts.pixel(size: size, color: color)
        : ArcadeFonts.mono(size: size, color: color);
    return Text(
      text,
      textAlign: align,
      style: style.copyWith(
        shadows: [
          Shadow(color: color.withOpacity(0.9), blurRadius: 6),
          Shadow(color: color.withOpacity(0.5), blurRadius: 14),
          Shadow(color: color.withOpacity(0.2), blurRadius: 28),
        ],
      ),
    );
  }
}

// ─── NEON BUTTON ───
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool filled;
  final bool fullWidth;
  final double fontSize;
  final EdgeInsets? padding;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = ArcadeColors.cyan,
    this.filled = true,
    this.fullWidth = false,
    this.fontSize = 9,
    this.padding,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp:   (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
          child: AnimatedContainer(
            duration: 150.ms,
            width: widget.fullWidth ? double.infinity : null,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.filled ? c : Colors.transparent,
              border: Border.all(color: c, width: 1.5),
              boxShadow: [
                BoxShadow(color: c.withOpacity(_hovered ? 0.5 : 0.25), blurRadius: _hovered ? 18 : 8),
                BoxShadow(color: c.withOpacity(_hovered ? 0.15 : 0.05), blurRadius: 40),
              ],
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.filled ? ArcadeColors.void_ : c, size: 16),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: ArcadeFonts.pixel(
                    size: widget.fontSize,
                    color: widget.filled ? ArcadeColors.void_ : c,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ARCADE CARD ───
class ArcadeCard extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool glowing;

  const ArcadeCard({
    super.key,
    required this.child,
    this.borderColor = ArcadeColors.borderDefault,
    this.padding,
    this.onTap,
    this.glowing = false,
  });

  @override
  State<ArcadeCard> createState() => _ArcadeCardState();
}

class _ArcadeCardState extends State<ArcadeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bc = widget.glowing ? widget.borderColor : (_hovered ? widget.borderColor : ArcadeColors.borderDefault);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ArcadeColors.panel,
            border: Border.all(color: bc, width: 1),
            boxShadow: widget.glowing || _hovered ? [
              BoxShadow(color: widget.borderColor.withOpacity(0.25), blurRadius: 16),
            ] : [],
          ),
          child: widget.glowing
            ? Stack(children: [
                widget.child,
                Positioned(top: 0, left: 0, right: 0, child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      widget.borderColor.withOpacity(0.8),
                      Colors.transparent,
                    ]),
                  ),
                )),
              ])
            : widget.child,
        ),
      ),
    );
  }
}

// ─── STAT CARD ───
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      borderColor: color,
      glowing: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: ArcadeFonts.pixel(
            size: 22, color: color,
          ).copyWith(shadows: [
            Shadow(color: color.withOpacity(0.8), blurRadius: 10),
            Shadow(color: color.withOpacity(0.4), blurRadius: 20),
          ])),
          const SizedBox(height: 8),
          Text(label, style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim, letterSpacing: 0.1)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

// ─── PROGRESS BAR ───
class NeonProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double height;
  const NeonProgressBar({
    super.key,
    required this.value,
    this.color = ArcadeColors.cyan,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      return Container(
        height: height,
        color: ArcadeColors.textGhost,
        child: Stack(children: [
          AnimatedContainer(
            duration: 600.ms,
            curve: Curves.easeOut,
            width: w * value.clamp(0.0, 1.0),
            height: height,
            color: color,
            foregroundDecoration: BoxDecoration(
              boxShadow: [BoxShadow(color: color, blurRadius: 6)],
            ),
          ),
        ]),
      );
    });
  }
}

// ─── BADGE ───
class ArcadeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const ArcadeBadge(this.label, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(label, style: ArcadeFonts.pixel(size: 7, color: color)),
    );
  }
}

// ─── NEON DIVIDER ───
class NeonDivider extends StatelessWidget {
  final Color color;
  const NeonDivider({super.key, this.color = ArcadeColors.cyan});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          color.withOpacity(0.8),
          Colors.transparent,
        ]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
      ),
    );
  }
}

// ─── NEON INPUT ───
class NeonTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Color accentColor;
  final VoidCallback? onEditingComplete;

  const NeonTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.accentColor = ArcadeColors.cyan,
    this.onEditingComplete,
  });

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  bool _focused = false;
  bool _showPass = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() { _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.accentColor;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim, letterSpacing: 0.1)),
      const SizedBox(height: 6),
      AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: ArcadeColors.pit,
          border: Border.all(
            color: _focused ? c : ArcadeColors.borderDefault,
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused ? [
            BoxShadow(color: c.withOpacity(0.25), blurRadius: 12),
          ] : [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscure && !_showPass,
          keyboardType: widget.keyboardType,
          onEditingComplete: widget.onEditingComplete,
          style: ArcadeFonts.mono(size: 15, color: ArcadeColors.textBright),
          cursorColor: c,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: ArcadeFonts.mono(size: 14, color: ArcadeColors.textGhost),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: _focused ? c : ArcadeColors.textDim, size: 18)
                : null,
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () => setState(() => _showPass = !_showPass),
                    child: Icon(
                      _showPass ? Icons.visibility_off : Icons.visibility,
                      color: ArcadeColors.textDim, size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    ]);
  }
}

// ─── BLINKING CURSOR ───
class BlinkingCursor extends StatefulWidget {
  final Color color;
  const BlinkingCursor({super.key, this.color = ArcadeColors.cyan});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 800.ms)..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: _ctrl.value > 0.5 ? 1 : 0,
      child: Container(
        width: 8, height: 16,
        color: widget.color,
      ),
    ),
  );
}

// ─── PARTICLES ───
class ParticleLayer extends StatefulWidget {
  final int count;
  const ParticleLayer({super.key, this.count = 25});
  @override
  State<ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<ParticleLayer>
    with TickerProviderStateMixin {
  final List<_ParticleData> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    for (int i = 0; i < widget.count; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(seconds: 6 + _random.nextInt(6)),
      )..repeat();
      _particles.add(_ParticleData(
        ctrl: ctrl,
        x: _random.nextDouble(),
        size: 1.0 + _random.nextDouble() * 1.5,
        color: [ArcadeColors.cyan, ArcadeColors.pink, ArcadeColors.green][_random.nextInt(3)],
        delay: _random.nextDouble(),
      ));
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final p in _particles) p.ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: _particles.map((p) => AnimatedBuilder(
          animation: p.ctrl,
          builder: (_, __) {
            final t = (p.ctrl.value + p.delay) % 1.0;
            final opacity = t < 0.1 ? t * 10 : (t > 0.9 ? (1 - t) * 10 : 0.7);
            return Positioned(
              left: p.x * constraints.maxWidth,
              bottom: t * constraints.maxHeight,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: p.size, height: p.size,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: p.color.withOpacity(0.8), blurRadius: 4)],
                  ),
                ),
              ),
            );
          },
        )).toList(),
      );
    }),
  );
}

class _ParticleData {
  final AnimationController ctrl;
  final double x, size, delay;
  final Color color;
  _ParticleData({required this.ctrl, required this.x, required this.size, required this.color, required this.delay});
}

// ─── CORNER DECORATIONS ───
class CornerDecorated extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;

  const CornerDecorated({
    super.key,
    required this.child,
    this.color = ArcadeColors.cyan,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      // Top-left
      Positioned(top: 0, left: 0, child: _Corner(color: color, size: size, flip: false)),
      // Top-right
      Positioned(top: 0, right: 0, child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159),
        child: _Corner(color: color, size: size, flip: false),
      )),
      // Bottom-left
      Positioned(bottom: 0, left: 0, child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.14159),
        child: _Corner(color: color, size: size, flip: false),
      )),
      // Bottom-right
      Positioned(bottom: 0, right: 0, child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationX(3.14159),
          child: _Corner(color: color, size: size, flip: false),
        ),
      )),
    ]);
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size;
  final bool flip;
  const _Corner({required this.color, required this.size, required this.flip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CornerPainter(color: color),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}
