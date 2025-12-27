import 'package:flutter_test/flutter_test.dart';
import 'package:my_sivi_ai/controllers/message_controller.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';

void main() {
  late ChatController controller;

  setUp(() {
    controller = ChatController();
  });

  test('Initial state should be empty', () {
    expect(controller.state, []);
  });

  test('Add message updates state', () {
    final msg = ChatMessage.sender(message: 'Hello');
    controller.addMessage(msg);

    expect(controller.state.length, 1);
    expect(controller.state[0].message, 'Hello');
  });
}
