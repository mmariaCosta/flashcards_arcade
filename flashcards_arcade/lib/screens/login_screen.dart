import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/arcade_theme.dart';
import '../widgets/arcade_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  late AnimationController _logoCtrl;
  late Animation<double> _logoPulse;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _logoPulse = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArcadeColors.void_,
      body: Stack(children: [
        // Background
        const GridBackground(child: SizedBox.expand()),
        const ParticleLayer(count: 20),

        // Main content
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 48),

                // ── LOGO ──
                _buildLogo(),

                const SizedBox(height: 48),

                // ── TAB SWITCHER ──
                _buildTabSwitcher(),

                const SizedBox(height: 32),

                // ── FORM ──
                _buildForm(),

                const SizedBox(height: 24),

                // ── DIVIDER ──
                _buildOrDivider(),

                const SizedBox(height: 20),

                // ── DEMO BUTTON ──
                NeonButton(
                  label: 'JOGAR SEM CONTA',
                  color: ArcadeColors.yellow,
                  filled: false,
                  fullWidth: true,
                  onTap: _submit,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 48),

                // ── INSERT COIN ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NeonText(
                      '— INSERT COIN —',
                      color: ArcadeColors.textGhost,
                      isPixel: true,
                      size: 7,
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(duration: 800.ms)
                        .then()
                        .fadeOut(duration: 800.ms),
                  ],
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),

        // Loading overlay
        if (_loading) _buildLoadingOverlay(),

        // CRT overlay
        const ScanlinesOverlay(child: SizedBox.expand()),
      ]),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoPulse,
      builder: (_, __) => Column(children: [
        // Pixel logo icon
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            border: Border.all(color: ArcadeColors.cyan, width: 2),
            color: ArcadeColors.cyanDim,
            boxShadow: ArcadeGlow.boxCyan(intensity: _logoPulse.value),
          ),
          child: Center(
            child: Text('FC', style: ArcadeFonts.pixel(
              size: 20, color: ArcadeColors.cyan,
            ).copyWith(shadows: ArcadeGlow.cyan(intensity: _logoPulse.value))),
          ),
        ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 20),

        Text(
          'FLASHCARDS',
          style: ArcadeFonts.pixel(size: 18, color: ArcadeColors.cyan)
              .copyWith(shadows: ArcadeGlow.cyan(intensity: _logoPulse.value)),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),

        const SizedBox(height: 6),

        Text(
          'ARCADE EDITION',
          style: ArcadeFonts.pixel(size: 8, color: ArcadeColors.pink)
              .copyWith(shadows: ArcadeGlow.pink()),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 12),

        // Stars row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text('★',
              style: ArcadeFonts.vt323(size: 20, color: ArcadeColors.yellow)
                  .copyWith(shadows: ArcadeGlow.yellow()),
            ),
          ).animate(delay: (500 + i * 80).ms).fadeIn().scale(begin: const Offset(0, 0))),
        ),
      ]),
    );
  }

  Widget _buildTabSwitcher() {
    return Row(children: [
      Expanded(child: GestureDetector(
        onTap: () => setState(() => _isLogin = true),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _isLogin ? ArcadeColors.cyan : ArcadeColors.textGhost,
                width: 2,
              ),
            ),
          ),
          child: Text('LOGIN', textAlign: TextAlign.center,
            style: ArcadeFonts.pixel(
              size: 9,
              color: _isLogin ? ArcadeColors.cyan : ArcadeColors.textDim,
            ).copyWith(shadows: _isLogin ? ArcadeGlow.cyan() : null)),
        ),
      )),
      Expanded(child: GestureDetector(
        onTap: () => setState(() => _isLogin = false),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: !_isLogin ? ArcadeColors.pink : ArcadeColors.textGhost,
                width: 2,
              ),
            ),
          ),
          child: Text('CADASTRO', textAlign: TextAlign.center,
            style: ArcadeFonts.pixel(
              size: 9,
              color: !_isLogin ? ArcadeColors.pink : ArcadeColors.textDim,
            ).copyWith(shadows: !_isLogin ? ArcadeGlow.pink() : null)),
        ),
      )),
    ]).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildForm() {
    return Column(children: [
      NeonTextField(
        label: 'EMAIL',
        hint: 'jogador@email.com',
        controller: _emailCtrl,
        prefixIcon: Icons.alternate_email,
        keyboardType: TextInputType.emailAddress,
        accentColor: ArcadeColors.cyan,
      ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1, end: 0),

      const SizedBox(height: 16),

      NeonTextField(
        label: 'SENHA',
        hint: '••••••••',
        controller: _passCtrl,
        obscure: true,
        prefixIcon: Icons.lock_outline,
        accentColor: ArcadeColors.cyan,
        onEditingComplete: _submit,
      ).animate().fadeIn(delay: 420.ms).slideX(begin: -0.1, end: 0),

      if (!_isLogin) ...[
        const SizedBox(height: 16),
        NeonTextField(
          label: 'CONFIRMAR SENHA',
          hint: '••••••••',
          obscure: true,
          prefixIcon: Icons.lock_outline,
          accentColor: ArcadeColors.pink,
        ).animate().fadeIn(delay: 490.ms).slideX(begin: -0.1, end: 0),
      ],

      const SizedBox(height: 24),

      NeonButton(
        label: _isLogin ? 'ENTRAR  >>' : 'CRIAR CONTA >>',
        color: ArcadeColors.cyan,
        fullWidth: true,
        onTap: _submit,
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

      if (_isLogin) ...[
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () {},
            child: Text('ESQUECI A SENHA',
              style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    ]);
  }

  Widget _buildOrDivider() {
    return Row(children: [
      const Expanded(child: NeonDivider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('OU', style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
      ),
      const Expanded(child: NeonDivider()),
    ]).animate().fadeIn(delay: 550.ms);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LOADING...', style: ArcadeFonts.pixel(
              size: 14, color: ArcadeColors.cyan,
            ).copyWith(shadows: ArcadeGlow.cyan()))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: Container(
                height: 4,
                color: ArcadeColors.textGhost,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(height: 4, color: ArcadeColors.cyan,
                    decoration: BoxDecoration(boxShadow: ArcadeGlow.boxCyan()),
                  ).animate().custom(
                    duration: 1200.ms,
                    builder: (context, value, child) => FractionallySizedBox(
                      widthFactor: value, child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
