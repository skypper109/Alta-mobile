import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/datasources/mock_cultural_guide_knowledge.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/theme/culture_theme.dart';

/// Écran de Dialogue avec le Guide Culturel IA Contextuel
class CulturalGuideScreen extends StatefulWidget {
  final CulturalGuideContext contextData;

  const CulturalGuideScreen({
    super.key,
    required this.contextData,
  });

  @override
  State<CulturalGuideScreen> createState() => _CulturalGuideScreenState();
}

class _CulturalGuideScreenState extends State<CulturalGuideScreen> {
  final List<GuideMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<GuideSuggestion> _suggestions;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _suggestions = MockCulturalGuideKnowledge.getSuggestionsForContext(widget.contextData);
    final welcomeMsg = MockCulturalGuideKnowledge.getWelcomeMessage(widget.contextData);
    _messages.add(welcomeMsg);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _askQuestion(String questionText) {
    if (questionText.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final userMsg = GuideMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: questionText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _textController.clear();
    });
    _scrollToBottom();

    // Simulation de réflexion IA naturelle (400ms)
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final aiAnswer = MockCulturalGuideKnowledge.answerQuestion(
        question: questionText,
        context: widget.contextData,
      );

      setState(() {
        _messages.add(aiAnswer);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final bgColor = isDark ? CultureTheme.darkBackground : const Color(0xFFFAF7F2);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── 1. EN-TÊTE FIXE DU GUIDE IA ─────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar IA
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: CultureTheme.accentOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Guide Culturel IA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'En ligne',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Contexte : ${widget.contextData.contentTitle} (${widget.contextData.regionName})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Bouton fermer
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) context.pop();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close_rounded, size: 18, color: titleColor),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. SUGGESTIONS DE QUESTIONS CONTEXTUELLES ───────────────────
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final sug = _suggestions[index];
                  return GestureDetector(
                    onTap: () => _askQuestion(sug.questionText),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sug.icon, size: 13, color: CultureTheme.accentOrange),
                          const SizedBox(width: 6),
                          Text(
                            sug.questionText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF9A3412),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── 3. LISTE DES MESSAGES DU DIALOGUE ────────────────────────────
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator(isDark, cardBg, borderCol);
                  }

                  final msg = _messages[index];
                  return _buildMessageBubble(
                    msg: msg,
                    context: context,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  );
                },
              ),
            ),

            // ── 4. BARRE DE SAISIE DE QUESTION LIBRE ─────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.paddingOf(context).bottom + 8,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderCol),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: titleColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Posez une question culturelle...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: _askQuestion,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _askQuestion(_textController.text),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CultureTheme.accentOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BULLE DE MESSAGE ───────────────────────────────────────────────────────
  Widget _buildMessageBubble({
    required GuideMessage msg,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: CultureTheme.primaryBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // Bulle Guide IA
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    size: 13, color: CultureTheme.accentOrange),
                const SizedBox(width: 5),
                Text(
                  'Compagnon Culturel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: titleColor,
                height: 1.5,
              ),
            ),

            // Carte d'action connectée si présente
            if (msg.action != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(msg.action!.targetRoute);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.action!.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 12, color: CultureTheme.accentOrange),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, Color cardBg, Color borderCol) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 14, color: CultureTheme.accentOrange),
            const SizedBox(width: 8),
            Text(
              'Le guide réfléchit...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: CultureTheme.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
