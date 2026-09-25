import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/people/add_person_screen.dart';
import 'package:kisan_hisab/screens/people/person_account_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/people_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/people/person_tile.dart';
import '../../utils/helpers.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeopleProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 1) return; // already on People
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
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
    AppHelpers.showSnackBar(context, 'Tab $index — next modules mein aayega');
  }

  void _openAddPerson({person}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPersonScreen(person: person),
      ),
    );
    if (result == true && mounted) {
      // stream auto-refresh karega
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('People'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            onPressed: () => _openAddPerson(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingMedium,
              0,
              AppSizes.paddingMedium,
              AppSizes.paddingMedium,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: provider.search,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                hintStyle:
                    const TextStyle(color: AppColors.textLight, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.clear, color: AppColors.textLight),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : provider.people.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: provider.searchQuery.isEmpty
                            ? 'No people yet'
                            : 'No results found',
                        subtitle: provider.searchQuery.isEmpty
                            ? 'Tap + to add your first person'
                            : 'Try a different name or phone',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        itemCount: provider.people.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final person = provider.people[index];
                          return PersonTile(
                            person: person,
                            onTap: () {
                              // Module 7 Integration - Open Ledger Account
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PersonAccountScreen(personId: person.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddPerson(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: _onNavTapped,
      ),
    );
  }
}
