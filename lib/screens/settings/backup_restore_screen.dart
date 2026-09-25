import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/constants.dart';
import '../../models/backup_model.dart';
import '../../services/backup_service.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isWorking = false;
  String? _statusMessage;

  Future<void> _createBackup() async {
    setState(() {
      _isWorking = true;
      _statusMessage = 'Cloud backup ban raha hai...';
    });

    try {
      final backup = await BackupService.createBackup();
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'Backup ban gaya! (${backup.sizeLabel})',
      );
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _restore(BackupModel backup) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Restore Backup?',
      message:
          '⚠️ Current data DELETE karke is backup se replace kar diya jayega.\n\n'
          'Backup: ${backup.label}\n'
          'People: ${backup.peopleCount} | Entries: ${backup.entriesCount}',
      confirmText: 'Restore Now',
    );
    if (!confirm || !mounted) return;

    setState(() {
      _isWorking = true;
      _statusMessage = 'Data restore ho raha hai...';
    });

    try {
      await BackupService.restoreBackup(backup.id, replaceAll: true);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Restore successful!');
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _deleteBackup(BackupModel backup) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Backup?',
      message: '${backup.label} delete ho jayega.',
      confirmText: 'Delete',
    );
    if (!confirm || !mounted) return;

    try {
      await BackupService.deleteBackup(backup.id);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Backup deleted');
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, e.toString(), isError: true);
    }
  }

  Future<void> _copyBackupText() async {
    setState(() {
      _isWorking = true;
      _statusMessage = 'Backup text tayar ho raha hai...';
    });

    try {
      final b64 = await BackupService.exportAsBase64String();
      await Clipboard.setData(ClipboardData(text: b64));
      if (!mounted) return;
      AppHelpers.showSnackBar(
          context, 'Backup code Clipboard mein Copy ho gaya!');
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _exportShare() async {
    setState(() {
      _isWorking = true;
      _statusMessage = 'Share file ban rahi hai...';
    });

    try {
      final b64 = await BackupService.exportAsBase64String();
      if (!mounted) return;
      await Share.share(
        b64,
        subject: 'KISAN_HISAB_BACKUP',
      );
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _importFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      AppHelpers.showSnackBar(
          context, 'Clipboard khali hai! Pehle backup code copy karein.',
          isError: true);
      return;
    }

    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Import Backup?',
      message:
          'Current data REPLACE ho jayega clipboard wale backup se. Continue?',
      confirmText: 'Import Now',
    );
    if (!confirm || !mounted) return;

    setState(() {
      _isWorking = true;
      _statusMessage = 'Backup import ho raha hai...';
    });

    try {
      await BackupService.importFromBase64String(text, replaceAll: true);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Import Successful!');
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Backup & Restore'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                color: AppColors.paaniColor,
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_outlined,
                        color: Colors.blue, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cloud Backup bina kisi storage cost ke Firestore mein mehfooz hota hai.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Create Cloud Backup Now',
                      icon: Icons.cloud_upload,
                      onPressed: _isWorking ? null : _createBackup,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isWorking ? null : _copyBackupText,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Code',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isWorking ? null : _importFromClipboard,
                            icon: const Icon(Icons.paste, size: 16),
                            label: const Text('Import Paste',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.toReceive,
                              side:
                                  const BorderSide(color: AppColors.toReceive),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isWorking ? null : _exportShare,
                          icon:
                              const Icon(Icons.share, color: AppColors.primary),
                          tooltip: 'Share',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saved Cloud Backups',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Backups List
              Expanded(
                child: StreamBuilder<List<BackupModel>>(
                  stream: BackupService.getBackupsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.toPay)),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    final backups = snapshot.data!;
                    if (backups.isEmpty) {
                      return const EmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'No backups yet',
                        subtitle:
                            'Tap "Create Cloud Backup Now" to save your data',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      itemCount: backups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final b = backups[index];
                        return Container(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.cloud_done,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    b.sizeLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppFormatters.date(b.createdAt)} • People: ${b.peopleCount} • Entries: ${b.entriesCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          _isWorking ? null : () => _restore(b),
                                      icon: const Icon(Icons.restore, size: 16),
                                      label: const Text('Restore'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size(0, 36),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppSizes.radiusSmall),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _isWorking
                                        ? null
                                        : () => _deleteBackup(b),
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.toPay, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isWorking)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(_statusMessage ?? 'Wait...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
