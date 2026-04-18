import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import 'chat_page.dart';

final userSearchProvider = FutureProvider.family.autoDispose<List<AppUser>, String>((ref, query) async {
  if (query.trim().length < 2) return const [];
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get<Map<String, dynamic>>('/api/users/search', queryParameters: {'q': query});
  final items = res.data?['items'] as List<dynamic>? ?? const [];
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
      appBar: AppBar(title: const Text('Kazan Kankaları')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: AppGradients.warm, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.white, size: 34),
                const SizedBox(height: 8),
                Text(
                  'Özelden fısılda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text('Dedikodu kankanı bul, özel kazanı yak.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Kazan Kankası ara',
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: CircleAvatar(backgroundColor: AppColors.lilac, child: Text(user.fullName.characters.first.toUpperCase())),
                      title: Text(user.fullName),
                      subtitle: Text('@${user.username}'),
                      trailing: const Icon(Icons.chat_bubble_rounded, color: AppColors.violet),
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
