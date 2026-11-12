import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      isAI: true,
      text:
          'Hello Alex! I am your personal financial intelligence advisor. How can I assist you with your spending, budgets, or savings goals today?',
      time: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    _ChatMessage(
      isAI: false,
      text: 'How much have I spent on food and dining this month?',
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    _ChatMessage(
      isAI: true,
      text:
          'You have spent \$458.50 on Food & Dining so far this month, which represents 76% of your \$600.00 monthly envelope limit.\n\nYou have \$141.50 remaining for the rest of the cycle. You are on track to stay within your target.',
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  bool _isTyping = false;

  final List<String> _quickPrompts = [
    'How is my savings rate?',
    'Review my subscriptions',
    'Where can I cut expenses?',
    'Forecast month-end balance',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(isAI: false, text: text, time: DateTime.now()),
      );
      _isTyping = true;
    });
    _inputController.clear();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(
            isAI: true,
            text:
                'Based on your actual cash flow, your current net savings rate is 75.8% (\$4,549.25 preserved out of \$6,000.00 income). We recommend keeping everyday grocery expenses consistent and allocating \$100 toward your Europe Vacation goal.',
            time: DateTime.now(),
          ),
        );
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldCardGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Assistant',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.income,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Active On-Device Engine',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.income,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chat Messages View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg, isDark);
                },
              ),
            ),

            if (_isTyping) ...[
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Analyzing financial data...',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Quick Prompt Suggestions Carousel
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return ActionChip(
                    label: Text(prompt),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Ask about spending, budgets or habits...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.emeraldCardGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildMessageBubble(_ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: msg.isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.isAI) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.emeraldCardGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: msg.isAI
                    ? (isDark ? AppColors.cardDark : Colors.white)
                    : (isDark ? AppColors.primaryLight : AppColors.primary),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: msg.isAI
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                  bottomRight: msg.isAI
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                ),
                border: msg.isAI
                    ? Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: msg.isAI
                      ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isAI;
  final String text;
  final DateTime time;

  _ChatMessage({required this.isAI, required this.text, required this.time});
}
