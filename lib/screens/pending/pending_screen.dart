import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../providers/people_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/people/pending_person_tile.dart';
import '../entries/dynamic_entry_screen.dart';
import '../people/person_account_screen.dart';

class PendingScreen extends StatefulWidget {
  /// 0 = To Receive, 1 = To Pay
  final int initialTab;

  const PendingScreen({super.key, this.initialTab = 0});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeopleProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PersonModel> _toReceiveList(List<PersonModel> people) {
    return people.where((p) => p.totalToReceive > 0).toList()
      ..sort((a, b) => b.totalToReceive.compareTo(a.totalToReceive));
  }

  List<PersonModel> _toPayList(List<PersonModel> people) {
    return people.where((p) => p.totalToPay > 0).toList()
      ..sort((a, b) => b.totalToPay.compareTo(a.totalToPay));
  }

  double _sumReceive(List<PersonModel> list) =>
      list.fold(0.0, (s, p) => s + p.totalToReceive);

  double _sumPay(List<PersonModel> list) =>
      list.fold(0.0, (s, p) => s + p.totalToPay);

  void _openAccount(PersonModel person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonAccountScreen(personId: person.id),
      ),
    );
  }

  void _quickReceive(PersonModel person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DynamicEntryScreen(
          entryType: EntryTypes.paymentReceive,
        ),
      ),
    );
  }

  void _quickPay(PersonModel person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DynamicEntryScreen(
          entryType: EntryTypes.paymentPay,
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
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
    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/history');
      return;
    }
    // index 4 = Reports — next module
    AppHelpers.showSnackBar(context, 'Reports — next module mein aayega');
  }

  @override
  Widget build(BuildContext context) {
    final people = context.watch<PeopleProvider>().allPeople;
    final receiveList = _toReceiveList(people);
    final payList = _toPayList(people);
    final totalReceive = _sumReceive(receiveList);
    final totalPay = _sumPay(payList);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Pending'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'To Receive'),
                Tab(text: 'To Pay'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ===== TO RECEIVE TAB =====
          _buildTabContent(
            list: receiveList,
            total: totalReceive,
            isToReceive: true,
            emptyTitle: 'Kuch lena nahi hai',
            emptySubtitle: 'Jis se lena ho, unki entries add karein',
            headerColor: AppColors.toReceive,
            headerBg: AppColors.toReceiveLight,
            headerLabel: 'Total To Receive',
          ),
          // ===== TO PAY TAB =====
          _buildTabContent(
            list: payList,
            total: totalPay,
            isToReceive: false,
            emptyTitle: 'Kuch dena nahi hai',
            emptySubtitle: 'Jis ko dena ho, unki entries add karein',
            headerColor: AppColors.toPay,
            headerBg: AppColors.toPayLight,
            headerLabel: 'Total To Pay',
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Pending often opened from Home overview
        onTap: _onNavTapped,
      ),
    );
  }

  Widget _buildTabContent({
    required List<PersonModel> list,
    required double total,
    required bool isToReceive,
    required String emptyTitle,
    required String emptySubtitle,
    required Color headerColor,
    required Color headerBg,
    required String headerLabel,
  }) {
    return Column(
      children: [
        // Summary Header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(AppSizes.paddingMedium),
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: headerColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerLabel,
                    style: TextStyle(
                      color: headerColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(total),
                    style: TextStyle(
                      color: headerColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Text(
                  '${list.length} people',
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: isToReceive ? Icons.arrow_downward : Icons.arrow_upward,
                  title: emptyTitle,
                  subtitle: emptySubtitle,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.paddingMedium,
                    0,
                    AppSizes.paddingMedium,
                    AppSizes.paddingMedium,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final person = list[index];
                    return PendingPersonTile(
                      person: person,
                      isToReceive: isToReceive,
                      onTap: () => _openAccount(person),
                      onAction: () {
                        if (isToReceive) {
                          _quickReceive(person);
                        } else {
                          _quickPay(person);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
