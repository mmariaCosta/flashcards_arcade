import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/arcade_theme.dart';
import '../widgets/arcade_widgets.dart';
import '../models/models.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StudyScreen extends StatefulWidget {
  final Deck deck;
  final AppState appState;

  const StudyScreen({super.key, required this.deck, required this.appState});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late StudySession _session;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showRating = false;
  int? _lastRating;

  late AnimationController _xpCtrl;
  String _xpText = '';

  @override
  void initState() {
    super.initState();
    _session = StudySession(deck: widget.deck);

    _flipCtrl = AnimationController(vsync: this, duration: 400.ms);
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));

    _xpCtrl = AnimationController(vsync: this, duration: 1200.ms);

    _initTts();
  }

  Future<void> _initTts() async {
    // Força o uso do engine Google TTS no Android (muito mais natural que o Pico TTS padrão)
    await _tts.setEngine('com.google.android.tts');

    await _tts.setSharedInstance(true);
    await _tts.awaitSpeakCompletion(true);

    // Velocidade natural — 0.4 soa robótico, 0.9 soa humano
    await _tts.setSpeechRate(0.9);

    // Pitch levemente acima do neutro dá mais naturalidade
    await _tts.setPitch(1.1);

    // Volume máximo
    await _tts.setVolume(1.0);

    // Linguagem padrão enquanto não há card selecionado
    await _tts.setLanguage('en-US');
  }

  Future<void> _speak(String text, String lang) async {
    // Para qualquer fala anterior antes de começar nova
    await _tts.stop();

    await _tts.setLanguage(lang);
    await _tts.speak(text);
  }

  String _getLangCode(String lang) {
    switch (lang.toLowerCase()) {
      case 'english':   return 'en-US';
      case 'spanish':   return 'es-ES';
      case 'japanese':  return 'ja-JP';
      case 'french':    return 'fr-FR';
      case 'german':    return 'de-DE';
      case 'portuguese': return 'pt-BR';
      default:          return 'en-US';
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _flipCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  void _flip() async {
    if (_session.isFlipped) return;

    HapticFeedback.lightImpact();

    final card = _session.current;

    if (card != null) {
      _speak(card.back, _getLangCode(card.language));
    }

    _flipCtrl.forward();
    setState(() {
      _session.flip();
      _showRating = true;
    });
  }

  void _rate(int rating) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastRating = rating;
      _session.rate(rating);
      _showRating = false;
    });

    final xp = rating == 4 ? 20 : rating == 3 ? 10 : 5;
    _showXP(xp, rating >= 3);
    widget.appState.addXP(xp);
    widget.appState.cardsStudiedToday++;

    await _flipCtrl.reverse();
    setState(() {});
  }

  void _showXP(int xp, bool correct) {
    setState(() => _xpText = correct ? '+$xp XP' : '+$xp XP');
    _xpCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isComplete) return _buildComplete();

    return Scaffold(
      backgroundColor: ArcadeColors.void_,
      body: Stack(children: [
        const GridBackground(child: SizedBox.expand()),

        SafeArea(
          child: Column(children: [
            _buildTopBar(),
            _buildProgressArea(),
            const SizedBox(height: 20),
            Expanded(child: _buildCardArea()),
            _buildBottomControls(),
            const SizedBox(height: 16),
          ]),
        ),

        _buildXPPopup(),

        const ScanlinesOverlay(child: SizedBox.expand()),
      ]),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            _tts.stop();
            Navigator.pop(context);
          },
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: ArcadeColors.textGhost),
              color: ArcadeColors.panel,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: ArcadeColors.textMid, size: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: NeonText(
          widget.deck.name.toUpperCase(),
          color: ArcadeColors.textMid, isPixel: true, size: 8,
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: ArcadeColors.cyan.withOpacity(0.4)),
            color: ArcadeColors.cyanDim,
          ),
          child: Text(
            '${_session.currentIndex + 1}/${_session.total}',
            style: ArcadeFonts.pixel(size: 8, color: ArcadeColors.cyan),
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        NeonProgressBar(value: _session.progress, color: ArcadeColors.cyan, height: 4),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 8, height: 8, color: ArcadeColors.green),
            const SizedBox(width: 4),
            Text('${_session.correct} CORRETOS',
              style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.green)),
          ]),
          Row(children: [
            Container(width: 8, height: 8, color: ArcadeColors.red),
            const SizedBox(width: 4),
            Text('${_session.wrong} ERROS',
              style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.red)),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildCardArea() {
    final card = _session.current;
    if (card == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _session.isFlipped ? null : _flip,
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, __) {
            final angle = _flipAnim.value * pi;
            final isBack = angle > pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildCardFace(
                      content: card.back,
                      label: card.language.toUpperCase(),
                      color: ArcadeColors.pink,
                      isBack: true,
                      language: card.language,
                    ),
                  )
                : _buildCardFace(
                    content: card.front,
                    label: 'PORTUGUÊS',
                    color: ArcadeColors.cyan,
                    isBack: false,
                    language: 'portuguese',
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required String content,
    required String label,
    required Color color,
    required bool isBack,
    required String language,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ArcadeColors.panel,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.35), blurRadius: 20),
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 50),
        ],
      ),
      child: Stack(children: [
        CornerDecorated(
          color: color,
          size: 16,
          child: const SizedBox.expand(),
        ),

        // Botão de áudio — para o card já virado, permite ouvir de novo
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.volume_up, color: color),
            onPressed: () => _speak(content, _getLangCode(language)),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArcadeBadge(label, color: color),
              const SizedBox(height: 28),

              Text(
                content,
                style: ArcadeFonts.vt323(size: 48, color: ArcadeColors.textBright)
                    .copyWith(shadows: [
                  Shadow(color: color.withOpacity(0.6), blurRadius: 12),
                ]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              if (!isBack) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20, height: 1, color: ArcadeColors.textGhost),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'TOQUE PARA VER',
                        style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.textGhost),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                    ),
                    Container(width: 20, height: 1, color: ArcadeColors.textGhost),
                  ],
                ),
              ],
            ],
          ),
        ),

        Positioned(bottom: 12, right: 14, child: Text(
          isBack ? '◀ FRENTE' : 'VIRAR ▶',
          style: ArcadeFonts.pixel(size: 5.5, color: color.withOpacity(0.5)),
        )),
      ]),
    );
  }

  Widget _buildBottomControls() {
    if (!_showRating) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeonButton(
          label: 'VIRAR CARD',
          color: ArcadeColors.cyan,
          fullWidth: true,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(vertical: 16),
          onTap: _flip,
        ).animate().fadeIn(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Text('COMO FOI?', style: ArcadeFonts.pixel(
          size: 7, color: ArcadeColors.textDim, letterSpacing: 0.2)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _RatingButton(
            label: 'ERREI', sub: '1 min',
            color: ArcadeColors.red, rating: 1, onTap: _rate,
          )),
          const SizedBox(width: 8),
          Expanded(child: _RatingButton(
            label: 'DIFÍCIL', sub: '10 min',
            color: ArcadeColors.orange, rating: 2, onTap: _rate,
          )),
          const SizedBox(width: 8),
          Expanded(child: _RatingButton(
            label: 'BOM', sub: '1 dia',
            color: ArcadeColors.cyan, rating: 3, onTap: _rate,
          )),
          const SizedBox(width: 8),
          Expanded(child: _RatingButton(
            label: 'FÁCIL', sub: '4 dias',
            color: ArcadeColors.green, rating: 4, onTap: _rate,
          )),
        ]),
      ]).animate().slideY(begin: 0.3, end: 0, duration: 300.ms).fadeIn(),
    );
  }

  Widget _buildXPPopup() {
    return AnimatedBuilder(
      animation: _xpCtrl,
      builder: (_, __) {
        if (_xpCtrl.value == 0) return const SizedBox.shrink();
        final t = _xpCtrl.value;
        final opacity = t < 0.3 ? t / 0.3 : (t > 0.7 ? (1 - t) / 0.3 : 1.0);
        final yOffset = -80 * t;
        return Positioned(
          top: 100 + yOffset,
          right: 24,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Text(
              _xpText,
              style: ArcadeFonts.pixel(size: 12, color: ArcadeColors.yellow)
                  .copyWith(shadows: ArcadeGlow.yellow()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplete() {
    final accuracy = _session.total > 0
        ? (_session.correct / _session.total * 100).round()
        : 0;

    Color resultColor;
    String resultLabel;
    if (accuracy >= 80) { resultColor = ArcadeColors.green; resultLabel = 'EXCELENTE!'; }
    else if (accuracy >= 60) { resultColor = ArcadeColors.yellow; resultLabel = 'BOM!'; }
    else { resultColor = ArcadeColors.red; resultLabel = 'PRATIQUE MAIS'; }

    return Scaffold(
      backgroundColor: ArcadeColors.void_,
      body: Stack(children: [
        const GridBackground(child: SizedBox.expand()),
        const ParticleLayer(count: 30),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SESSION CLEAR!', style: ArcadeFonts.pixel(
                  size: 18, color: resultColor,
                ).copyWith(shadows: [
                  Shadow(color: resultColor.withOpacity(0.9), blurRadius: 8),
                  Shadow(color: resultColor.withOpacity(0.4), blurRadius: 20),
                ])).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 8),
                Text(resultLabel, style: ArcadeFonts.pixel(size: 10, color: ArcadeColors.textMid))
                    .animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 40),

                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: resultColor, width: 3),
                    boxShadow: [BoxShadow(color: resultColor.withOpacity(0.4), blurRadius: 30)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$accuracy%', style: ArcadeFonts.pixel(size: 24, color: resultColor)
                          .copyWith(shadows: [Shadow(color: resultColor, blurRadius: 10)])),
                      Text('ACURÁCIA', style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.textDim)),
                    ],
                  ),
                ).animate(delay: 400.ms).scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 40),

                Row(children: [
                  Expanded(child: _ResultStat(
                    value: '${_session.correct}', label: 'CORRETOS', color: ArcadeColors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _ResultStat(
                    value: '${_session.wrong}', label: 'ERROS', color: ArcadeColors.red)),
                  const SizedBox(width: 12),
                  Expanded(child: _ResultStat(
                    value: '${_session.total}', label: 'TOTAL', color: ArcadeColors.cyan)),
                ]).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),

                NeonButton(
                  label: 'CONTINUAR >>',
                  color: ArcadeColors.cyan,
                  fullWidth: true,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onTap: () => Navigator.pop(context),
                ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
        const ScanlinesOverlay(child: SizedBox.expand()),
      ]),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  final int rating;
  final void Function(int) onTap;

  const _RatingButton({
    required this.label, required this.sub,
    required this.color, required this.rating, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(rating),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: ArcadeFonts.pixel(size: 6.5, color: color)),
          const SizedBox(height: 3),
          Text(sub, style: ArcadeFonts.mono(size: 10, color: color.withOpacity(0.6))),
        ]),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ResultStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => ArcadeCard(
    borderColor: color,
    glowing: true,
    child: Column(children: [
      Text(value, style: ArcadeFonts.pixel(size: 20, color: color)
          .copyWith(shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 10)])),
      const SizedBox(height: 6),
      Text(label, style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.textDim)),
    ]),
  );
}