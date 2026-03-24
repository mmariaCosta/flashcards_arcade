import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/arcade_theme.dart';
import '../widgets/arcade_widgets.dart';
import '../models/models.dart';

class StatsScreen extends StatelessWidget {
  final AppState appState;

  const StatsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: NeonText('ESTATÍSTICAS', color: ArcadeColors.green, isPixel: true, size: 11),
        )),

        // Top stats
        SliverToBoxAdapter(child: _buildTopStats()),

        // Level section
        SliverToBoxAdapter(child: _buildLevelCard()),

        // Bar chart
        SliverToBoxAdapter(child: _buildBarChart()),

        // Per-deck stats
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: NeonText('POR DECK', color: ArcadeColors.textDim, isPixel: true, size: 8),
        )),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DeckStatCard(deck: appState.decks[i])
                  .animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1),
            ),
            childCount: appState.decks.length,
          )),
        ),
      ],
    );
  }

  Widget _buildTopStats() {
    final totalReviews = appState.decks.fold(0, (sum, d) =>
        sum + d.cards.fold(0, (s, c) => s + c.totalReviews));
    final globalAccuracy = appState.totalCards > 0
        ? (appState.decks.fold(0.0, (sum, d) => sum + d.accuracy) / appState.decks.length * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(children: [
          Expanded(child: StatCard(
            value: '${appState.streak}🔥',
            label: 'STREAK',
            color: ArcadeColors.yellow,
          )),
          const SizedBox(width: 10),
          Expanded(child: StatCard(
            value: '${appState.totalXP}',
            label: 'TOTAL XP',
            color: ArcadeColors.purple,
          )),
        ]).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: StatCard(
            value: '$totalReviews',
            label: 'REVISÕES',
            color: ArcadeColors.cyan,
          )),
          const SizedBox(width: 10),
          Expanded(child: StatCard(
            value: '$globalAccuracy%',
            label: 'ACURÁCIA',
            color: ArcadeColors.green,
          )),
        ]).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }

  Widget _buildLevelCard() {
    final xpForNext = (appState.level) * 500;
    final xpInLevel = appState.totalXP - (appState.level - 1) * 500;
    final progress = (xpInLevel / xpForNext).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ArcadeCard(
        borderColor: ArcadeColors.purple,
        glowing: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NÍVEL', style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
                const SizedBox(height: 4),
                NeonText('${appState.level}', color: ArcadeColors.purple, isPixel: true, size: 28),
              ]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ArcadeColors.purpleDim,
                  border: Border.all(color: ArcadeColors.purple.withOpacity(0.5)),
                ),
                child: Text('LV${appState.level}',
                  style: ArcadeFonts.pixel(size: 14, color: ArcadeColors.purple)
                    .copyWith(shadows: ArcadeGlow.purple())
              ),)
            ]),
            const SizedBox(height: 16),
            NeonProgressBar(value: progress, color: ArcadeColors.purple, height: 6),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$xpInLevel XP', style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
              Text('$xpForNext XP para LV${appState.level + 1}',
                style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
            ]),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildBarChart() {
    // Simulated 7-day study data
    final weekData = [8, 15, 12, 20, 6, 18, appState.cardsStudiedToday];
    final days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'HOJ'];
    final maxY = weekData.reduce((a, b) => a > b ? a : b).toDouble() + 5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: ArcadeCard(
        borderColor: ArcadeColors.cyan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('ÚLTIMOS 7 DIAS', style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
              ArcadeBadge('CARDS/DIA', color: ArcadeColors.cyan),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  backgroundColor: Colors.transparent,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: ArcadeColors.textGhost,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: ArcadeColors.textGhost),
                      left: BorderSide(color: ArcadeColors.textGhost),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(days[value.toInt() % days.length],
                          style: ArcadeFonts.pixel(size: 5.5, color: ArcadeColors.textDim)),
                      ),
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: ArcadeFonts.mono(size: 9, color: ArcadeColors.textGhost),
                      ),
                    )),
                  ),
                  barGroups: List.generate(7, (i) {
                    final isToday = i == 6;
                    final color = isToday ? ArcadeColors.cyan : ArcadeColors.cyan.withOpacity(0.4);
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: weekData[i].toDouble(),
                        color: color,
                        width: 20,
                        borderRadius: BorderRadius.zero,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: ArcadeColors.textGhost.withOpacity(0.2),
                        ),
                        rodStackItems: [],
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms),
    );
  }
}

class _DeckStatCard extends StatelessWidget {
  final Deck deck;
  const _DeckStatCard({required this.deck});

  @override
  Widget build(BuildContext context) {
    final accuracy = deck.accuracy;
    final accuracyColor = accuracy >= 0.8
        ? ArcadeColors.green
        : accuracy >= 0.6
            ? ArcadeColors.yellow
            : ArcadeColors.red;

    return ArcadeCard(
      borderColor: ArcadeColors.borderDefault,
      child: Column(children: [
        Row(children: [
          Text(deck.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(deck.name,
            style: ArcadeFonts.pixel(size: 8, color: ArcadeColors.textBright))),
          Text('${(accuracy * 100).round()}%',
            style: ArcadeFonts.pixel(size: 10, color: accuracyColor)
                .copyWith(shadows: [Shadow(color: accuracyColor.withOpacity(0.7), blurRadius: 6)])),
        ]),
        const SizedBox(height: 10),
        NeonProgressBar(value: accuracy, color: accuracyColor, height: 4),
        const SizedBox(height: 8),
        Row(children: [
          _Chip('${deck.totalCards} cards', ArcadeColors.textDim),
          const SizedBox(width: 8),
          _Chip('${deck.newCards} novos', ArcadeColors.cyan),
          const SizedBox(width: 8),
          _Chip('${deck.dueToday} pendentes', ArcadeColors.pink),
        ]),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    color: color.withOpacity(0.1),
    child: Text(label, style: ArcadeFonts.mono(size: 10, color: color)),
  );
}
