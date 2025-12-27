import 'package:flutter_riverpod/legacy.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';

class UsersController extends StateNotifier<List<User>> {
  UsersController() : super([]) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final fetched = await ChatService().fetchUsers();
    state = fetched;
  }

  void addUser(User user) {
    state = [...state, user];
  }
}

final usersProvider = StateNotifierProvider<UsersController, List<User>>(
  (ref) => UsersController(),
);

final selectedTabProvider = StateProvider<int>((ref) => 0);
