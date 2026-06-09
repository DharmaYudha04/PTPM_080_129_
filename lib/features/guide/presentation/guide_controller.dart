import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../domain/usecases/send_message_usecase.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;

  Map<String, String> toOpenAiMessage() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': text,
    };
  }
}

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController()
      : _useCase = SendMessageUseCase(getIt()),
        super(const []);

  final SendMessageUseCase _useCase;

  Future<void> send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    final historyBeforeUserMessage = state
        .where((message) => message.text.trim().isNotEmpty)
        .take(10)
        .map((message) => message.toOpenAiMessage())
        .toList();

    state = [
      ...state,
      ChatMessage(text: trimmed, isUser: true),
      const ChatMessage(text: '', isUser: false),
    ];

    try {
      await for (final response in _useCase(
        prompt: trimmed,
        history: historyBeforeUserMessage,
      )) {
        if (!mounted) return;

        state = [
          ...state.sublist(0, state.length - 1),
          ChatMessage(text: response, isUser: false),
        ];
      }

      if (!mounted) return;

      final last = state.isEmpty ? null : state.last;
      if (last != null && !last.isUser && last.text.trim().isEmpty) {
        state = [
          ...state.sublist(0, state.length - 1),
          const ChatMessage(
            text: 'Kanca Jogja belum mengembalikan jawaban. Coba kirim ulang.',
            isUser: false,
          ),
        ];
      }
    } catch (_) {
      if (!mounted) return;

      state = [
        ...state.sublist(0, state.length - 1),
        const ChatMessage(
          text:
              'Kanca Jogja sedang tidak bisa dihubungi. Coba cek koneksi, API key, atau jalankan lewat Android jika web terkena CORS.',
          isUser: false,
        ),
      ];
    }
  }

  void clear() {
    state = const [];
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>(
  (ref) => ChatController(),
);
