# 🕹️ FLASHCARDS PRO — ARCADE EDITION

Um app Flutter de flashcards com visual retrô arcade neon, completamente repaginado do zero.

---

## 🎮 TELAS

| Tela | Descrição |
|------|-----------|
| **Login** | Tela de entrada com logo pulsante, scanlines CRT e partículas neon |
| **Dashboard** | Visão geral com streak, stats, meta diária e decks pendentes |
| **Decks** | Lista de decks com criação inline (entrada por texto) |
| **Estudo** | Flashcard com flip 3D animado e botões de avaliação SM-2 |
| **Estatísticas** | Gráfico de barras 7 dias, nível/XP e breakdown por deck |

---

## ⚡ INSTALAÇÃO RÁPIDA

### Pré-requisitos
- Flutter SDK 3.x  →  https://flutter.dev/docs/get-started/install
- Dart 3.0+
- Android Studio / VS Code

### Passos

```bash
# 1. Extraia o projeto
unzip flashcards_arcade.zip
cd flashcards_arcade

# 2. Instale as dependências
flutter pub get

# 3. Rode no emulador ou dispositivo
flutter run

# Build APK de release
flutter build apk --release
```

---

## 📦 DEPENDÊNCIAS

```yaml
google_fonts: ^6.1.0       # Fontes Press Start 2P, VT323, Share Tech Mono
fl_chart: ^0.68.0          # Gráfico de barras de estatísticas
shared_preferences: ^2.2.2 # Persistência local
provider: ^6.1.1           # Gerenciamento de estado
flutter_animate: ^4.5.0    # Animações fluidas
uuid: ^4.3.3               # IDs únicos para cards/decks
```

---

## 🎨 DESIGN SYSTEM

### Paleta Neon
| Cor | Hex | Uso |
|-----|-----|-----|
| Cyan | `#00FFFF` | Principal, info, progresso |
| Pink | `#FF00AA` | Secundária, ação, verso do card |
| Green | `#00FF41` | Sucesso, acerto, stats |
| Yellow | `#FFE600` | Streak, XP, destaque |
| Purple | `#BF00FF` | Nível, XP avançado |
| Red | `#FF0044` | Erro, perigo |

### Fontes
- **Press Start 2P** — Títulos e labels (pixel font)
- **VT323** — Texto dos flashcards (CRT display font)
- **Share Tech Mono** — Body text (terminal monospace)

### Efeitos
- ✅ Scanlines CRT animadas
- ✅ Grid de fundo com pulso
- ✅ Partículas flutuantes coloridas
- ✅ Glow neon em todos os elementos
- ✅ Animações de entrada com flutter_animate
- ✅ Flip 3D real dos flashcards
- ✅ Efeito glitch no logo
- ✅ Barras de progresso com glow

---

## 🗂️ ESTRUTURA DO PROJETO

```
lib/
├── main.dart                    # Entry point
├── theme/
│   └── arcade_theme.dart        # Cores, fontes, glow helpers
├── models/
│   └── models.dart              # Flashcard, Deck, AppState, StudySession
├── widgets/
│   └── arcade_widgets.dart      # Componentes reutilizáveis
└── screens/
    ├── login_screen.dart        # Tela de login/cadastro
    ├── home_screen.dart         # Dashboard + nav bar
    ├── study_screen.dart        # Sessão de estudos com flip
    ├── decks_screen.dart        # Lista e criação de decks
    └── stats_screen.dart        # Estatísticas com gráfico
```

---

## 🎯 ALGORITMO SM-2

O app usa o algoritmo **SuperMemo 2** para espaçamento de repetições:

- **1 (Errei)** → Reinicia repetição, próxima revisão em 1 min
- **2 (Difícil)** → Intervalo curto, fator de facilidade diminui
- **3 (Bom)** → Intervalo aumenta normalmente
- **4 (Fácil)** → Intervalo longo, fator de facilidade aumenta

---

## 💡 COMO ADICIONAR CARDS

Na tela **DECKS → + NOVO**, cole os cards no formato:

```
Olá
Hello
Adeus
Goodbye
Obrigado
Thank you
Por favor
Please
```

Linhas ímpares = Português | Linhas pares = Tradução

---

*INSERT COIN TO CONTINUE* 🪙
