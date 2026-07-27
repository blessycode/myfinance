import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(isAI: true, text: 'Hi Alex! 👋 I\'m your AI financial assistant. How can I help you today?', time: DateTime.now().subtract(const Duration(minutes: 5))),
    _ChatMessage(isAI: false, text: 'How much have I spent on food this month?', time: DateTime.now().subtract(const Duration(minutes: 4))),
    _ChatMessage(isAI: true, text: '🍔 You\'ve spent **\$458.50** on food this month, which is 76% of your \$600 food budget.\n\nYou have **\$141.50** remaining for the rest of the month. You\'re on track! 🎉', time: DateTime.now().subtract(const Duration(minutes: 4))),
    _ChatMessage(isAI: false, text: 'Give me savings tips', time: DateTime.now().subtract(const Duration(minutes: 2))),
    _ChatMessage(isAI: true, text: 'Here are 3 personalized tips based on your spending:\n\n💡 **Meal Prep** – Could save \$120/month on dining out\n\n📱 **Review Subscriptions** – You have \$54.97/month in subscriptions. Cancel unused ones.\n\n⚡ **Automate Savings** – Set up auto-transfer of \$500/month to your emergency fund', time: DateTime.now().subtract(const Duration(minutes: 1))),
  ];

  bool _isTyping = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(isAI: false, text: text, time: DateTime.now()));
      _isTyping = true;
    });
    _inputCtrl.clear();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            isAI: true,
            text: 'Great question! Based on your spending patterns, I recommend focusing on reducing your dining expenses by 20%. This could save you approximately \$91.70 this month. Would you like me to create a meal budget for you?',
            time: DateTime.now(),
          ));
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Assistant', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      Row(children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text('Online', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success)),
                      ]),
                    ],
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () {}),
                ],
              ),
            ),

            // Quick suggestions
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Savings tips', 'Monthly report', 'Budget advice', 'Top spends', 'Investment ideas']
                    .map((s) => GestureDetector(
                          onTap: () => _sendMessage(s),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Center(child: Text(s, style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 8),
            Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator(isDark);
                  }
                  final msg = _messages[index];
                  return _buildMessage(msg, isDark);
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: _sendMessage,
                        style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                          prefixIcon: const Icon(Icons.mic_rounded, size: 18, color: AppColors.textTertiaryLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputCtrl.text),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

  Widget _buildMessage(_ChatMessage msg, bool isDark) {
    final isAI = msg.isAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isAI ? null : AppColors.primaryGradient,
                color: isAI ? (isDark ? AppColors.cardDark : Colors.white) : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isAI ? const Radius.circular(4) : const Radius.circular(18),
                  bottomRight: isAI ? const Radius.circular(18) : const Radius.circular(4),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isAI ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) : Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 14, backgroundColor: AppColors.primary, child: Text('A', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
          ],
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(200),
                const SizedBox(width: 4),
                _dot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 0.5, delay: Duration(milliseconds: delay), duration: const Duration(milliseconds: 400));
  }
}

class _ChatMessage {
  final bool isAI;
  final String text;
  final DateTime time;
  _ChatMessage({required this.isAI, required this.text, required this.time});
}
