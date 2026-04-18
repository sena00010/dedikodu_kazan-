import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_config.dart';
import '../../models/app_user.dart';
import '../../services/media_service.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 230,
                  title: const Text('Profil'),
                  flexibleSpace: FlexibleSpaceBar(
                    background: DecoratedBox(
                      decoration: const BoxDecoration(gradient: AppGradients.gossip),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Avatar(user: user, size: 86),
                            const SizedBox(height: 10),
                            Text(
                              user.fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                            ),
                            Text('@${user.username}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (user.bio?.trim().isNotEmpty ?? false)
                            _InfoPanel(icon: Icons.auto_stories_outlined, title: 'Hakkında', value: user.bio!),
                          if (user.bio?.trim().isNotEmpty ?? false) const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _Stat(label: 'Jeton', value: '${user.credits}', color: AppColors.peach)),
                              const SizedBox(width: 12),
                              Expanded(child: _Stat(label: 'VIP', value: user.isVip ? 'Açık' : 'Kapalı', color: AppColors.lilac)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _Stat(label: 'Dil', value: _languageName(user.languageCode), color: const Color(0xFFFFD8ED))),
                              const SizedBox(width: 12),
                              Expanded(child: _Stat(label: 'Davet', value: '#${user.publicId.isEmpty ? user.id : user.publicId.substring(0, 6)}', color: AppColors.mint)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () => _showEditProfile(context, ref, user),
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Profilini parlat'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => _copyInvite(context, user),
                            icon: const Icon(Icons.favorite_border_rounded),
                            label: const Text('Kazan Kankası Çağır'),
                          ),
                          const SizedBox(height: 18),
                          _InfoPanel(
                            icon: Icons.link_rounded,
                            title: 'Davet linki',
                            value: 'dedikodukazani.app/invite/${user.publicId.isEmpty ? user.id : user.publicId}',
                          ),
                          const SizedBox(height: 12),
                          _InfoPanel(
                            icon: Icons.translate_rounded,
                            title: 'Dil seçimi',
                            value: _languageName(user.languageCode),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }

  static String _languageName(String? code) => code == 'en' ? 'English' : 'Türkçe';

  Future<void> _copyInvite(BuildContext context, AppUser user) async {
    final code = user.publicId.isEmpty ? '${user.id}' : user.publicId;
    await Clipboard.setData(ClipboardData(text: 'dedikodukazani.app/invite/$code'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kazan Kankası davet linki panoya düştü.')),
      );
    }
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, AppUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ProfileEditor(user: user),
    );
  }
}

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.user});
  final AppUser user;

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.user.fullName);
  late final TextEditingController _age = TextEditingController(text: widget.user.age?.toString() ?? '');
  late final TextEditingController _job = TextEditingController(text: widget.user.jobTitle ?? '');
  late final TextEditingController _bio = TextEditingController(text: widget.user.bio ?? '');
  String? _gender;
  String? _partner;
  String _language = 'tr';
  String? _avatarUrl;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _gender = widget.user.gender;
    _partner = widget.user.partner;
    _language = widget.user.languageCode ?? 'tr';
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _job.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('Profilini parlat', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Center(
            child: Stack(
              children: [
                _Avatar(user: widget.user, overrideUrl: _avatarUrl, size: 88),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: _saving ? null : _pickAvatar,
                    icon: const Icon(Icons.add_a_photo_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _name, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'İsim soyisim')),
          const SizedBox(height: 10),
          TextField(controller: _age, textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yaş')),
          const SizedBox(height: 10),
          TextField(controller: _job, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Meslek')),
          const SizedBox(height: 10),
          TextField(controller: _bio, textAlign: TextAlign.center, maxLines: 3, decoration: const InputDecoration(labelText: 'Hakkında')),
          const SizedBox(height: 14),
          _ChoiceRow(title: 'Cinsiyet', selected: _gender, values: const ['Kadın', 'Erkek', 'Non-binary', 'Söylemem'], onSelected: (value) => setState(() => _gender = value)),
          const SizedBox(height: 14),
          _ChoiceRow(title: 'Partner', selected: _partner, values: const ['Var', 'Yok', 'Karışık', 'Söylemem'], onSelected: (value) => setState(() => _partner = value)),
          const SizedBox(height: 14),
          _ChoiceRow(title: 'Dil', selected: _language, values: const ['tr', 'en'], labels: const {'tr': 'Türkçe', 'en': 'English'}, onSelected: (value) => setState(() => _language = value)),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w800)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      final media = await ref.read(mediaServiceProvider).upload(File(picked.path), 'avatar');
      setState(() => _avatarUrl = media.url);
    } catch (_) {
      setState(() => _message = 'Fotoğraf yüklenemedi. Tekrar deneyelim.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile({
        'full_name': _name.text.trim().isEmpty ? widget.user.fullName : _name.text.trim(),
        if (_age.text.trim().isNotEmpty) 'age': int.tryParse(_age.text.trim()),
        if (_job.text.trim().isNotEmpty) 'job_title': _job.text.trim(),
        if (_bio.text.trim().isNotEmpty) 'bio': _bio.text.trim(),
        if (_gender != null) 'gender': _gender,
        if (_partner != null) 'partner': _partner,
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
        'language_code': _language,
      });
      if (mounted) Navigator.pop(context);
    } on AuthMessage catch (error) {
      setState(() => _message = error.message);
    } catch (_) {
      setState(() => _message = 'Profil güncellenemedi. Bir daha deneyelim.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.overrideUrl, required this.size});
  final AppUser user;
  final String? overrideUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = overrideUrl ?? user.avatarUrl;
    final imageUrl = url == null || url.isEmpty
        ? null
        : url.startsWith('http')
            ? url
            : '${AppConfig.apiBaseUrl}$url';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.lilac,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      child: imageUrl == null
          ? Text(
              user.fullName.characters.first.toUpperCase(),
              style: TextStyle(fontSize: size * 0.34, fontWeight: FontWeight.w900, color: AppColors.ink),
            )
          : null,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.violet),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.title, required this.selected, required this.values, required this.onSelected, this.labels = const {}});
  final String title;
  final String? selected;
  final List<String> values;
  final Map<String, String> labels;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              FilterChip(
                selected: selected == value,
                showCheckmark: true,
                label: Text(labels[value] ?? value),
                onSelected: (_) => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}
