import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/history/trash_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../services/entry_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/entries/entry_filter_tabs.dart';
import '../../widgets/entries/entry_tile.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String? personId;

  const HistoryScreen({super.key, this.personId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EntryModel> _filterEntries(List<EntryModel> entries) {
    var filtered = entries;

    // Filter by person if personId is provided
    if (widget.personId != null) {
      filtered = filtered.where((e) => e.personId == widget.personId).toList();
    }

    // Type filter
    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'payment') {
        filtered = filtered
            .where((e) =>
                e.type == EntryTypes.paymentReceive ||
                e.type == EntryTypes.paymentPay)
            .toList();
      } else {
        filtered = filtered.where((e) => e.type == _selectedFilter).toList();
      }
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        final personName = (e.personName ?? '').toLowerCase();
        final note = (e.note ?? '').toLowerCase();
        final typeData = e.typeData.values.map((v) => v.toString().toLowerCase()).join(' ');
        return personName.contains(query) ||
            note.contains(query) ||
            typeData.contains(query);
      }).toList();
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    context.watch<EntryProvider>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('History'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: widget.personId != null,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingMedium, 0, AppSizes.paddingMedium, AppSizes.paddingMedium),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, note, or details...',
                    hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter Tabs
                Row(
                  children: [
                    Expanded(
                      child: EntryFilterTabs(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (v) => setState(() => _selectedFilter = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<EntryModel>>(
        stream: EntryService.getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final filtered = _filterEntries(snapshot.data ?? []);
          final grouped = _groupByDate(filtered);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            color: AppColors.primary,
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions found',
                    subtitle: 'Try changing filters or search terms',
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      context.w(AppSizes.paddingMedium),
                      0,
                      context.w(AppSizes.paddingMedium),
                      context.h(32),
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final key = grouped.keys.elementAt(index);
                      final entries = grouped[key]!;
                      final firstDate = entries.first.date;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: context.h(AppSizes.paddingSmall)),
                            child: Text(
                              _getDateHeader(firstDate),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontSize: context.sp(14),
                              ),
                            ),
                          ),
                          ...entries.map((entry) => Padding(
                                padding: EdgeInsets.only(bottom: context.h(8)),
                                child: EntryTile(
                                  entry: entry,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TransactionDetailScreen(entry: entry),
                                      ),
                                    );
                                  },
                                ),
                              )),
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}