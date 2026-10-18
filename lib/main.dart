import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'questions.dart';

void main() => runApp(const SinavApp());

const _seconds = 15;

class SinavApp extends StatelessWidget {
  const SinavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sınav',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B)),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B), brightness: Brightness.dark)),
      home: const HomePage(),
    );
  }
}

/// Chalkboard background from the first version of the app, dimmed so text stays readable.
class Board extends StatelessWidget {
  final Widget child;
  const Board({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('images/back.jpg'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Color(0xCC0B2E26), BlendMode.srcOver)),
      ),
      child: SafeArea(child: child),
    );
  }
}

// ── Home ────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> best = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => best = {for (final c in categories) c.id: p.getInt('best_${c.id}') ?? 0});
  }

  @override
  Widget build(BuildContext context) {
    final total = best.values.fold(0, (a, b) => a + b);
    return Scaffold(
      body: Board(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            const Icon(Icons.school_rounded, color: Colors.white, size: 44),
            const SizedBox(height: 12),
            const Text('Sınav', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            const SizedBox(height: 6),
            Text('Doğru mu, yanlış mı? Her soru için $_seconds saniyen var.', style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F)),
                const SizedBox(width: 10),
                Text('Toplam en iyi skor: $total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Bir konu seç', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final c in categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async {
                      await Navigator.of(context).push(_route(QuizPage(category: c)));
                      _load();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: c.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
                          child: Icon(c.icon, color: c.color, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            Text('${c.subtitle} · ${c.questions.length} soru', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ]),
                        ),
                        if ((best[c.id] ?? 0) > 0)
                          Chip(label: Text('${best[c.id]}/${c.questions.length}'), visualDensity: VisualDensity.compact, avatar: const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA000))),
                        const Icon(Icons.chevron_right_rounded),
                      ]),
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

Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, a, _) => page,
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
      ),
    );

// ── Quiz ────────────────────────────────────────────────────────────────
class Answer {
  final Question q;
  final bool? given; // null = time ran out
  const Answer(this.q, this.given);
  bool get correct => given == q.answer;
}

