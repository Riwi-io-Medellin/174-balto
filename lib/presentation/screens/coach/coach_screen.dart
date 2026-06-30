import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/coach_message.dart';
import '../../bloc/coach/coach_cubit.dart';
import '../../bloc/coach/coach_state.dart';
import 'widgets/message_bubble.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachCubit>()..init(),
      child: const _CoachView(),
    );
  }
}

class _CoachView extends StatefulWidget {
  const _CoachView();

  @override
  State<_CoachView> createState() => _CoachViewState();
}

class _CoachViewState extends State<_CoachView> {
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    context.read<CoachCubit>().sendMessage(text);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva sesión'),
        content:
            const Text('¿Borrar el historial de esta conversación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Borrar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<CoachCubit>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoachCubit, CoachState>(
      listenWhen: (_, curr) =>
          curr is CoachLoaded && curr.sendError != null,
      listener: (ctx, state) {
        if (state is CoachLoaded && state.sendError != null) {
          BaltoToast.error(ctx, state.sendError!);
        }
      },
      builder: (ctx, state) {
        final messages =
            state is CoachLoaded ? state.messages : <CoachMessage>[];
        final isTyping = state is CoachLoaded && state.isTyping;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.navCoach,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Balto Coach',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            actions: [
              if (messages.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  tooltip: 'Nueva sesión',
                  onPressed: _confirmClear,
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFE5E7EB), height: 1),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty && !isTyping
                    ? const _EmptyState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: messages.length + (isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (isTyping && i == messages.length) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _scrollToBottom());
                            return const TypingIndicator();
                          }
                          if (i == messages.length - 1) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _scrollToBottom());
                          }
                          return MessageBubble(message: messages[i]);
                        },
                      ),
              ),
              _InputBar(
                textCtrl: _textCtrl,
                focusNode: _focusNode,
                isTyping: isTyping,
                onSend: _send,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.navCoach.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 36,
                color: AppColors.navCoach,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Balto Coach',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu asistente de bienestar animal.\nPregúntame sobre el cuidado, nutrición\ny salud de tu mascota.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.textCtrl,
    required this.focusNode,
    required this.isTyping,
    required this.onSend,
  });

  final TextEditingController textCtrl;
  final FocusNode focusNode;
  final bool isTyping;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textCtrl,
              focusNode: focusNode,
              enabled: !isTyping,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Pregunta sobre tu mascota…',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide:
                      const BorderSide(color: AppColors.navCoach),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isTyping ? 0.4 : 1.0,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.navCoach,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: isTyping ? null : onSend,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
