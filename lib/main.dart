import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const VocabBuildApp());

const Color kNavyBg = Color(0xFF0A1128);
const Color kCardBg = Color(0xFF13213F);
const Color kAccent = Color(0xFFE50914); // Netflix red accent for headings

class VocabBuildApp extends StatelessWidget {
  const VocabBuildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocab Build',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kNavyBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  String _word = '';
  String _partOfSpeech = '';
  String _meaning = '';
  String _example = '';
  bool _hasResult = false;

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _hasResult = false;
    });

    try {
      final res = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final entry = data.first;
        final meaning = entry['meanings'][0];
        final def = meaning['definitions'][0];

        setState(() {
          _word = entry['word'] ?? word;
          _partOfSpeech = meaning['partOfSpeech'] ?? '';
          _meaning = def['definition'] ?? '';
          _example = def['example'] ?? '';
          _hasResult = true;
        });
      } else {
        setState(() => _error = 'No definition found for "$word".');
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Check your connection.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _resultLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: kAccent,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _resultValue(String text, {bool italic = false, double size = 21}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: size,
        fontWeight: FontWeight.w400,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavyBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              Text(
                'VOCAB BUILD',
                textAlign: TextAlign.center,
                style: GoogleFonts.anton(
                  color: Colors.white,
                  fontSize: 46,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'search a word, we help u learn',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 44),
              Container(
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a word...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search,
                          color: Colors.white70, size: 26),
                      onPressed: _search,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.redAccent),
                  ),
                ),
              if (!_loading && _hasResult)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 34,
                      ),
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _resultLabel('WORD'),
                          const SizedBox(height: 8),
                          _resultValue(_word, size: 26),
                          const SizedBox(height: 36),
                          _resultLabel('PART OF SPEECH'),
                          const SizedBox(height: 8),
                          _resultValue(
                            _partOfSpeech.isEmpty ? '—' : _partOfSpeech,
                          ),
                          const SizedBox(height: 36),
                          _resultLabel('MEANING'),
                          const SizedBox(height: 8),
                          _resultValue(_meaning),
                          if (_example.isNotEmpty) ...[
                            const SizedBox(height: 36),
                            _resultLabel('SENTENCE USE'),
                            const SizedBox(height: 8),
                            _resultValue('"$_example"', italic: true),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
