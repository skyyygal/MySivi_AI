import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sivi_ai/controllers/user_provider.dart';
import 'package:my_sivi_ai/models/user_models.dart';

void main() {
  late ProviderContainer container;
  late UsersController notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(usersProvider.notifier);
  });

  test('Initial users list is empty', () {
    final users = container.read(usersProvider);
    expect(users, []);
  });

  test('Add user updates state', () {
    final newUser = User(id: 1, fullName: 'Test User');
    notifier.addUser(newUser);

    final users = container.read(usersProvider);
    expect(users.length, 1);
    expect(users.first.fullName, 'Test User');
  });

  test('Fetch users updates state', () async {
    await notifier.fetchUsers();
    final users = container.read(usersProvider);
    expect(users.isNotEmpty, true);
  });
}
