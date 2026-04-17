// ignore_for_file: prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/app_config.dart';
import '../../models/thread.dart';
import '../../services/api_client.dart';
import '../../services/media_service.dart';
import '../../services/realtime_service.dart';

final commentsProvider = FutureProvider.family.autoDispose<List<ChatMessage>, String>((ref, path) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get<Map<String, dynamic>>(path);
  final items = res.data!['items'] as List<dynamic>;
  return items.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
});

class ChatPage extends ConsumerStatefulWidget {
  ChatPage({super.key, required GossipThread thread})
      : title = thread.content,
        bannerText = thread.content,
        commentsPath = '/api/threads/${thread.id}/comments',
        sendPath = '/api/threads/${thread.id}/comments',
        roomKey = 'thread:${thread.id}';

  ChatPage.direct({
    super.key,
    required this.title,
    required String conversationId,
  })  : bannerText = 'Özel dedikodu hattı açık',
        commentsPath = '/api/conversations/$conversationId/messages',
        sendPath = '/api/conversations/$conversationId/messages',
        roomKey = 'conversation:$conversationId';

  final String title;
  final String bannerText;
  final String commentsPath;
  final String sendPath;
  final String roomKey;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _message = TextEditingController();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  bool _aiTyping = false;
  bool _emojiOpen = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    final realtime = ref.read(realtimeServiceProvider);
    realtime.connect(rooms: [widget.roomKey]);
    realtime.events.listen((event) {
      if (!mounted) return;
      if (event['event'] == 'AI_TYPING') setState(() => _aiTyping = true);
      if (event['event'] == 'MESSAGE_RECEIVED') {
        setState(() => _aiTyping = false);
        ref.invalidate(commentsProvider(widget.commentsPath));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.commentsPath));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _GossipBanner(text: widget.bannerText),
          Expanded(
            child: comments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length + (_aiTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_aiTyping && index == items.length) {
                    return const _TypingBubble();
                  }
                  final item = items[index];
                  return _Bubble(message: item);
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _emojiOpen
                        ? SizedBox(
                            height: 260,
                            child: EmojiPicker(
                              onEmojiSelected: (_, emoji) => _message.text += emoji.emoji,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Emoji',
                          onPressed: () => setState(() => _emojiOpen = !_emojiOpen),
                          icon: const Icon(Icons.emoji_emotions_outlined),
                        ),
                        IconButton(
                          tooltip: 'Foto/video',
                          onPressed: _showMediaSheet,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                        IconButton(
                          tooltip: _recording ? 'Kaydı gönder' : 'Ses kaydı',
                          onPressed: _toggleRecording,
                          icon: Icon(_recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _message,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Kazana bir kepçe de sen at...',
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _send,
                          icon: const Icon(Icons.send),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    _message.clear();
    await ref.read(apiClientProvider).dio.post(widget.sendPath, data: {'content': text, 'message_type': 'text'});
    ref.invalidate(commentsProvider(widget.commentsPath));
  }

  Future<void> _showMediaSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden foto gönder'),
              onTap: () => _pickAndSend(ImageSource.gallery, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kameradan foto çek'),
              onTap: () => _pickAndSend(ImageSource.camera, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Galeriden video gönder'),
              onTap: () => _pickAndSend(ImageSource.gallery, 'video'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Kameradan video çek'),
              onTap: () => _pickAndSend(ImageSource.camera, 'video'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSend(ImageSource source, String mediaType) async {
    Navigator.pop(context);
    final picked = mediaType == 'video'
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source, imageQuality: 88);
    if (picked == null) return;
    final uploaded = await ref.read(mediaServiceProvider).upload(File(picked.path), mediaType);
    await ref.read(apiClientProvider).dio.post(
          widget.sendPath,
          data: uploaded.toMessagePayload(content: _message.text.trim()),
        );
    _message.clear();
    ref.invalidate(commentsProvider(widget.commentsPath));
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path == null) return;
      final uploaded = await ref.read(mediaServiceProvider).upload(File(path), 'audio');
      await ref.read(apiClientProvider).dio.post(
            widget.sendPath,
            data: uploaded.toMessagePayload(content: _message.text.trim()),
          );
      _message.clear();
      ref.invalidate(commentsProvider(widget.commentsPath));
      return;
    }
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/dedikodu-${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() => _recording = true);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Şükriye Teyze yazıyor...'),
      ),
    );
  }
}

class _GossipBanner extends StatelessWidget {
  const _GossipBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary, const Color(0xFFFFC857)]),
      ),
      child: Text(
        'Kazan kaynıyor: $text',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAi = message.isAi;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAi ? scheme.secondaryContainer : scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAi && message.persona != null)
                Text(message.persona!, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
              _MessageBody(message: message),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final url = message.mediaUrl == null ? null : '${AppConfig.apiBaseUrl}${message.mediaUrl}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (url != null && message.messageType == 'image')
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, width: 260, fit: BoxFit.cover),
          ),
        if (url != null && message.messageType == 'video') _MediaChip(icon: Icons.play_circle_fill, label: message.fileName ?? 'Video'),
        if (url != null && message.messageType == 'audio') _MediaChip(icon: Icons.graphic_eq, label: message.fileName ?? 'Ses kaydı'),
        if (message.content.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(message.content)),
      ],
    );
  }
}

class _MediaChip extends StatelessWidget {
  const _MediaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
