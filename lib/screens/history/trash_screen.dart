import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/entries/entry_tile.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        context.read<EntryProvider>().startListeningTrash();
      } catch (e) {
        debugPrint('Trash init error: $e');
      }
      // Short delay so stream settle ho jaye
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _restore(EntryModel entry) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Restore Entry?',
      message: 'This entry will be restored and balances updated.',
      confirmText: 'Restore',
    );
    if (!confirm || !mounted) return;

    try {
      final success = await context.read<EntryProvider>().restoreEntry(entry);
      if (!mounted) return;
      if (success) {
        AppHelpers.showSnackBar(context, 'Entry restored');
      } else {
        AppHelpers.showSnackBar(context, 'Failed to restore', isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _permanentDelete(EntryModel entry) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Permanently?',
      message: 'This action cannot be undone. Entry will be deleted forever.',
      confirmText: 'Delete',
    );
    if (!confirm || !mounted) return;

    try {
      final success =
          await context.read<EntryProvider>().permanentDelete(entry.id);
      if (!mounted) return;
      if (success) {
        AppHelpers.showSnackBar(context, 'Entry deleted permanently');
      } else {
        AppHelpers.showSnackBar(context, 'Failed to delete', isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _clearAll(List<EntryModel> trash) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Clear All Trash?',
      message:
          'All ${trash.length} deleted entries will be permanently removed.',
      confirmText: 'Clear All',
    );
    if (!confirm || !mounted) return;

    try {
      for (var entry in trash) {
        await context.read<EntryProvider>().permanentDelete(entry.id);
      }
      if (mounted) AppHelpers.showSnackBar(context, 'Trash cleared');
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final trash = provider.trash;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Trash'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : provider.error != null && trash.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: AppColors.toPay),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not load trash',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                )
              : trash.isEmpty
                  ? const EmptyState(
                      icon: Icons.delete_outline,
                      title: 'Trash is empty',
                      subtitle: 'Deleted entries will appear here',
                    )
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          color: AppColors.toPayLight,
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.toPay, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${trash.length} deleted entries',
                                  style: const TextStyle(
                                    color: AppColors.toPay,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.all(AppSizes.paddingMedium),
                            itemCount: trash.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final entry = trash[index];
                              return Column(
                                children: [
                                  EntryTile(entry: entry),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _restore(entry),
                                            icon: const Icon(Icons.restore,
                                                size: 18),
                                            label: const Text('Restore'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.primary,
                                              side: const BorderSide(
                                                  color: AppColors.primary),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes.radiusSmall),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _permanentDelete(entry),
                                            icon: const Icon(
                                                Icons.delete_forever,
                                                size: 18),
                                            label: const Text('Delete'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.toPay,
                                              side: const BorderSide(
                                                  color: AppColors.toPay),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes.radiusSmall),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          child: CustomButton(
                            text: 'Clear All Trash',
                            icon: Icons.delete_sweep,
                            onPressed: () => _clearAll(trash),
                            color: AppColors.toPay,
                          ),
                        ),
                      ],
                    ),
    );
  }
}
