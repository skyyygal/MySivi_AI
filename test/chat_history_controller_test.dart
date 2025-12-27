import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sivi_ai/controllers/chat_history_provider.dart';
import 'package:my_sivi_ai/models/user_models.dart';

void main() {
  late ProviderContainer container;
  late ChatHistoryController chatHistoryController;
  setUp(() {
    container = ProviderContainer();
    chatHistoryController = container.read(chatHistoryProvider.notifier);
  });
  test('Initial chat messages are empty', () {
    final messages = container.read(chatHistoryProvider);
    expect(messages, []);
  });
  test('Generates chat history when users are added', () async {
    final users = [
      User(id: 1, fullName: 'Alice'),
      User(id: 2, fullName: 'Bob'),
    ];

    await chatHistoryController.generateChatHistory(users);

    final chatHistory = container.read(chatHistoryProvider);
    expect(chatHistory.length, 2);
    expect(chatHistory[0].user.fullName, 'Alice');
    expect(chatHistory[1].user.fullName, 'Bob');
  });
  test('ChatHistory items have proper fields', () async {
    final users = [User(id: 1, fullName: 'Alice')];
    await chatHistoryController.generateChatHistory(users);

    final chatItem = container.read(chatHistoryProvider).first;
    expect(chatItem.unreadCount >= 0, true);
    expect(chatItem.lastMessage.message.isNotEmpty, true);
  });
}
