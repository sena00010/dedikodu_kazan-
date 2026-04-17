import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/thread.dart';
import '../../services/api_client.dart';
import '../chat/chat_page.dart';

final threadsProvider = FutureProvider.autoDispose<List<GossipThread>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get<Map<String, dynamic>>('/api/threads');
  final items = res.data!['items'] as List<dynamic>;
  return items.map((e) => GossipThread.fromJson(e as Map<String, dynamic>)).toList();
});

class ThreadsPage extends ConsumerWidget {
  const ThreadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dedikodu Kazanı'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(threadsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewThread(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Kazan aç'),
      ),
      body: threads.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) => LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: columns == 2 ? 2.8 : 2.35,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _ThreadTile(thread: items[index]),
            );
          },
        ),
      ),
    );
  }

  void _showNewThread(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Bugün kazana ne düşüyor?'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await ref.read(apiClientProvider).dio.post('/api/threads', data: {'content': controller.text});
                ref.invalidate(threadsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Paylaş'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread});
  final GossipThread thread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(thread: thread))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  thread.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.mode_comment_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text('${thread.commentCount} yorum'),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
