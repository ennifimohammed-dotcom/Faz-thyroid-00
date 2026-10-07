import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../services/backup_service.dart';
import '../../widgets/common.dart';
import '../state/app_state.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool busy = false;

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    final st = context.read<AppState>();
    final s = st.s;
    setState(() => busy = true);
    try {
      final json = await st.exportBackupJson();
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final name =
          'thyroid_backup_${now.year}${two(now.month)}${two(now.day)}.json';
      final file = File('${dir.path}/$name');
      await file.writeAsString(json, flush: true);
      await Share.shareXFiles([XFile(file.path)], subject: name);
    } catch (e) {
      _msg('${s.t('backup_error')} : $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _restore() async {
    final st = context.read<AppState>();
    final s = st.s;
    setState(() => busy = true);
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final f = res.files.single;
      final String text;
      if (f.bytes != null) {
        text = utf8.decode(f.bytes!);
      } else if (f.path != null) {
        text = await File(f.path!).readAsString();
      } else {
        throw const FormatException('Fichier illisible');
      }
      final bundle = decodeBackup(text);
      st.validateBundle(bundle);
      if (!mounted) return;
      final ok = await confirmDialog(
          context, s, '${s.t('restore_confirm')}\n\n${s.t('rows')} : ${bundle.totalRows}');
      if (!ok) return;
      await st.restoreBackup(bundle);
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
            onPressed: busy ? null : _export,
            icon: const Icon(Icons.upload_file),
            label: Text(s.t('backup_export')),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy ? null : _restore,
            icon: const Icon(Icons.download),
            label: Text(s.t('backup_restore')),
          ),
          if (busy) const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
