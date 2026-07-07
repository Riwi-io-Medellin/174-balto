import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../bloc/walk_chat/walk_chat_cubit.dart';
import '../../../bloc/walk_chat/walk_chat_state.dart';

class WalkChatSheet extends StatefulWidget {
  const WalkChatSheet({super.key});

  @override
  State<WalkChatSheet> createState() => _WalkChatSheetState();
}

class _WalkChatSheetState extends State<WalkChatSheet> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    context.read<WalkChatCubit>().sendMessage(text);
    _textController.clear();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollableController) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: AppRadius.radius2,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocConsumer<WalkChatCubit, WalkChatState>(
                  listener: (context, state) {
                    if (state is WalkChatLoaded) _scrollToBottom();
                  },
                  builder: (context, state) {
                    if (state is WalkChatError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! WalkChatLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet. Say hello!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMine =
                            message.senderUserId == state.currentUserId;
                        return _ChatBubble(message: message, isMine: isMine);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radius24,
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.navWalks,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.navWalks : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.r16),
            topRight: const Radius.circular(AppRadius.r16),
            bottomLeft: Radius.circular(isMine ? AppRadius.r16 : AppRadius.r4),
            bottomRight: Radius.circular(isMine ? AppRadius.r4 : AppRadius.r16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMine ? Colors.white : const Color(0xFF1F2937),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
