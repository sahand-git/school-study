import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/question_model.dart';
import '../services/tutor_ai_service.dart';

class TutorChatScreen extends StatefulWidget {
  final String? initialPrompt;

  const TutorChatScreen({super.key, this.initialPrompt});

  @override
  State<TutorChatScreen> createState() => _TutorChatScreenState();
}

class _TutorChatScreenState extends State<TutorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickSuggestions = [
    'چۆن نمرەی ١٠٠ لە فیزیا بێنم؟',
    'یاسای ئۆم زۆر ئاڵۆزە، بە سادەیی فێرم بکە',
    'فێڵی خێرای داتاشراو چییە؟',
    'چۆن کاتی تاقیکردنەوە دابەش بکەم؟',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text: 'سڵاو لە تۆی هیوای ئایندە! 🌟\nمن مامۆستای تایبەتیت لە ئامادەیا. هەر یاسایەک یان پرسیارێکی وزاریت بۆ ئاڵۆزە، لێرە بیپرسە تا بە ٣ هەنگاوی سادە وەک ڕۆژ بۆت ڕوون بکەمەوە.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialPrompt!);
      });
    }
  }

  void _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    final response = await TutorAiService.getSimplifiedAnswer(text);

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'tutor_${DateTime.now().millisecondsSinceEpoch}',
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.amber,
              radius: 17,
              child: Icon(Icons.school_rounded, color: Colors.black, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مامۆستای ئامادەیا (Tutor)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  'وەڵامدانەوە و شیکاری بە زمانی کوردی سادە',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick suggestions chips
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _quickSuggestions.length,
                itemBuilder: (context, idx) {
                  final suggestion = _quickSuggestions[idx];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.cardBorder),
                      label: Text(
                        suggestion,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _handleSendMessage(suggestion),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.isUser;

                  return Align(
                    alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.84,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.indigo : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 4 : 20),
                          bottomRight: Radius.circular(isUser ? 20 : 4),
                        ),
                        border: Border.all(
                          color: isUser ? AppColors.indigo : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.amber),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'مامۆستا بە سادەترین شێواز شیکاری دەکات...',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),

            // Input Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'پرسیارەکەت بنووسە یان یاسایەک بپرسە...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _handleSendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleSendMessage(_textController.text),
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
}
