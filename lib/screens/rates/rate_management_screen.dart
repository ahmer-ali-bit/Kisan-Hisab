import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/rates/add_rate_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/rate_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/rates/rate_type_tabs.dart';
import '../../widgets/rates/rate_tile.dart';

class RateManagementScreen extends StatefulWidget {
  const RateManagementScreen({super.key});

  @override
  State<RateManagementScreen> createState() => _RateManagementScreenState();
}

class _RateManagementScreenState extends State<RateManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RateProvider>().startListening();
    });
  }

  void _openAddRate() {
    final type = context.read<RateProvider>().selectedType;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRateScreen(rateType: type),
      ),
    );
  }

  void _deleteRate(String id) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Rate?',
      message: 'Are you sure you want to delete this rate?',
      confirmText: 'Delete',
    );
    if (!confirm || !mounted) return;

    final success = await context.read<RateProvider>().deleteRate(id);
    if (success && mounted) {
      AppHelpers.showSnackBar(context, 'Rate deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RateProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Rate Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          RateTypeTabs(
            selectedType: provider.selectedType,
            onTypeChanged: (type) => provider.setType(type),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : provider.rates.isEmpty
                    ? EmptyState(
                        icon: Icons.currency_rupee,
                        title: 'No rates added',
                        subtitle:
                            'Tap + to add a new rate for ${provider.selectedType}',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall),
                        itemCount: provider.rates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final rate = provider.rates[index];
                          return RateTile(
                            rate: rate,
                            onDelete: () => _deleteRate(rate.id),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: _openAddRate,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New Rate',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
