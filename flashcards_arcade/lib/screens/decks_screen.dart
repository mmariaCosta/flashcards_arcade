import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/arcade_theme.dart';
import '../widgets/arcade_widgets.dart';
import '../models/models.dart';

class DecksScreen extends StatefulWidget {
  final AppState appState;
  final void Function(Deck) onStartStudy;

  const DecksScreen({super.key, required this.appState, required this.onStartStudy});

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  bool _showCreate = false;
  final _nameCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final _cardsCtrl = TextEditingController();
  String _selectedEmoji = '📚';

  final _emojis = ['📚', '🇺🇸', '🇯🇵', '🇪🇸', '🇫🇷', '🇩🇪', '🇮🇹', '🇰🇷', '🇧🇷', '🌍', '⭐', '🎯'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _langCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  void _createDeck() {
    final name = _nameCtrl.text.trim();
    final lang = _langCtrl.text.trim();
    final raw = _cardsCtrl.text.trim();

    if (name.isEmpty || lang.isEmpty || raw.isEmpty) return;

    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final cards = <Flashcard>[];
    for (int i = 0; i + 1 < lines.length; i += 2) {
      cards.add(Flashcard(
        front: lines[i].trim(),
        back: lines[i + 1].trim(),
        language: lang,
      ));
    }

    if (cards.isEmpty) return;

    setState(() {
      widget.appState.decks.add(Deck(
        name: name,
        description: '$lang — ${cards.length} cards',
        language: lang,
        emoji: _selectedEmoji,
        cards: cards,
      ));
      _showCreate = false;
      _nameCtrl.clear();
      _langCtrl.clear();
      _cardsCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showCreate ? _buildCreateForm() : _buildDeckList();
  }

  Widget _buildDeckList() {
    final decks = widget.appState.decks;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeonText('MEUS DECKS', color: ArcadeColors.cyan, isPixel: true, size: 11),
              NeonButton(
                label: '+ NOVO',
                color: ArcadeColors.pink,
                filled: false,
                fontSize: 7,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onTap: () => setState(() => _showCreate = true),
              ),
            ],
          ),
        )),

        if (decks.isEmpty)
          SliverToBoxAdapter(child: _buildEmpty())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FullDeckCard(
                  deck: decks[i],
                  onStudy: () => widget.onStartStudy(decks[i]),
                  onDelete: () => setState(() => widget.appState.decks.removeAt(i)),
                ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1, end: 0),
              ),
              childCount: decks.length,
            )),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text('📦', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          NeonText('NENHUM DECK', color: ArcadeColors.textDim, isPixel: true, size: 10, align: TextAlign.center),
          const SizedBox(height: 16),
          NeonButton(
            label: 'CRIAR PRIMEIRO DECK',
            color: ArcadeColors.pink,
            onTap: () => setState(() => _showCreate = true),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _showCreate = false),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: ArcadeColors.textGhost),
                color: ArcadeColors.panel,
              ),
              child: const Icon(Icons.close, color: ArcadeColors.textMid, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          NeonText('CRIAR DECK', color: ArcadeColors.pink, isPixel: true, size: 11),
        ]),

        const SizedBox(height: 28),

        // Emoji picker
        Text('ÍCONE', style: ArcadeFonts.pixel(size: 7, color: ArcadeColors.textDim)),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _emojis.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final e = _emojis[i];
              final sel = e == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: sel ? ArcadeColors.pinkDim : ArcadeColors.panel,
                    border: Border.all(
                      color: sel ? ArcadeColors.pink : ArcadeColors.textGhost,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        NeonTextField(
          label: 'NOME DO DECK',
          hint: 'Ex: Inglês — Básico',
          controller: _nameCtrl,
          accentColor: ArcadeColors.pink,
        ),

        const SizedBox(height: 16),

        NeonTextField(
          label: 'IDIOMA',
          hint: 'Ex: Inglês, Japonês...',
          controller: _langCtrl,
          accentColor: ArcadeColors.pink,
        ),

        const SizedBox(height: 16),

        Text('CARDS  (linha1=português / linha2=tradução)', style: ArcadeFonts.pixel(size: 6, color: ArcadeColors.textDim)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ArcadeColors.pit,
            border: Border.all(color: ArcadeColors.borderDefault),
          ),
          child: TextField(
            controller: _cardsCtrl,
            maxLines: 8,
            style: ArcadeFonts.mono(size: 13, color: ArcadeColors.textBright),
            cursorColor: ArcadeColors.pink,
            decoration: InputDecoration(
              hintText: 'Olá\nHello\nAdeus\nGoodbye\nObrigado\nThank you',
              hintStyle: ArcadeFonts.mono(size: 12, color: ArcadeColors.textGhost),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),

        const SizedBox(height: 24),

        NeonButton(
          label: 'SALVAR DECK',
          color: ArcadeColors.pink,
          fullWidth: true,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(vertical: 16),
          onTap: _createDeck,
        ),
      ]),
    );
  }
}

class _FullDeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onStudy;
  final VoidCallback onDelete;

  const _FullDeckCard({required this.deck, required this.onStudy, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = [ArcadeColors.cyan, ArcadeColors.pink, ArcadeColors.green, ArcadeColors.yellow];
    final color = colors[deck.name.hashCode.abs() % colors.length];
    final accuracy = (deck.accuracy * 100).round();

    return ArcadeCard(
      borderColor: color,
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ArcadeColors.borderDefault)),
            color: color.withOpacity(0.05),
          ),
          child: Row(children: [
            Text(deck.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deck.name, style: ArcadeFonts.pixel(size: 9, color: ArcadeColors.textBright)),
                const SizedBox(height: 3),
                Text(deck.description, style: ArcadeFonts.mono(size: 11, color: ArcadeColors.textDim)),
              ],
            )),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.delete_outline, color: ArcadeColors.textGhost, size: 18),
              ),
            ),
          ]),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            _MiniStat(value: '${deck.totalCards}', label: 'CARDS', color: color),
            const SizedBox(width: 16),
            _MiniStat(value: '${deck.dueToday}', label: 'DUE', color: ArcadeColors.pink),
            const SizedBox(width: 16),
            _MiniStat(value: '$accuracy%', label: 'ACERTO', color: ArcadeColors.green),
            const Spacer(),
            NeonButton(
              label: 'ESTUDAR',
              color: color,
              filled: deck.dueToday > 0,
              fontSize: 7,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onTap: onStudy,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: ArcadeFonts.pixel(size: 11, color: color)
          .copyWith(shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 6)])),
      Text(label, style: ArcadeFonts.pixel(size: 5.5, color: ArcadeColors.textGhost)),
    ],
  );
}
