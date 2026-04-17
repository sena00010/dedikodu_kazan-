import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../services/api_client.dart';
import 'chat_page.dart';

final userSearchProvider = FutureProvider.family.autoDispose<List<AppUser>, String>((ref, query) async {
  if (query.trim().length < 2) return const [];
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get<Map<String, dynamic>>('/api/users/search', queryParameters: {'q': query});
  final items = res.data!['items'] as List<dynamic>;
  return items.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
});

class DirectMessagesPage extends ConsumerStatefulWidget {
  const DirectMessagesPage({super.key});

  @override
  ConsumerState<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends ConsumerState<DirectMessagesPage> {
  final _query = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userSearchProvider(_query.text));
    return Scaffold(
      appBar: AppBar(title: const Text('Özel dedikodu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Kullanıcı ara',
              hintText: 'İsim veya kullanıcı adı yaz',
            ),
          ),
          const SizedBox(height: 16),
          users.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
            data: (items) => Column(
              children: [
                for (final user in items)
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: CircleAvatar(child: Text(user.fullName.characters.first.toUpperCase())),
                      title: Text(user.fullName),
                      subtitle: Text('@${user.username}'),
                      trailing: const Icon(Icons.chat_bubble_outline),
                      onTap: () => _openDM(user),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDM(AppUser user) async {
    final api = ref.read(apiClientProvider);
    final res = await api.dio.post<Map<String, dynamic>>('/api/dms/${user.id}');
    final conversationId = res.data!['id'] as String;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage.direct(title: user.fullName, conversationId: conversationId),
      ),
    );
  }
}
