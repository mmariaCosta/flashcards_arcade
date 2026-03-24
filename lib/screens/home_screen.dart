import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/arcade_theme.dart';
import '../widgets/arcade_widgets.dart';
import '../models/models.dart';
import 'study_screen.dart';
import 'decks_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  final _appState = AppState.demo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArcadeColors.void_,
      body: Stack(children: [
        const GridBackground(child: SizedBox.expand()),
        const ParticleLayer(count: 15),

        SafeArea(
          child: IndexedStack(
            index: _tab,
            children: [
              _DashboardTab(appState: _appState, onStartStudy: _goStudy),
              DecksScreen(appState: _appState, onStartStudy: _goStudy),
              StatsScreen(appState: _appState),
            ],
          ),
        ),

        // ── BOTTOM NAV ──
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _ArcadeNavBar(
            selected: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        ),

        const ScanlinesOverlay(child: SizedBox.expand()),
      ]),
    );
  }

  void _goStudy(Deck deck) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => StudyScreen(deck: deck, appState: _appState),
      transitionDuration: 500.ms,
      transitionsBuilder: (_, anim, __, child) =>
        SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
    ));
  }
}

// ─── BOTTOM NAV BAR ───
class _ArcadeNavBar extends StatelessWidget {
  final int selected;
  final void Function(int) onTap;

  const _ArcadeNavBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.grid_view_rounded, 'label': 'HOME'},
      {'icon': Icons.style_rounded, 'label': 'DECKS'},
      {'icon': Icons.bar_chart_rounded, 'label': 'STATS'},
    ];

    final colors = [ArcadeColors.cyan, ArcadeColors.pink, ArcadeColors.green];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: ArcadeColors.void_,
      ),
      child: Row(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final isSelected = selected == i;
          final c = colors[i];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: 200.ms,
                color: isSelected ? c.withOpacity(0.06) : Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: 200.ms,
                      width: isSelected ? 40 : 36,
                      height: isSelected ? 40 : 36,
                      decoration: isSelected
                          ? BoxDecoration(
                              border: Border.all(color: c.withOpacity(0.4), width: 1),
                              color: c.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(color: c.withOpacity(0.3), blurRadius: 12)
                              ],
                            )
                          : null,
                      child: Icon(
                        e.value['icon'] as IconData,
                        color: isSelected ? c : ArcadeColors.textDim,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 3),

                    AnimatedDefaultTextStyle(
                      duration: 200.ms,
                      style: ArcadeFonts.pixel(
                        size: 5.5,
                        color: isSelected ? c : ArcadeColors.textDim,
                      ),
                      child: Text(e.value['label'] as String),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── DASHBOARD TAB ───
class _DashboardTab extends StatelessWidget {
  final AppState appState;
  final void Function(Deck) onStartStudy;

  const _DashboardTab({required this.appState, required this.onStartStudy});

  @override
  Widget build(BuildContext context) {
    final dueDecks = appState.decks.where((d) => d.dueToday > 0).toList();

    return CustomScrollView(
      slivers: [
        // ── HEADER ──
        SliverToBoxAdapter(child: _buildHeader()),

        // ── STATS ROW ──
        SliverToBoxAdapter(child: _buildStats()),

        // ── DAILY PROGRESS ──
        SliverToBoxAdapter(child: _buildDailyProgress()),

        // ── DUE DECKS ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            NeonText('REVISAR AGORA', color: ArcadeColors.textMid, isPixel: true, size: 8),
            const SizedBox(width: 8),
            ArcadeBadge('${appState.totalDue}', color: ArcadeColors.pink),
          ]),
        )),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DeckReviewCard(
                deck: dueDecks[i],
                onTap: () => onStartStudy(dueDecks[i]),
              ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1, end: 0),
            ),
            childCount: dueDecks.length,
          )),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OLÁ,', style: ArcadeFonts.pixel(size: 8, color: ArcadeColors.textDim)),
            const SizedBox(height: 4),
            NeonText(
              appState.playerName,
              size: 16, color: ArcadeColors.cyan, isPixel: true,
            ),
          ]),
        ),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: ArcadeColors.yellowDim,
            border: Border.all(color: ArcadeColors.yellow.withOpacity(0.5)),
            boxShadow: ArcadeGlow.boxCyan(intensity: 0.3),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('🔥', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              NeonText('${appState.streak}', color: ArcadeColors.yellow, size: 18, isPixel: false),
              Text('STREAK', style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.textDim)),
            ]),
          ]),
        ).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Expanded(child: StatCard(
          value: '${appState.cardsStudiedToday}',
          label: 'HOJE',
          color: ArcadeColors.cyan,
          subtitle: '/ ${appState.dailyGoalCards} meta',
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          value: '${appState.totalCards}',
          label: 'CARDS',
          color: ArcadeColors.pink,
          subtitle: '${appState.decks.length} decks',
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          value: 'LV${appState.level}',
          label: 'NÍVEL',
          color: ArcadeColors.yellow,
          subtitle: '${appState.totalXP} XP',
        )),
      ]),
    );
  }

  Widget _buildDailyProgress() {
    final progress = appState.cardsStudiedToday / appState.dailyGoalCards;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ArcadeCard(
        borderColor: ArcadeColors.cyan,
        glowing: progress >= 1.0,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('META DIÁRIA', style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
            Text('${(progress * 100).round()}%',
              style: ArcadeFonts.pixel(size: 9, color: ArcadeColors.cyan)
                  .copyWith(shadows: ArcadeGlow.cyan())),
          ]),
          const SizedBox(height: 12),
          NeonProgressBar(value: progress, color: ArcadeColors.cyan, height: 6),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${appState.cardsStudiedToday} estudados',
              style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
            Text('${appState.dailyGoalCards - appState.cardsStudiedToday} restantes',
              style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
          ]),
        ]),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

// ─── DECK REVIEW CARD ───
class _DeckReviewCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;

  const _DeckReviewCard({required this.deck, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [ArcadeColors.cyan, ArcadeColors.pink, ArcadeColors.green, ArcadeColors.yellow];
    final color = colors[deck.name.hashCode.abs() % colors.length];

    return ArcadeCard(
      borderColor: color,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Row(children: [
        // Color strip — color moved inside BoxDecoration
        Container(
          width: 4,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 14),

        // Emoji
        Text(deck.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),

        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(deck.name, style: ArcadeFonts.pixel(size: 9, color: ArcadeColors.textBright)),
            const SizedBox(height: 4),
            Row(children: [
              ArcadeBadge('${deck.dueToday} DUE', color: color),
              const SizedBox(width: 6),
              ArcadeBadge(deck.language.toUpperCase(), color: ArcadeColors.textDim),
            ]),
          ],
        )),

        // Start button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: NeonButton(
            label: 'JOGAR',
            color: color,
            fontSize: 7,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            onTap: onTap,
          ),
        ),
      ]),
    );
  }
}