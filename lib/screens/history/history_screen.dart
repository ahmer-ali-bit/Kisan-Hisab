import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/history/trash_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/entries/entry_filter_tabs.dart';
import '../../widgets/entries/entry_tile.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryProvider>().startListening();
    });
  }

  List<EntryModel> _filterEntries(List<EntryModel> entries) {
    if (_selectedFilter == 'all') return entries;
    if (_selectedFilter == 'payment') {
      return entries
          .where((e) =>
              e.type == EntryTypes.paymentReceive ||
              e.type == EntryTypes.paymentPay)
          .toList();
    }
    return entries.where((e) => e.type == _selectedFilter).toList();
  }

  // Group entries by date
  Map<String, List<EntryModel>> _groupByDate(List<EntryModel> entries) {
    final Map<String, List<EntryModel>> grouped = {};
    for (var entry in entries) {
      final key = '${entry.date.day}-${entry.date.month}-${entry.date.year}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _onNavTapped(int index) {
    if (index == 3) return; // Already on History
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/people');
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/select-entry-type');
      return;
    }
    AppHelpers.showSnackBar(context, 'Tab $index — next modules mein aayega');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final filtered = _filterEntries(provider.entries);
    final grouped = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Trash',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSizes.paddingSmall),
          EntryFilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (v) => setState(() => _selectedFilter = v),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        subtitle: 'Add your first entry to get started',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium),
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final key = grouped.keys.elementAt(index);
                          final entries = grouped[key]!;
                          final firstDate = entries.first.date;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingSmall),
                                child: Text(
                                  _getDateHeader(firstDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ...entries.map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: EntryTile(
                                      entry: entry,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TransactionDetailScreen(
                                                    entry: entry),
                                          ),
                                        );
                                      },
                                    ),
                                  )),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTapped,
      ),
    );
  }
}
