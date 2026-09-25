import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../providers/people_provider.dart';
import '../people/person_avatar.dart';

class PersonPicker extends StatelessWidget {
  final String label;
  final PersonModel? selectedPerson;
  final Function(PersonModel) onSelected;
  final bool isRequired;

  const PersonPicker({
    super.key,
    required this.label,
    required this.selectedPerson,
    required this.onSelected,
    this.isRequired = true,
  });

  void _openPicker(BuildContext context) {
    final peopleProvider = context.read<PeopleProvider>();
    final people = peopleProvider.allPeople;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Person',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: people.isEmpty
                  ? const Center(
                      child: Text(
                        'No people added yet.\nAdd people first from People screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: people.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final person = people[i];
                        final isSelected = selectedPerson?.id == person.id;
                        return ListTile(
                          leading: PersonAvatar(
                            name: person.name,
                            photoBase64: person.photoBase64,
                            radius: 20,
                          ),
                          title: Text(
                            person.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle:
                              person.phone != null ? Text(person.phone!) : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary)
                              : null,
                          onTap: () {
                            onSelected(person);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.toPay),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (selectedPerson != null) ...[
                  PersonAvatar(
                    name: selectedPerson!.name,
                    photoBase64: selectedPerson!.photoBase64,
                    radius: 14,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                ],
                Expanded(
                  child: Text(
                    selectedPerson?.name ?? 'Select person',
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedPerson != null
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
