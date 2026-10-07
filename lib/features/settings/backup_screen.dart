import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/backup_service.dart';
import '../../widgets/common.dart';
import '../state/app_state.dart';

/// Sauvegarde / restauration par presse-papiers : aucun plugin natif,
/// donc aucun risque de blocage de compilation Android.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _text = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _copy() async {
    final st = context.read<AppState>();
    final s = st.s;
    setState(() => busy = true);
    try {
      final json = await st.exportBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      _msg(s.t('backup_copied'));
    } catch (e) {
      _msg('${s.t('backup_error')} : $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _text.text = data!.text!;
  }

  Future<void> _restore() async {
    final st = context.read<AppState>();
    final s = st.s;
    setState(() => busy = true);
    try {
      final bundle = decodeBackup(_text.text.trim());
      st.validateBundle(bundle);
      if (!mounted) return;
      final ok = await confirmDialog(context, s,
          '${s.t('restore_confirm')}\n\n${s.t('rows')} : ${bundle.totalRows}');
      if (!ok) return;
      await st.restoreBackup(bundle);
      _text.clear();
      _msg(s.t('restore_done'));
    } catch (e) {
      _msg('${s.t('backup_error')} : $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      appBar: AppBar(title: Text(s.t('menu_backup'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.t('backup_info')),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: busy ? null : _copy,
            icon: const Icon(Icons.copy),
            label: Text(s.t('backup_export')),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _text,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: s.t('backup_hint'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : _paste,
                icon: const Icon(Icons.paste),
                label: Text(s.t('backup_paste')),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: busy ? null : _restore,
                icon: const Icon(Icons.restore),
                label: Text(s.t('backup_restore')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
