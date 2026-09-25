import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../pending/pending_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start listening to real dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().startListening();
    });
  }

  void _onNavTapped(int index) {
    if (index == 0) return;
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
    if (index == 4) {
      Navigator.pushReplacementNamed(context, '/reports');
      return;
    }
  }

  void _openPending(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PendingScreen(initialTab: tabIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final greeting = AppHelpers.getGreeting();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: const Icon(Icons.menu, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
                const Text(
                  'Kisan Sahib 👋',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              AppHelpers.showSnackBar(context, 'No new notifications');
            },
          ),
        ],
      ),

      // ===== BODY =====
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async {
                provider.startListening();
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. OVERVIEW CARD (Clickable -> Pending Screen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                        Text(
                          'Tap card for details',
                          style: TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors.textLight.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    _buildOverviewCard(provider),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // 2. STATS ROW (Kapas & Paani)
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard('Kapas (Cotton)',
                                '${provider.kapasTotalMann.toStringAsFixed(1)} Mann')),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                            child: _buildStatCard('Paani (Water)',
                                '${provider.paaniTotalHours.toStringAsFixed(1)} Hours')),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // 3. RECENT ACTIVITY LIST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                        TextButton(
                          onPressed: () => _onNavTapped(3),
                          child: const Text('See All',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),

                    // Activity Tiles
                    if (provider.recentActivities.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'No recent activity yet',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      )
                    else
                      ...provider.recentActivities
                          .map((activity) => _buildActivityTile(activity)),

                    const SizedBox(height: 20),

                    // QUICK ENTRY BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/select-entry-type'),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Quick Entry',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMedium)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

      // ===== BOTTOM NAV BAR =====
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  // ===== WIDGET HELPERS =====

  Widget _buildOverviewCard(DashboardProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // To Receive Card (Tab 0)
          Expanded(
            child: InkWell(
              onTap: () => _openPending(0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                bottomLeft: Radius.circular(AppSizes.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('To Receive',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 13)),
                        Spacer(),
                        Icon(Icons.arrow_downward,
                            color: AppColors.toReceive, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(provider.toReceive),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.toReceive),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider
          Container(height: 60, width: 1, color: AppColors.border),
          // To Pay Card (Tab 1)
          Expanded(
            child: InkWell(
              onTap: () => _openPending(1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSizes.radiusMedium),
                bottomRight: Radius.circular(AppSizes.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('To Pay',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 13)),
                        Spacer(),
                        Icon(Icons.arrow_upward,
                            color: AppColors.toPay, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(provider.toPay),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.toPay),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityItem activity) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (activity.type == EntryTypes.kapas) {
      icon = Icons.grass;
      iconColor = Colors.orange.shade800;
      bgColor = AppColors.kapasColor;
    } else if (activity.type == EntryTypes.paani) {
      icon = Icons.water_drop;
      iconColor = Colors.blue.shade800;
      bgColor = AppColors.paaniColor;
    } else if (activity.type == EntryTypes.mazdoori) {
      icon = Icons.engineering;
      iconColor = Colors.amber.shade800;
      bgColor = AppColors.mazdoorColor;
    } else if (activity.type == EntryTypes.paymentReceive) {
      icon = Icons.arrow_downward;
      iconColor = AppColors.toReceive;
      bgColor = AppColors.toReceiveLight;
    } else {
      icon = Icons.arrow_upward;
      iconColor = AppColors.toPay;
      bgColor = AppColors.toPayLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(activity.subtitle,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(activity.time,
              style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
        ],
      ),
    );
  }
}