class QuizPage extends StatefulWidget {
  final Category category;
  const QuizPage({super.key, required this.category});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late final List<Question> questions = [...widget.category.questions]..shuffle(Random());
  late final AnimationController timer = AnimationController(vsync: this, duration: const Duration(seconds: _seconds))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _answer(null);
    });
  final answers = <Answer>[];
  int index = 0;
  int streak = 0;
  Answer? last; // shown as feedback until "Next"

  @override
  void initState() {
    super.initState();
    timer.forward();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  void _answer(bool? value) {
    if (last != null) return;
    timer.stop();
    final a = Answer(questions[index], value);
    setState(() {
      last = a;
      answers.add(a);
      streak = a.correct ? streak + 1 : 0;
    });
  }

  void _next() {
    if (index == questions.length - 1) {
      Navigator.of(context).pushReplacement(_route(ResultPage(category: widget.category, answers: answers)));
      return;
    }
    setState(() {
      index++;
      last = null;
    });
    timer.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];
    final c = widget.category;
    return Scaffold(
      body: Board(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: (index + (last != null ? 1 : 0)) / questions.length),
                    duration: const Duration(milliseconds: 400),
                    builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white24, color: const Color(0xFF69F0AE)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${index + 1}/${questions.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Chip(avatar: Icon(c.icon, size: 18, color: c.color), label: Text(c.title)),
              const Spacer(),
              AnimatedOpacity(
                opacity: streak >= 2 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Chip(avatar: const Text('🔥'), label: Text('$streak seri')),
              ),
            ]),
            const Spacer(),
            // Countdown ring
            AnimatedBuilder(
              animation: timer,
              builder: (_, _) {
                final left = (_seconds * (1 - timer.value)).ceil();
                final danger = left <= 5 && last == null;
                return SizedBox(
                  width: 92, height: 92,
                  child: Stack(fit: StackFit.expand, children: [
                    CircularProgressIndicator(value: 1 - timer.value, strokeWidth: 7, backgroundColor: Colors.white24, color: danger ? const Color(0xFFFF5252) : const Color(0xFF69F0AE)),
                    Center(child: Text('$left', style: TextStyle(color: danger ? const Color(0xFFFF8A80) : Colors.white, fontSize: 30, fontWeight: FontWeight.w800))),
                  ]),
                );
              },
            ),
            const SizedBox(height: 26),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(a), child: child)),
              child: Text(q.text, key: ValueKey(index), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.35, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: last == null ? const SizedBox(width: double.infinity) : _Feedback(answer: last!),
            ),
            const Spacer(),
            if (last == null) ...[
              _AnswerButton(label: 'DOĞRU', icon: Icons.check_rounded, color: const Color(0xFF00C853), onTap: () => _answer(true)),
              const SizedBox(height: 12),
              _AnswerButton(label: 'YANLIŞ', icon: Icons.close_rounded, color: const Color(0xFFFF5252), onTap: () => _answer(false)),
            ] else
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF00695C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  icon: Icon(index == questions.length - 1 ? Icons.flag_rounded : Icons.arrow_forward_rounded),
                  label: Text(index == questions.length - 1 ? 'Sonucu gör' : 'Sonraki soru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AnswerButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 2),
        icon: Icon(icon, size: 26),
        label: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  final Answer answer;
  const _Feedback({required this.answer});

  @override
  Widget build(BuildContext context) {
    final ok = answer.correct;
    final timeout = answer.given == null;
    final color = ok ? const Color(0xFF00C853) : const Color(0xFFFF5252);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .6))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(ok ? Icons.check_circle_rounded : (timeout ? Icons.timer_off_rounded : Icons.cancel_rounded), color: color),
          const SizedBox(width: 8),
          Text(ok ? 'Doğru!' : (timeout ? 'Süre doldu' : 'Yanlış'), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          Text('Cevap: ${answer.q.answer ? 'Doğru' : 'Yanlış'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Text(answer.q.why, style: const TextStyle(color: Colors.white, height: 1.4)),
      ]),
    );
  }
}

// ── Result ──────────────────────────────────────────────────────────────
class ResultPage extends StatefulWidget {
  final Category category;
  final List<Answer> answers;
  const ResultPage({super.key, required this.category, required this.answers});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool newBest = false;
  int get score => widget.answers.where((a) => a.correct).length;

  @override
  void initState() {
    super.initState();
    _saveBest();
  }

  Future<void> _saveBest() async {
    final p = await SharedPreferences.getInstance();
    final key = 'best_${widget.category.id}';
    if (score > (p.getInt(key) ?? 0)) {
      await p.setInt(key, score);
      setState(() => newBest = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.answers.length;
    final ratio = score / total;
    final msg = ratio == 1 ? 'Mükemmel! 🎉' : ratio >= .75 ? 'Harika iş!' : ratio >= .5 ? 'İyi gidiyorsun' : 'Biraz daha pratik';
    return Scaffold(
      body: Board(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => SizedBox(
                  width: 170, height: 170,
                  child: Stack(fit: StackFit.expand, children: [
                    CircularProgressIndicator(value: v, strokeWidth: 12, backgroundColor: Colors.white24, color: const Color(0xFF69F0AE), strokeCap: StrokeCap.round),
                    Center(child: Text('${(v * total).round()}/$total', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800))),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            if (newBest)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('🏆 Yeni en iyi skor!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 24),
            const Text('Cevapların', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final a in widget.answers)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(a.correct ? Icons.check_circle_rounded : Icons.cancel_rounded, color: a.correct ? const Color(0xFF00C853) : const Color(0xFFFF5252)),
                  title: Text(a.q.text, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(a.given == null ? 'Süre doldu · cevap: ${a.q.answer ? 'Doğru' : 'Yanlış'}' : 'Cevabın: ${a.given! ? 'Doğru' : 'Yanlış'}'),
                ),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(54)),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Konular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF00695C), minimumSize: const Size.fromHeight(54)),
                  onPressed: () => Navigator.of(context).pushReplacement(_route(QuizPage(category: widget.category))),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
